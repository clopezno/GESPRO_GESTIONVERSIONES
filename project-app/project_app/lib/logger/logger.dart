import 'package:logger/logger.dart';

/// Instancia global del logger para registrar mensajes en toda la aplicación.
///
/// Configura el logger con un [PrettyPrinter] que:
/// - Compacta los logs configurando `methodCount` en 0.
/// - Muestra hasta 8 niveles de pila en caso de error.
/// - Limita la longitud de las líneas a 120 caracteres.
/// - Incluye colores y emojis para mejorar la legibilidad.
/// - Desactiva el formato de fecha y hora.
final Logger log = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // Muestra 0 niveles de pila para compactar los logs
    errorMethodCount: 8, // Muestra hasta 8 niveles de pila en caso de error
    lineLength: 120, // Longitud máxima de las líneas
    colors: true, // Activa colores en los logs
    printEmojis: true, // Incluye emojis para mejorar la legibilidad
    dateTimeFormat: DateTimeFormat.none, // Desactiva la impresión de fechas
  ),
);
