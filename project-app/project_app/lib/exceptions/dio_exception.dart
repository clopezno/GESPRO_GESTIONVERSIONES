import 'app_exception.dart';
import 'package:dio/dio.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

/// Clase que maneja las excepciones generadas por Dio.
///
/// Proporciona métodos para traducir errores de Dio en excepciones específicas
/// de la aplicación, facilitando su manejo y registro.
class DioExceptions {
  /// Maneja un error generado por Dio y lo convierte en una excepción personalizada.
  ///
  /// - [error]: Excepción generada por Dio.
  /// - [url]: URL asociada a la solicitud, si está disponible.
  ///
  /// Retorna una subclase de [AppException] según el tipo de error.
  static AppException handleDioError(DioException error, {String? url}) {
    // Log del error recibido por Dio antes de procesarlo
    log.e(
        'DioExceptions: Error de tipo ${error.type}, mensaje: ${error.message}, URL: $url');

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return FetchDataException("Tiempo de conexión agotado", url: url);
      case DioExceptionType.sendTimeout:
        return FetchDataException("Tiempo de envío agotado", url: url);
      case DioExceptionType.receiveTimeout:
        return FetchDataException("Tiempo de recepción agotado", url: url);
      case DioExceptionType.badResponse:
        return _handleHttpResponseError(error, url: url);
      case DioExceptionType.cancel:
        return AppException("La solicitud al servidor fue cancelada", url: url);
      case DioExceptionType.unknown:
        return FetchDataException("Sin conexión a Internet", url: url);
      default:
        return AppException("Ocurrió un error inesperado", url: url);
    }
  }

  /// Maneja errores de respuesta HTTP específicos.
  ///
  /// - [error]: Excepción generada por Dio con un código de estado HTTP.
  /// - [url]: URL asociada a la solicitud, si está disponible.
  ///
  /// Retorna una subclase de [AppException] según el código de estado.
  static AppException _handleHttpResponseError(DioException error,
      {String? url}) {
    int? statusCode = error.response?.statusCode;

    // Log del estado HTTP y la URL en caso de error de respuesta
    log.e('DioExceptions: Error HTTP $statusCode para la URL: $url');

    switch (statusCode) {
      case 400:
        return BadRequestException("Solicitud incorrecta", url: url);
      case 401:
        return UnauthorizedException("No autorizado", url: url);
      case 403:
        return AppException("Prohibido", url: url);
      case 404:
        return AppException("Recurso no encontrado", url: url);
      case 500:
        return AppException("Error interno del servidor", url: url);
      default:
        return AppException(
          "Código de estado inválido recibido: $statusCode",
          url: url,
        );
    }
  }
}
