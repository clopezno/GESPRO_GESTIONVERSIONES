part of 'gps_bloc.dart';

/// Representa el estado del GPS en la aplicación.
///
/// Este estado mantiene información sobre:
/// - Si el GPS está activado.
/// - Si la aplicación tiene permisos para acceder al GPS.
/// 
/// También incluye un **getter** que combina ambos valores para verificar
/// si el GPS está listo para ser utilizado.
class GpsState extends Equatable {
  /// Indica si el GPS del dispositivo está habilitado.
  final bool isGpsEnabled;

  /// Indica si los permisos de acceso al GPS han sido otorgados.
  final bool isGpsPermissionGranted;

  /// Getter que retorna `true` si tanto el GPS está habilitado como si
  /// los permisos han sido concedidos.
  ///
  /// Esto permite comprobar de forma sencilla si la aplicación puede 
  /// utilizar correctamente las funcionalidades de GPS.
  bool get isAllReady => isGpsEnabled && isGpsPermissionGranted;

  /// Constructor que inicializa las propiedades del estado.
  ///
  /// - `isGpsEnabled`: Debe ser `true` si el GPS está activado.
  /// - `isGpsPermissionGranted`: Debe ser `true` si la aplicación tiene permisos.
  const GpsState({
    required this.isGpsEnabled,
    required this.isGpsPermissionGranted,
  });

  /// Crea una copia del estado actual con propiedades modificadas opcionalmente.
  ///
  /// Este método es útil cuando se quiere mantener parte del estado actual
  /// y solo cambiar valores específicos.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final newState = currentState.copyWith(isGpsEnabled: true);
  /// ```
  GpsState copyWith({
    bool? isGpsEnabled,
    bool? isGpsPermissionGranted,
  }) =>
      GpsState(
        isGpsEnabled: isGpsEnabled ??
            this.isGpsEnabled, // Mantiene el valor actual si no se proporciona uno nuevo.
        isGpsPermissionGranted: isGpsPermissionGranted ??
            this.isGpsPermissionGranted, // Mantiene el valor actual si no se proporciona uno nuevo.
      );

  /// Define las propiedades utilizadas por `Equatable` para comparar estados.
  ///
  /// Esto asegura que dos instancias de `GpsState` con las mismas propiedades
  /// sean consideradas iguales.
  @override
  List<Object> get props => [isGpsEnabled, isGpsPermissionGranted];

  /// Devuelve una representación en string del estado actual.
  ///
  /// Útil para depuración y registro en el log.
  @override
  String toString() {
    return 'GpsState(isGpsEnabled: $isGpsEnabled, isGpsPermissionGranted: $isGpsPermissionGranted)';
  }
}
