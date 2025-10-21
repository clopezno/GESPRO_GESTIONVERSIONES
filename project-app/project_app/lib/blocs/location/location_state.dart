part of 'location_bloc.dart';

/// **LocationState**
///
/// Representa el estado de la localización del usuario en el Bloc.
///
/// Atributos:
/// - **followingUser**: Indica si el mapa está centrado y siguiendo la ubicación del usuario.
/// - **lastKnownLocation**: Última ubicación conocida del usuario (puede ser `null` si no está disponible).
/// - **myLocationHistory**: Historial de ubicaciones del usuario, guardado como una lista de `LatLng`.
class LocationState extends Equatable {
  /// Indica si se está siguiendo la ubicación del usuario.
  ///
  /// Por defecto, se inicializa en `false`.
  final bool followingUser;

  /// Última ubicación conocida del usuario.
  ///
  /// Es de tipo `LatLng` y puede ser `null` inicialmente si aún no se ha determinado la ubicación.
  final LatLng? lastKnownLocation;

  /// Historial de ubicaciones del usuario.
  ///
  /// Se almacena como una lista de objetos `LatLng`. Si no se proporciona, se inicializa como una lista vacía.
  final List<LatLng> myLocationHistory;

  /// Constructor de **LocationState**.
  ///
  /// - `followingUser`: Define si el usuario está siendo seguido (por defecto `false`).
  /// - `lastKnownLocation`: Última ubicación conocida del usuario (puede ser `null`).
  /// - `myLocationHistory`: Historial de ubicaciones del usuario.
  const LocationState({
    this.followingUser = false,
    this.lastKnownLocation,
    List<LatLng>? myLocationHistory,
  }) : myLocationHistory = myLocationHistory ?? const [];

  /// Crea una copia del estado actual con nuevos valores opcionales.
  ///
  /// Si no se proporciona un valor para un parámetro, se mantiene el valor actual.
  ///
  /// Parámetros opcionales:
  /// - `followingUser`: Define si el usuario está siendo seguido.
  /// - `lastKnownLocation`: Nueva ubicación conocida.
  /// - `myLocationHistory`: Nuevo historial de ubicaciones.
  ///
  /// Devuelve una nueva instancia de `LocationState`.
  LocationState copyWith({
    bool? followingUser,
    LatLng? lastKnownLocation,
    List<LatLng>? myLocationHistory,
  }) =>
      LocationState(
        followingUser: followingUser ?? this.followingUser,
        lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
        myLocationHistory: myLocationHistory ?? this.myLocationHistory,
      );

  /// Define los valores que se comparan para determinar si dos estados son iguales.
  ///
  /// `props` permite que el paquete `Equatable` optimice la comparación de estados.
  @override
  List<Object?> get props => [
        followingUser,
        lastKnownLocation,
        myLocationHistory,
      ];
}
