import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/helpers/custom_image_marker.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/widgets/widgets.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  GoogleMapController? _mapController; // Controlador del mapa
  final LocationBloc locationBloc; // Bloc de ubicación para obtener la posición del usuario
  StreamSubscription<LocationState>? locationSubscription; // Suscripción al estado de ubicación

  LatLng? mapCenter; // Coordenadas del centro del mapa

  MapBloc({required this.locationBloc}) : super(const MapState()) {
    // Manejar eventos del MapBloc
    on<OnMapInitializedEvent>(_onInitMap);
    on<OnStartFollowingUserEvent>(_onStartFollowingUser);
    on<OnStopFollowingUserEvent>(
        (event, emit) => emit(state.copyWith(isFollowingUser: false)));
    on<OnUpdateUserPolylinesEvent>(_onPolylineNewPoint);
    on<OnDisplayPolylinesEvent>((event, emit) => emit(
        state.copyWith(polylines: event.polylines, markers: event.markers)));
    on<OnToggleShowUserRouteEvent>((event, emit) =>
        emit(state.copyWith(showUserRoute: !state.showUserRoute)));
    on<OnRemovePoiMarkerEvent>(_onRemovePoiMarker);
    on<OnAddPoiMarkerEvent>(_onAddPoiMarker);
    on<OnClearMapEvent>(_onClearMap); // Maneja el evento de limpiar el mapa

    // Suscribirse al LocationBloc para obtener actualizaciones de ubicación
    locationSubscription = locationBloc.stream.listen((locationState) {
      if (locationState.lastKnownLocation != null) {
        log.i(
            'Añadiendo nueva polilínea con la ubicación del usuario: ${locationState.lastKnownLocation}');
        add(OnUpdateUserPolylinesEvent(locationState.myLocationHistory));
      }

      if (!state.isFollowingUser) return;
      if (locationState.lastKnownLocation == null) return;
    });
  }

  // Inicializa el mapa con el controlador y el contexto
  Future<void> _onInitMap(OnMapInitializedEvent event, Emitter<MapState> emit) async {
    _mapController = event.mapController;
    log.i('Mapa inicializado. Controlador del mapa establecido.');
    emit(state.copyWith(isMapInitialized: true, mapContext: event.mapContext));
  }

  // Mueve la cámara a una ubicación específica
  Future<void> moveCamera(LatLng latLng) async {
    if (_mapController == null) {
      log.w('El controlador del mapa aún no está listo.');
      return;
    }
    log.i('Moviendo cámara a la posición: $latLng');
    final cameraUpdate = CameraUpdate.newLatLng(latLng);
    await _mapController?.animateCamera(cameraUpdate);
  }

  // Comienza a seguir la ubicación del usuario
  Future<void> _onStartFollowingUser(
      OnStartFollowingUserEvent event, Emitter<MapState> emit) async {
    emit(state.copyWith(isFollowingUser: true));
    log.i('Comenzando a seguir al usuario.');
    if (locationBloc.state.lastKnownLocation == null) return;
    await moveCamera(locationBloc.state.lastKnownLocation!);
  }

  // Añade un nuevo punto a la polilínea de la ruta del usuario
  void _onPolylineNewPoint(
      OnUpdateUserPolylinesEvent event, Emitter<MapState> emit) {
    log.i('Añadiendo nuevo punto a la polilínea.');
    final myRoute = Polyline(
      polylineId: const PolylineId('myRoute'),
      points: event.userLocations,
      width: 5,
      color: const Color.fromARGB(255, 207, 18, 135),
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );
    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    currentPolylines['myRoute'] = myRoute;
    emit(state.copyWith(polylines: currentPolylines));
  }

  // Dibuja un EcoCityTour en el mapa, añadiendo polilíneas y marcadores
  Future<void> drawEcoCityTour(EcoCityTour tour) async {
    log.i('Dibujando EcoCityTour en el mapa: ${tour.name}');
    final myRoute = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.teal,
      width: 5,
      points: tour.polilynePoints,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
    );

    Map<String, Marker> poiMarkers = {};
    if (tour.pois.isNotEmpty) {
      for (var poi in tour.pois) {
        final icon = poi.imageUrl != null
            ? await getNetworkImageMarker(poi.imageUrl!)
            : await getCustomMarker();

        final poiMarker = Marker(
          markerId: MarkerId(poi.name),
          position: poi.gps,
          icon: icon,
          onTap: () async {
            if (state.mapContext != null) {
              log.i('Mostrando detalles del lugar: ${poi.name}');
              showPlaceDetails(state.mapContext!, poi);
            }
          },
        );
        poiMarkers[poi.name] = poiMarker;
      }
    }

    final currentPolylines = Map<String, Polyline>.from(state.polylines);
    final currentMarkers = Map<String, Marker>.from(state.markers);
    currentPolylines['route'] = myRoute;
    currentMarkers.addAll(poiMarkers);

    add(OnDisplayPolylinesEvent(currentPolylines, currentMarkers));

    if (tour.pois.isNotEmpty) {
      final LatLng firstPoiLocation = tour.pois.first.gps;
      log.i('Moviendo la cámara al primer POI: ${tour.pois.first.name}');
      await moveCamera(firstPoiLocation);
    }
  }

  // Muestra los detalles de un lugar en un BottomSheet
  void showPlaceDetails(BuildContext context, PointOfInterest poi) {
    log.i('Mostrando detalles del POI: ${poi.name}');
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return CustomBottomSheet(poi: poi);
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
    );
  }

  // Elimina un marcador de POI del mapa
  void _onRemovePoiMarker(
      OnRemovePoiMarkerEvent event, Emitter<MapState> emit) {
    log.i('Eliminando marcador de POI: ${event.poiName}');
    final updatedMarkers = Map<String, Marker>.from(state.markers);
    updatedMarkers.remove(event.poiName);
    emit(state.copyWith(markers: updatedMarkers));
  }

  // Añade un marcador de POI al mapa
  Future<void> _onAddPoiMarker(
      OnAddPoiMarkerEvent event, Emitter<MapState> emit) async {
    log.i('Añadiendo marcador de POI: ${event.poi.name}');
    final updatedMarkers = Map<String, Marker>.from(state.markers);
    final icon = event.poi.imageUrl != null
        ? await getNetworkImageMarker(event.poi.imageUrl!)
        : await getCustomMarker();

    final poiMarker = Marker(
      markerId: MarkerId(event.poi.name),
      position: event.poi.gps,
      icon: icon,
      onTap: () async {
        if (state.mapContext != null) {
          showPlaceDetails(state.mapContext!, event.poi);
        }
      },
    );

    updatedMarkers[event.poi.name] = poiMarker;
    emit(state.copyWith(markers: updatedMarkers));
  }

  // Limpia todos los marcadores y polilíneas del mapa
  void _onClearMap(OnClearMapEvent event, Emitter<MapState> emit) {
    log.i('MapBloc: Limpiando todos los marcadores y polilíneas del mapa.');
    emit(state.copyWith(
      polylines: {},
      markers: {},
    ));
  }

  @override
  Future<void> close() async {
    log.i('Cerrando MapBloc y cancelando suscripción de localización.');
    await locationSubscription?.cancel();
    await super.close();
  }
}
