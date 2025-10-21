import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Clase que proporciona un mensaje de carga modal.
///
/// Esta clase permite mostrar un cuadro de diálogo con un mensaje de carga y un
/// indicador de progreso circular, ideal para operaciones que requieren esperar.
class LoadingMessageHelper {
  /// Muestra un cuadro de diálogo de carga en la pantalla.
  ///
  /// - [context]: El contexto de la aplicación donde se mostrará el cuadro de diálogo.
  ///
  /// Este método presenta un mensaje modal que el usuario no puede cerrar
  /// accidentalmente mientras se realiza una operación en segundo plano.
  static void showLoadingMessage(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false, // Evita que el usuario cierre el diálogo
        builder: (context) => AlertDialog(
              title: Text(
                'loading_title'.tr(),
                textAlign: TextAlign.center, // Centrar el título
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              content: IntrinsicHeight(
                // Ajusta el tamaño del contenido al espacio necesario
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Altura mínima necesaria
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Centra verticalmente
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // Centra horizontalmente
                  children: [
                    Text(
                      'loading_message'.tr(),
                      textAlign: TextAlign.center, // Centrar el texto
                      style: TextStyle(
                        fontSize: 16, // Ajusta el tamaño del texto
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'loading_warning'.tr(),
                      textAlign: TextAlign.center, // Centrar el texto
                      style: TextStyle(
                        fontSize: 14, // Ajusta el tamaño del texto
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(
                      height: 20, // Espacio entre el texto y el indicador
                    ),
                    CircularProgressIndicator(
                      strokeWidth: 3,
                      color:
                          Theme.of(context).primaryColor, // Color del indicador
                    ),
                  ],
                ),
              ),
            ));
  }
}
