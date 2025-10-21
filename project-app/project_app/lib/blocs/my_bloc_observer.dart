import 'package:bloc/bloc.dart';
import 'package:project_app/logger/logger.dart';

/// Observador personalizado para los eventos del Bloc.
///
/// Este observador utiliza un logger para registrar los eventos de creación,
/// eventos, cambios, transiciones, errores y cierre de los Blocs.
class MyBlocObserver extends BlocObserver {
  /// Método llamado cuando se crea un Bloc.
  ///
  /// Registra el tipo de Bloc creado.
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log.i('onCreate -- ${bloc.runtimeType}');
  }

  /// Método llamado cuando un evento es añadido a un Bloc.
  ///
  /// Registra el tipo de Bloc y el evento añadido.
  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    log.d('onEvent -- ${bloc.runtimeType}, $event');
  }

  /// Método llamado cuando el estado de un Bloc cambia.
  ///
  /// Registra el tipo de Bloc y el cambio de estado.
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log.d('onChange -- ${bloc.runtimeType}, $change');
  }

  /// Método llamado cuando ocurre una transición en un Bloc.
  ///
  /// Registra el tipo de Bloc y la transición.
  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log.d('onTransition -- ${bloc.runtimeType}, $transition');
  }

  /// Método llamado cuando ocurre un error en un Bloc.
  ///
  /// Registra el tipo de Bloc, el error y el stack trace.
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.e('onError -- ${bloc.runtimeType}, $error',
        error: error, stackTrace: stackTrace);
    super.onError(bloc, error, stackTrace);
  }

  /// Método llamado cuando un Bloc es cerrado.
  ///
  /// Registra el tipo de Bloc cerrado.
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log.i('onClose -- ${bloc.runtimeType}');
  }
}
