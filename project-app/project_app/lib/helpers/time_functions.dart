import 'package:easy_localization/easy_localization.dart';

/// Convierte una duración en segundos a un formato de horas y minutos.
///
/// - [seconds]: La duración en segundos.
///
/// Retorna una cadena que indica la duración en horas y minutos.
/// Por ejemplo, `3600` retornará "1 hora", y `4500` retornará "1 hora 15 minutos".
String formatDuration(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds % 3600) ~/ 60;

  if (hours > 0) {
    return '$hours ${hours == 1 ? 'hour'.tr() : 'hours'.tr()} '
        '$minutes ${'minutes'.tr()}';
  } else {
    return '$minutes ${'minutes'.tr()}';
  }
}

/// Convierte una distancia en metros a un formato legible en metros o kilómetros.
///
/// - [meters]: La distancia en metros.
///
/// Retorna una cadena que indica la distancia en metros o kilómetros.
/// Por ejemplo, `1500` retornará "1.5 km", y `500` retornará "500 m".
String formatDistance(double meters) {
  if (meters >= 1000) {
    double kilometers = meters / 1000;
    return '${kilometers.toStringAsFixed(1)} km.';
  } else {
    return '${meters.round()} m.';
  }
}

/// Convierte una duración en minutos a un formato de horas y minutos.
///
/// - [minutes]: La duración en minutos.
///
/// Retorna una cadena que indica la duración en un formato legible.
/// Por ejemplo, `90` retornará "1 hora 30m", y `45` retornará "45m".
String formatTime(double minutes) {
  final hours = minutes ~/ 60;
  final mins = minutes % 60;

  if (hours == 0) {
    return '${mins.round()}m'; // Solo minutos si es menos de una hora
  } else if (hours == 1 && mins == 0) {
    return '1 ${'hour'.tr()}'; // Exactamente una hora
  } else if (hours == 1) {
    return '1 ${'hour'.tr()} ${mins.round()}m'; // Una hora con minutos
  } else if (mins == 0) {
    return '$hours ${'hours'.tr()}'; // Solo horas si no hay minutos
  } else {
    return '$hours ${'hours'.tr()} ${mins.round()}m'; // Horas y minutos
  }
}
