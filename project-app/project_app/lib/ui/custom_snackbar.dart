import 'package:flutter/material.dart';

/// Un widget personalizado que extiende [SnackBar] para mostrar mensajes en la aplicación.
///
/// Proporciona una implementación predeterminada con un botón de acción opcional,
/// texto personalizado, y una duración configurable.
class CustomSnackbar extends SnackBar {
  /// Crea una instancia de [CustomSnackbar].
  ///
  /// - [msg] es el mensaje que se mostrará en el cuerpo del SnackBar.
  /// - [btnLabel] es el texto del botón de acción (por defecto, 'Aceptar').
  /// - [duration] define cuánto tiempo estará visible el SnackBar (por defecto, 2 segundos).
  /// - [onPressed] es el callback que se ejecuta al presionar el botón de acción.
  CustomSnackbar({
    super.key,
    required String msg,
    String btnLabel = 'Aceptar',
    super.duration = const Duration(seconds: 2),
    VoidCallback? onPressed,
  }) : super(
          content: Text(msg), // Duración personalizada
          action: SnackBarAction(
            label: btnLabel, // Etiqueta del botón de acción
            onPressed: () {
              // Ejecutar el callback opcional si está definido
              if (onPressed != null) {
                onPressed();
              }
            },
          ),
        );

  /// Muestra un [SnackBar] con un mensaje simple.
  ///
  /// - [context] es el contexto en el que se mostrará el SnackBar.
  /// - [message] es el texto que se mostrará en el cuerpo del SnackBar.
  ///
  /// Este método utiliza el [ScaffoldMessenger] para gestionar la visibilidad del SnackBar.
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
