import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

part 'location_event.dart';
part 'location_state.dart';

/// **LocationBloc**
///
/// Gestiona la lógica relacionada con la ubicación del usuario:
/// - Seguimiento de la posición en tiempo real.
/// - Gestión de eventos como inicio o fin del seguimiento.
/// - Almacenamiento del historial de ubicaciones del usuario.
class LocationBloc extends Bloc<LocationEvent, LocationState> {
  /// Suscripción al flujo de posiciones del usuario.
  StreamSubscription? positionStream;

  /// Constructor para inicializar el **LocationBloc**.
  ///
  /// Configura los manejadores de eventos y establece el estado inicial.
  LocationBloc() : super(const LocationState()) {
    // Manejador del evento OnNewUserLocationEvent
    on<OnNewUserLocationEvent>((event, emit) {
      log.i(
          'LocationBloc: Nueva ubicación del usuario recibida: ${event.newLocation}');
      emit(state.copyWith(
        lastKnownLocation: event.newLocation,
        myLocationHistory: [
          ...state.myLocationHistory,
          event.newLocation
        ], // Agregar la nueva ubicación al historial
      ));
    });

    // Manejador del evento OnStartFollowingUser
    on<OnStartFollowingUser>((event, emit) {
      log.i('LocationBloc: Iniciado seguimiento de usuario');
      emit(state.copyWith(followingUser: true));
    });

    // Manejador del evento OnStopFollowingUser
    on<OnStopFollowingUser>((event, emit) {
      log.i('LocationBloc: Detenido seguimiento de usuario');
      emit(state.copyWith(followingUser: false));
    });
  }

  /// Obtiene la posición actual del usuario.
  ///
  /// Retorna la ubicación actual del usuario como un `LatLng`.
  /// En caso de error, lanza una excepción.
  Future<LatLng> getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      log.i('LocationBloc: Posición actual obtenida: $position');
      return LatLng(position.latitude, position.longitude);
    } catch (e, stackTrace) {
      log.e('LocationBloc: Error obteniendo posición actual',
          error: e, stackTrace: stackTrace);
      rethrow; // Propaga la excepción para manejarla en niveles superiores.
    }
  }

  /// Comienza a seguir al usuario emitiendo sus posiciones en tiempo real.
  ///
  /// Añade el evento **OnStartFollowingUser** y escucha el flujo de posiciones.
  void startFollowingUser() {
    add(const OnStartFollowingUser());
    positionStream = Geolocator.getPositionStream().listen((event) {
      final position = event;
      log.d('LocationBloc: Nueva posición emitida: $position');
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
    });
  }

  /// Detiene el seguimiento del usuario.
  ///
  /// Cancela la suscripción al flujo de posiciones y emite el evento **OnStopFollowingUser**.
  void stopFollowingUser() {
    log.i('LocationBloc: Deteniendo seguimiento de usuario');
    positionStream?.cancel();
    add(const OnStopFollowingUser());
  }

  /// Cierra el **LocationBloc** y libera los recursos asociados.
  ///
  /// Cancela cualquier suscripción activa antes de cerrar.
  @override
  Future<void> close() {
    log.i('LocationBloc: Cerrando LocationBloc y cancelando suscripciones.');
    stopFollowingUser(); // Asegura que no haya suscripciones activas.
    return super.close();
  }
}
