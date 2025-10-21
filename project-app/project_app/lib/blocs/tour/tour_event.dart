part of 'tour_bloc.dart';

/// Clase base para todos los eventos del `TourBloc`.
///
/// Utiliza `Equatable` para permitir comparaciones entre instancias de eventos.
abstract class TourEvent extends Equatable {
  /// Constructor constante para `TourEvent`.
  const TourEvent();

  /// Lista de propiedades que se usarán para comparar instancias.
  @override
  List<Object> get props => [];
}

/// LoadTourEvent
///
/// Se dispara cuando se solicita cargar un EcoCityTour.
///
/// Parámetros:
/// - `city`: Nombre de la ciudad donde se realiza el tour.
/// - `numberOfSites`: Número de sitios a incluir en el tour.
/// - `userPreferences`: Lista de preferencias del usuario.
/// - `mode`: Modo de transporte (e.g., "walking", "cycling").
/// - `maxTime`: Tiempo máximo permitido para la ruta.
/// - `systemInstruction`: Instrucción específica para el sistema.
class LoadTourEvent extends TourEvent {
  final String city;
  final int numberOfSites;
  final List<String> userPreferences;
  final String mode;
  final double maxTime;
  final String systemInstruction;

  /// Constructor del evento `LoadTourEvent`.
  const LoadTourEvent({
    required this.city,
    required this.numberOfSites,
    required this.systemInstruction,
    required this.userPreferences,
    required this.mode,
    required this.maxTime,
  });

  /// Propiedades utilizadas para comparar instancias.
  @override
  List<Object> get props => [city, numberOfSites, userPreferences, mode, maxTime];
}

/// OnAddPoiEvent
///
/// Se dispara cuando se añade un punto de interés (POI) al tour.
///
/// Parámetros:
/// - `poi`: Instancia de `PointOfInterest` que representa el POI añadido.
class OnAddPoiEvent extends TourEvent {
  final PointOfInterest poi;

  /// Constructor del evento `OnAddPoiEvent`.
  const OnAddPoiEvent({required this.poi});

  /// Propiedades utilizadas para comparar instancias.
  @override
  List<Object> get props => [poi];
}

/// OnRemovePoiEvent
///
/// Se dispara cuando se elimina un punto de interés (POI) del tour.
///
/// Parámetros:
/// - `poi`: Instancia de `PointOfInterest` que representa el POI eliminado.
/// - `shouldUpdateMap`: Booleano que indica si el mapa debe actualizarse tras eliminar el POI.
class OnRemovePoiEvent extends TourEvent {
  final PointOfInterest poi;
  final bool shouldUpdateMap;

  /// Constructor del evento `OnRemovePoiEvent`.
  const OnRemovePoiEvent({required this.poi, this.shouldUpdateMap = true});

  /// Propiedades utilizadas para comparar instancias.
  @override
  List<Object> get props => [poi, shouldUpdateMap];
}

/// **OnJoinTourEvent**
///
/// Se dispara cuando el usuario se une al tour actual.
///
/// No tiene parámetros porque solo indica una acción.
class OnJoinTourEvent extends TourEvent {
  /// Constructor constante del evento `OnJoinTourEvent`.
  const OnJoinTourEvent();
}

/// **ResetTourEvent**
///
/// Se dispara para resetear el estado del tour.
///
/// Generalmente utilizado al regresar a la pantalla de carga inicial.
class ResetTourEvent extends TourEvent {
  /// Constructor constante del evento `ResetTourEvent`.
  const ResetTourEvent();
}

/// **LoadSavedToursEvent**
///
/// Se dispara para cargar los tours guardados.
///
/// Generalmente utilizado después de realizar acciones como eliminar un tour guardado.
class LoadSavedToursEvent extends TourEvent {
  /// Constructor constante del evento `LoadSavedToursEvent`.
  const LoadSavedToursEvent();
}

/// **LoadTourFromSavedEvent**
///
/// Se dispara cuando se carga un tour desde la lista de tours guardados.
///
/// Parámetros:
/// - `documentId`: ID del documento que identifica el tour en la base de datos.
class LoadTourFromSavedEvent extends TourEvent {
  final String documentId;

  /// Constructor del evento `LoadTourFromSavedEvent`.
  const LoadTourFromSavedEvent({required this.documentId});

  /// Propiedades utilizadas para comparar instancias.
  @override
  List<Object> get props => [documentId];
}
