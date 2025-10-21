import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/blocs.dart';
import '../themes/themes.dart';

/// Un widget que muestra un mapa interactivo utilizando Google Maps.
///
/// Este widget permite:
/// - Establecer una posición inicial del mapa.
/// - Mostrar líneas poligonales y marcadores personalizados.
/// - Manejar eventos como mover el mapa o inicializar el controlador.
class MapView extends StatelessWidget {
  /// Posición inicial del mapa.
  final LatLng initialPosition;

  /// Conjunto de líneas poligonales que se mostrarán en el mapa.
  final Set<Polyline> polylines;

  /// Conjunto de marcadores que se mostrarán en el mapa.
  final Set<Marker> markers;

  /// Crea una instancia de [MapView].
  ///
  /// - [initialPosition] establece el centro inicial del mapa.
  /// - [polylines] define las rutas a mostrar en el mapa.
  /// - [markers] define los puntos de interés visibles.
  const MapView({
    super.key,
    required this.initialPosition,
    required this.polylines,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    // Calcula el tamaño del mapa excluyendo el AppBar
    final size = MediaQuery.of(context).size;
    final appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;

    // Obtiene la instancia del MapBloc para manejar eventos y estado
    final mapBloc = BlocProvider.of<MapBloc>(context);

    // Configura la posición inicial de la cámara
    final CameraPosition initialCameraPosition =
        CameraPosition(target: initialPosition, zoom: 15);

    return SizedBox(
      width: size.width,
      height: size.height - appBarHeight, // Altura ajustada al AppBar
      // Listener para eventos del puntero en el mapa
      child: Listener(
        // Detiene el seguimiento del usuario al mover el mapa
        onPointerMove: (event) => mapBloc.add(const OnStopFollowingUserEvent()),
        child: GoogleMap(
          initialCameraPosition: initialCameraPosition,
          compassEnabled: false,
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          zoomGesturesEnabled: true,
          mapToolbarEnabled: false,

          // Lanza un evento al crear el mapa para guardar su controlador
          onMapCreated: (controller) =>
              mapBloc.add(OnMapInitializedEvent(controller, context)),

          // Aplica un estilo al mapa
          style: jsonEncode(appleMapEsqueMapTheme),

          // Configuración de elementos visuales en el mapa
          polylines: polylines,
          markers: markers,

          // Actualiza el centro del mapa al mover la cámara
          onCameraMove: (position) => mapBloc.mapCenter = position.target,
        ),
      ),
    );
  }
}
