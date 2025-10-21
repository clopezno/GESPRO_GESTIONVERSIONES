part of 'gps_bloc.dart';

/// Clase base para todos los eventos relacionados con el GPS.
///
/// Esta clase utiliza `Equatable` para facilitar la comparación de eventos.
/// Todas las subclases deben extender `GpsEvent`.
sealed class GpsEvent extends Equatable {
  /// Constructor base para los eventos del GPS.
  const GpsEvent();

  /// Lista de propiedades que se utilizarán para comparar eventos.
  ///
  /// Por defecto, esta lista está vacía y se sobrescribe en subclases
  /// para incluir las propiedades relevantes.
  @override
  List<Object> get props => [];
}

/// Evento que se dispara al comprobar el estado del GPS y los permisos.
///
/// Este evento se utiliza para comunicar si:
/// - El GPS está habilitado en el dispositivo.
/// - La aplicación tiene permisos para acceder al GPS.
///
/// Ejemplo de uso:
/// ```dart
/// bloc.add(OnGpsAndPermissionEvent(
///   isGpsEnabled: true,
///   isGpsPermissionGranted: false,
/// ));
/// ```
class OnGpsAndPermissionEvent extends GpsEvent {
  /// Indica si el GPS está activado.
  final bool isGpsEnabled;

  /// Indica si los permisos de GPS han sido otorgados a la aplicación.
  final bool isGpsPermissionGranted;

  /// Constructor que inicializa el evento con el estado del GPS y permisos.
  ///
  /// - `isGpsEnabled`: Debe ser `true` si el GPS está activado.
  /// - `isGpsPermissionGranted`: Debe ser `true` si los permisos han sido otorgados.
  const OnGpsAndPermissionEvent({
    required this.isGpsEnabled,
    required this.isGpsPermissionGranted,
  });

  /// Sobrescribe `props` para incluir las propiedades que identifican el evento.
  ///
  /// Esto asegura que dos eventos con las mismas propiedades sean considerados iguales.
  @override
  List<Object> get props => [isGpsEnabled, isGpsPermissionGranted];
}
