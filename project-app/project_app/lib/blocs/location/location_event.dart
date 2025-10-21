part of 'location_bloc.dart';

/// Clase base para los eventos del **LocationBloc**.
///
/// - Utiliza **Equatable** para facilitar la comparación de eventos.
/// - Proporciona una lista de propiedades (`props`) para determinar la igualdad entre instancias.
class LocationEvent extends Equatable {
  /// Constructor constante para **LocationEvent**.
  const LocationEvent();

  @override
  List<Object> get props => [];
}

/// Evento que se dispara cuando hay una nueva ubicación del usuario.
///
/// Parámetros:
/// - `newLocation`: La nueva ubicación del usuario representada por `LatLng`.
class OnNewUserLocationEvent extends LocationEvent {
  /// Nueva ubicación del usuario.
  final LatLng newLocation;

  /// Constructor del evento **OnNewUserLocationEvent**.
  ///
  /// - `newLocation` es un parámetro obligatorio porque siempre se espera una única ubicación.
  const OnNewUserLocationEvent(this.newLocation);

  @override
  List<Object> get props => [newLocation];
}

/// Evento que se dispara cuando la aplicación comienza a seguir la ubicación del usuario.
///
/// No necesita parámetros porque solo indica una acción.
class OnStartFollowingUser extends LocationEvent {
  const OnStartFollowingUser();
}

/// Evento que se dispara cuando la aplicación deja de seguir la ubicación del usuario.
///
/// No necesita parámetros porque solo indica una acción.
class OnStopFollowingUser extends LocationEvent {
  const OnStopFollowingUser();
}
