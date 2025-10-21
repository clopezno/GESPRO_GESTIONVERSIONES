part of 'map_bloc.dart';

/// Representa el estado del mapa en el `MapBloc`.
///
/// Este estado contiene información sobre:
/// - Inicialización del mapa.
/// - Seguimiento de la ubicación del usuario.
/// - Visibilidad de rutas.
/// - Polilíneas y marcadores que se deben mostrar en el mapa.
/// - Contexto del mapa para interactuar con la interfaz de usuario.
class MapState extends Equatable {
  /// Indica si el mapa ha sido inicializado.
  final bool isMapInitialized;

  /// Indica si el mapa está siguiendo la ubicación del usuario.
  final bool isFollowingUser;

  /// Indica si la ruta del usuario debe ser visible en el mapa.
  final bool showUserRoute;

  /// Mapa que contiene las polilíneas que se deben renderizar en el mapa.
  final Map<String, Polyline> polylines;

  /// Mapa que contiene los marcadores que se deben renderizar en el mapa.
  final Map<String, Marker> markers;

  /// Contexto del mapa, útil para interactuar con la UI desde el bloc.
  final BuildContext? mapContext;

  /// Constructor de `MapState`.
  ///
  /// Inicializa los parámetros del estado con valores predeterminados o proporcionados.
  /// - `isMapInitialized`: `false` por defecto.
  /// - `isFollowingUser`: `false` por defecto.
  /// - `showUserRoute`: `false` por defecto.
  /// - `polylines` y `markers`: Mapas vacíos si no se especifican.
  /// - `mapContext`: Nulo por defecto.
  const MapState({
    this.mapContext,
    this.isMapInitialized = false,
    this.isFollowingUser = false,
    this.showUserRoute = false,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
  })  : polylines = polylines ?? const {},
        markers = markers ?? const {};

  /// Retorna una copia del estado actual con valores opcionalmente modificados.
  ///
  /// Parámetros:
  /// - `isMapInitialized`: Indica si el mapa ha sido inicializado.
  /// - `isFollowingUser`: Indica si el mapa sigue la ubicación del usuario.
  /// - `showUserRoute`: Indica si la ruta del usuario es visible.
  /// - `polylines`: Nuevas polilíneas para el mapa.
  /// - `markers`: Nuevos marcadores para el mapa.
  /// - `mapContext`: Contexto actualizado del mapa.
  MapState copyWith({
    bool? isMapInitialized,
    bool? isFollowingUser,
    bool? showUserRoute,
    Map<String, Polyline>? polylines,
    Map<String, Marker>? markers,
    BuildContext? mapContext,
  }) =>
      MapState(
        mapContext: mapContext ?? this.mapContext,
        isMapInitialized: isMapInitialized ?? this.isMapInitialized,
        isFollowingUser: isFollowingUser ?? this.isFollowingUser,
        showUserRoute: showUserRoute ?? this.showUserRoute,
        polylines: polylines ?? this.polylines,
        markers: markers ?? this.markers,
      );

  /// Propiedades utilizadas para determinar si dos instancias de `MapState` son iguales.
  @override
  List<Object?> get props => [
        isMapInitialized,
        isFollowingUser,
        showUserRoute,
        polylines,
        markers,
        mapContext,
      ];
}
