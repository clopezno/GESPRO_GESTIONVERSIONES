import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:project_app/logger/logger.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/ui/ui.dart';
import 'package:project_app/views/views.dart';
import 'package:project_app/widgets/widgets.dart';

/// Pantalla principal que muestra el mapa y la información del EcoCityTour.
///
/// Esta pantalla incluye funcionalidades como:
/// - Mostrar el mapa con la ruta del tour.
/// - Añadir puntos de interés (POIs) al tour.
/// - Unirse al tour.
/// - Manejar el estado del GPS y la ubicación en tiempo real.
class MapScreen extends StatefulWidget {
  /// Datos del tour a ser mostrados en el mapa.
  final EcoCityTour tour;

  const MapScreen({
    super.key,
    required this.tour,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  /// Bloc que gestiona el estado de la ubicación.
  late LocationBloc locationBloc;

  /// Bandera para evitar mostrar múltiples diálogos de carga.
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    locationBloc = BlocProvider.of<LocationBloc>(context);
    locationBloc.startFollowingUser(); // Comienza a seguir al usuario
    _initializeRouteAndPois();
    log.i('MapScreen: Inicializado para el EcoCityTour en ${widget.tour.city}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: MultiBlocListener(
        listeners: [
          BlocListener<TourBloc, TourState>(
            listener: (context, state) => _handleLoadingState(state),
          ),
        ],
        child: BlocBuilder<LocationBloc, LocationState>(
          builder: (context, locationState) {
            if (locationState.lastKnownLocation == null) {
              return _buildLoadingTourMessage(context);
            }
            return _buildMapView(locationState);
          },
        ),
      ),
    );
  }

  /// Construye la barra de navegación personalizada.
  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<TourBloc, TourState>(
        builder: (context, tourState) {
          return CustomAppBar(
            title: 'eco_city_tour_title'.tr(),
            tourState: tourState,
          );
        },
      ),
    );
  }

  /// Maneja el estado de carga del [TourBloc].
  void _handleLoadingState(TourState state) {
    if (state.isLoading && !_isDialogShown) {
      _isDialogShown = true;
      LoadingMessageHelper.showLoadingMessage(context);
    } else if (!state.isLoading && _isDialogShown) {
      _isDialogShown = false;
      if (Navigator.canPop(context)) Navigator.of(context).pop();
    }
  }

Widget _buildMapView(LocationState locationState) {
  return BlocBuilder<MapBloc, MapState>(
    builder: (context, mapState) {
      final tourState = context.watch<TourBloc>().state;
      
      // Determinar la posición inicial del mapa
      final initialPosition = (tourState.ecoCityTour != null &&
              tourState.ecoCityTour!.pois.isNotEmpty)
          ? tourState.ecoCityTour!.pois.first.gps
          : locationState.lastKnownLocation;

      return Stack(
        children: [
          MapView(
            initialPosition: initialPosition!,
            polylines: mapState.polylines.values.toSet(),
            markers: mapState.markers.values.toSet(),
          ),
          _buildSearchBar(),
          _buildMapButtons(),
          _buildJoinTourButton(),
        ],
      );
    },
  );
}



  /// Construye la barra de búsqueda en el mapa.
  Widget _buildSearchBar() {
    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        if (state.ecoCityTour != null) {
          return const Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: CustomSearchBar(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Construye los botones flotantes en el mapa.
  Widget _buildMapButtons() {
    return const Positioned(
      bottom: 90, // Espaciado del botón principal
      right: 10,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          BtnToggleUserRoute(),
          SizedBox(height: 15), // Espacio entre botones
          BtnFollowUser(),
        ],
      ),
    );
  }

  /// Construye el botón para unirse al EcoCityTour.
  Widget _buildJoinTourButton() {
    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        if (state.ecoCityTour != null && !state.isJoined) {
          return Positioned(
            bottom: 40,
            left: 32,
            right: 32,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MaterialButton(
                color: Theme.of(context).primaryColor,
                height: 50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                onPressed: _joinEcoCityTour,
                child: Text(
                  'join_eco_city_tour'.tr(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  /// Construye un mensaje mientras se espera la ubicación.
  Widget _buildLoadingTourMessage(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined,
                size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              'loading_eco_city_tour'.tr(),
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'waiting_for_gps'.tr(),
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Inicializa la ruta y mueve la cámara al primer POI.
  Future<void> _initializeRouteAndPois() async {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    log.i('MapScreen: Dibujando ruta optimizada.');
    await mapBloc.drawEcoCityTour(widget.tour);

    if (widget.tour.pois.isNotEmpty) {
      mapBloc.moveCamera(widget.tour.pois.first.gps);
    }
  }

  /// Añade la ubicación actual al tour y activa el evento de unión al tour.
  void _joinEcoCityTour() {
    final lastKnownLocation = locationBloc.state.lastKnownLocation;

    if (lastKnownLocation == null) {
      _showSnackbar('no_location_found'.tr());
      return;
    }

    final newPoi = PointOfInterest(
      gps: lastKnownLocation,
      name: 'current_location'.tr(),
      description: 'current_location_description'.tr(),
      url: null,
      imageUrl: null,
      rating: 5.0,
    );

    log.i('Añadiendo ubicación actual al tour.');
    BlocProvider.of<TourBloc>(context).add(OnAddPoiEvent(poi: newPoi));
    BlocProvider.of<TourBloc>(context).add(const OnJoinTourEvent());
  }

  /// Muestra un Snackbar con un mensaje.
  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar(msg: message));
  }

  @override
  void dispose() {
    locationBloc.stopFollowingUser();
    log.i('MapScreen: Cerrando pantalla y deteniendo seguimiento.');
    super.dispose();
  }
}
