part of 'tour_bloc.dart';

/// Representa el estado del `TourBloc`.
///
/// Este estado contiene información sobre el tour actual, los tours guardados, 
/// el estado de carga, posibles errores, y si el usuario se ha unido al tour.
class TourState extends Equatable {
  /// El tour actual que se está gestionando.
  final EcoCityTour? ecoCityTour;

  /// Lista de tours guardados.
  final List<EcoCityTour> savedTours;

  /// Indica si el estado está en proceso de carga.
  final bool isLoading;

  /// Indica si hubo un error al manejar algún evento.
  final bool hasError;

  /// Indica si el usuario se ha unido al tour actual.
  final bool isJoined;

  /// Constructor de `TourState`.
  ///
  /// - `ecoCityTour`: Tour actual o `null` si no hay ninguno.
  /// - `savedTours`: Lista de tours guardados (por defecto vacía).
  /// - `isLoading`: Estado de carga (por defecto `false`).
  /// - `hasError`: Indica si hubo errores (por defecto `false`).
  /// - `isJoined`: Indica si el usuario está unido al tour (por defecto `false`).
  const TourState({
    this.ecoCityTour,
    this.savedTours = const [],
    this.isLoading = false,
    this.hasError = false,
    this.isJoined = false,
  });

  /// Crea una copia del estado actual con valores opcionalmente modificados.
  ///
  /// - Si un valor no se proporciona, se conservará el valor actual del estado.
  ///
  /// Ejemplo de uso:
  /// ```dart
  /// final newState = currentState.copyWith(isLoading: true);
  /// ```
  TourState copyWith({
    EcoCityTour? ecoCityTour,
    List<EcoCityTour>? savedTours,
    bool? isLoading,
    bool? hasError,
    bool? isJoined,
  }) {
    return TourState(
      savedTours: savedTours ?? this.savedTours,
      ecoCityTour: ecoCityTour ?? this.ecoCityTour,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      isJoined: isJoined ?? this.isJoined,
    );
  }

  /// Devuelve un nuevo estado con `ecoCityTour` configurado como `null`.
  ///
  /// Se utiliza para limpiar el tour actual sin modificar otros valores del estado.
  TourState copyWithNull() {
    return const TourState(
      ecoCityTour: null,
    );
  }

  /// Proporciona una lista de propiedades para facilitar la comparación de instancias.
  ///
  /// Esto permite a `Equatable` determinar si dos estados son iguales.
  @override
  List<Object?> get props => [ecoCityTour, savedTours, isLoading, hasError, isJoined];
}
