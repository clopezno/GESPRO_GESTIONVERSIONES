import 'package:project_app/logger/logger.dart'; // Importar logger para registrar errores

/// Clase base para manejar excepciones personalizadas en la aplicación.
///
/// Proporciona un sistema uniforme para manejar y registrar errores,
/// incluyendo un mensaje, un prefijo para identificar el tipo de error,
/// y una URL opcional asociada al error.
class AppException implements Exception {
  /// Mensaje descriptivo del error.
  final String message;

  /// Prefijo para categorizar el tipo de error (opcional).
  final String? prefix;

  /// URL asociada al error, si está disponible (opcional).
  final String? url;

  /// Crea una excepción personalizada con un mensaje, prefijo y URL opcional.
  AppException(this.message, {this.prefix, this.url}) {
    log.e('$prefix$message${url != null ? ' (URL: $url)' : ''}');
  }

  /// Retorna una representación en texto de la excepción.
  @override
  String toString() {
    return "$prefix$message${url != null ? ' (URL: $url)' : ''}";
  }
}

/// Excepción para errores de comunicación o red.
///
/// Indica que hubo un problema al intentar comunicarse con un servidor o servicio remoto.
class FetchDataException extends AppException {
  /// Crea una excepción de tipo "Error en la comunicación".
  FetchDataException(super.message, {super.url})
      : super(prefix: "Error en la comunicación: ");
}

/// Excepción para solicitudes incorrectas (400 Bad Request).
///
/// Indica que el cliente envió una solicitud malformada o no válida.
class BadRequestException extends AppException {
  /// Crea una excepción de tipo "Solicitud incorrecta".
  BadRequestException(super.message, {super.url})
      : super(prefix: "Solicitud incorrecta: ");
}

/// Excepción para errores de autorización (401 Unauthorized).
///
/// Indica que el cliente no está autorizado para acceder al recurso solicitado.
class UnauthorizedException extends AppException {
  /// Crea una excepción de tipo "No autorizado".
  UnauthorizedException(super.message, {super.url})
      : super(prefix: "No autorizado: ");
}

/// Excepción para entradas no válidas.
///
/// Indica que se proporcionaron datos incorrectos o no aceptables al sistema.
class InvalidInputException extends AppException {
  /// Crea una excepción de tipo "Entrada no válida".
  InvalidInputException(super.message, {super.url})
      : super(prefix: "Entrada no válida: ");
}
