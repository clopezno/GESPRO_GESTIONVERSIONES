part of 'map_bloc.dart';

/// Clase base para todos los eventos del `MapBloc`.
///
/// Esta clase abstracta utiliza `Equatable` para facilitar la comparación entre eventos.
/// Proporciona una lista de propiedades (`props`) para determinar si dos eventos son iguales.
abstract class MapEvent extends Equatable {
  /// Constructor constante de la clase base `MapEvent`.
  const MapEvent();

  /// Define las propiedades que se utilizan para la comparación.
  ///
  /// Por defecto, devuelve una lista vacía.
  @override
  List<Object> get props => [];
}

/// Evento que se dispara cuando el mapa ha sido inicializado.
///
/// Parámetros:
/// - `mapController`: Controlador del mapa de Google Maps.
/// - `mapContext`: Contexto del mapa para interactuar con la UI.
class OnMapInitializedEvent extends MapEvent {
  /// Controlador del mapa de Google Maps.
  final GoogleMapController mapController;

  /// Contexto del mapa, útil para interactuar con la UI desde el bloc.
  final BuildContext mapContext;

  /// Constructor del evento `OnMapInitializedEvent`.
  const OnMapInitializedEvent(this.mapController, this.mapContext);

  /// Propiedades utilizadas para la comparación.
  ///
  /// Incluye `mapController` y `mapContext`.
  @override
  List<Object> get props => [mapController, mapContext];
}

/// Evento que se dispara para detener el seguimiento de la ubicación del usuario.
class OnStopFollowingUserEvent extends MapEvent {
  /// Constructor constante del evento `OnStopFollowingUserEvent`.
  const OnStopFollowingUserEvent();
}

/// Evento que se dispara para iniciar el seguimiento de la ubicación del usuario.
class OnStartFollowingUserEvent extends MapEvent {
  /// Constructor constante del evento `OnStartFollowingUserEvent`.
  const OnStartFollowingUserEvent();
}

/// Evento para actualizar las polilíneas de la ruta del usuario.
///
/// Parámetros:
/// - `userLocations`: Lista de ubicaciones del usuario representadas como `LatLng`.
class OnUpdateUserPolylinesEvent extends MapEvent {
  /// Lista de ubicaciones del usuario.
  final List<LatLng> userLocations;

  /// Constructor del evento `OnUpdateUserPolylinesEvent`.
  const OnUpdateUserPolylinesEvent(this.userLocations);

  /// Propiedades utilizadas para la comparación.
  ///
  /// Incluye `userLocations`.
  @override
  List<Object> get props => [userLocations];
}

/// Evento para alternar la visibilidad de la ruta del usuario.
class OnToggleShowUserRouteEvent extends MapEvent {
  /// Constructor constante del evento `OnToggleShowUserRouteEvent`.
  const OnToggleShowUserRouteEvent();
}

/// Evento para mostrar nuevas polilíneas y marcadores en el mapa.
///
/// Parámetros:
/// - `polylines`: Mapa de polilíneas que se deben renderizar.
/// - `markers`: Mapa de marcadores que se deben renderizar.
class OnDisplayPolylinesEvent extends MapEvent {
  /// Polilíneas para renderizar en el mapa.
  final Map<String, Polyline> polylines;

  /// Marcadores para renderizar en el mapa.
  final Map<String, Marker> markers;

  /// Constructor del evento `OnDisplayPolylinesEvent`.
  const OnDisplayPolylinesEvent(this.polylines, this.markers);

  /// Propiedades utilizadas para la comparación.
  ///
  /// Incluye `polylines` y `markers`.
  @override
  List<Object> get props => [polylines, markers];
}

/// Evento para eliminar un marcador de Punto de Interés (POI) del mapa.
///
/// Parámetros:
/// - `poiName`: Nombre del POI que se eliminará.
class OnRemovePoiMarkerEvent extends MapEvent {
  /// Nombre del POI que se eliminará.
  final String poiName;

  /// Constructor del evento `OnRemovePoiMarkerEvent`.
  const OnRemovePoiMarkerEvent(this.poiName);

  /// Propiedades utilizadas para la comparación.
  ///
  /// Incluye `poiName`.
  @override
  List<Object> get props => [poiName];
}

/// Evento para añadir un marcador de Punto de Interés (POI) al mapa.
///
/// Parámetros:
/// - `poi`: Información del POI que se añadirá como marcador.
class OnAddPoiMarkerEvent extends MapEvent {
  /// Información del POI que se añadirá.
  final PointOfInterest poi;

  /// Constructor del evento `OnAddPoiMarkerEvent`.
  const OnAddPoiMarkerEvent(this.poi);

  /// Propiedades utilizadas para la comparación.
  ///
  /// Incluye `poi`.
  @override
  List<Object> get props => [poi];
}

/// Evento para limpiar todas las polilíneas y marcadores del mapa.
class OnClearMapEvent extends MapEvent {
  /// Constructor constante del evento `OnClearMapEvent`.
  const OnClearMapEvent();
}
