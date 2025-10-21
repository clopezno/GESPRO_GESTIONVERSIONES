import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:project_app/logger/logger.dart'; // Importamos logger para usarlo

part 'gps_event.dart';
part 'gps_state.dart';

/// **GpsBloc**: Gestiona el estado del GPS y los permisos de localización.
///
/// Este Bloc se encarga de:
/// - Comprobar si el GPS está habilitado.
/// - Solicitar permisos de localización al usuario.
/// - Escuchar cambios en el estado del GPS.
/// - Emitir estados actualizados a través de eventos.
class GpsBloc extends Bloc<GpsEvent, GpsState> {
  /// Suscripción al stream que escucha cambios en el estado del GPS.
  StreamSubscription? _gpsSubscription;

  /// Constructor del GpsBloc.
  ///
  /// Inicializa el estado con `isGpsEnabled` y `isGpsPermissionGranted` en `false`.
  GpsBloc()
      : super(const GpsState(
            isGpsEnabled: false, isGpsPermissionGranted: false)) {
    // Manejo del evento `OnGpsAndPermissionEvent`
    on<OnGpsAndPermissionEvent>((event, emit) {
      log.i(
          'GpsBloc: Recibido evento OnGpsAndPermissionEvent - GPS habilitado: ${event.isGpsEnabled}, Permisos: ${event.isGpsPermissionGranted}');
      emit(state.copyWith(
        isGpsEnabled: event.isGpsEnabled,
        isGpsPermissionGranted: event.isGpsPermissionGranted,
      ));
    });

    _init(); // Inicializa el estado del GPS y los permisos.
  }

  /// Inicializa el estado del GPS y los permisos de localización.
  ///
  /// Combina el resultado de `checkGpsStatus` y `isPermissionGranted`
  /// para emitir el estado inicial.
  Future<void> _init() async {
    try {
      log.i('GpsBloc: Inicializando estado del GPS y permisos.');

      final gpsInitStatus =
          await Future.wait([checkGpsStatus(), isPermissionGranted()]);

      log.d(
          'GpsBloc: Estado inicial - GPS habilitado: ${gpsInitStatus[0]}, Permisos concedidos: ${gpsInitStatus[1]}');

      add(OnGpsAndPermissionEvent(
          isGpsEnabled: gpsInitStatus[0],
          isGpsPermissionGranted: gpsInitStatus[1]));
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al inicializar GPS o permisos',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Comprueba si los permisos de localización están concedidos.
  ///
  /// Devuelve `true` si los permisos están concedidos, de lo contrario `false`.
  Future<bool> isPermissionGranted() async {
    try {
      final isGranted = await Permission.location.isGranted;
      log.d('GpsBloc: Permiso de localización concedido: $isGranted');
      return isGranted;
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al comprobar los permisos de localización',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Comprueba si el GPS está habilitado en el dispositivo.
  ///
  /// Escucha cambios en el estado del GPS usando `Geolocator.getServiceStatusStream`.
  /// Devuelve `true` si el GPS está habilitado.
  Future<bool> checkGpsStatus() async {
    try {
      final isEnable = await Geolocator.isLocationServiceEnabled();
      log.d('GpsBloc: GPS habilitado: $isEnable');

      _gpsSubscription = Geolocator.getServiceStatusStream().listen((event) {
        final isEnabled = (event.index == 1);
        log.d('GpsBloc: Cambió el estado del GPS - Habilitado: $isEnabled');
        add(OnGpsAndPermissionEvent(
            isGpsEnabled: isEnabled,
            isGpsPermissionGranted: state.isGpsPermissionGranted));
      });

      return isEnable;
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al verificar el estado del GPS',
          error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Solicita permisos de localización al usuario.
  ///
  /// Dependiendo del estado del permiso, emite un evento para actualizar el estado:
  /// - `PermissionStatus.granted`: Permiso concedido.
  /// - Otros estados: Permiso denegado y se abre la configuración de la app.
  Future<void> askGpsAccess() async {
    try {
      final status = await Permission.location.request();
      log.i('GpsBloc: Solicitando acceso al GPS, estado: $status');

      switch (status) {
        case PermissionStatus.granted:
          log.i('GpsBloc: Permiso de GPS concedido.');
          add(OnGpsAndPermissionEvent(
              isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: true));
          break;
        case PermissionStatus.denied:
        case PermissionStatus.restricted:
        case PermissionStatus.permanentlyDenied:
          log.w('GpsBloc: Permiso de GPS denegado o restringido.');
          add(OnGpsAndPermissionEvent(
              isGpsEnabled: state.isGpsEnabled, isGpsPermissionGranted: false));
          openAppSettings();
          break;
        default:
          break;
      }
    } catch (e, stackTrace) {
      log.e('GpsBloc: Error al solicitar acceso al GPS',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Cierra el GpsBloc y cancela la suscripción al stream de cambios en el GPS.
  @override
  Future<void> close() {
    log.i('GpsBloc: Cerrando GpsBloc y cancelando suscripciones.');
    _gpsSubscription?.cancel();
    return super.close();
  }
}
