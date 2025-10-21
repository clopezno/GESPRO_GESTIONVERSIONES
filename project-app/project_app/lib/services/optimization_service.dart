import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/models/models.dart';

/// Servicio para optimizar rutas turísticas utilizando la API de Google Directions.
///
/// Este servicio genera rutas optimizadas entre múltiples puntos de interés (POIs),
/// teniendo en cuenta el modo de transporte y devolviendo un [EcoCityTour] que incluye
/// distancia, duración y los puntos necesarios para dibujar la ruta.
class OptimizationService {
  /// Cliente HTTP para realizar solicitudes.
  final Dio _dioOptimization;

  /// Constructor del servicio, con la opción de inyectar un cliente [Dio] personalizado.
  ///
  /// Ideal para pruebas unitarias, donde un cliente simulado puede reemplazar al real.
  OptimizationService({Dio? dio}) : _dioOptimization = dio ?? Dio();

  /// Solicita una ruta optimizada entre múltiples POIs.
  ///
  /// - [pois]: Lista de puntos de interés a incluir en la ruta.
  /// - [mode]: Modo de transporte ("walking", "driving", etc.).
  /// - [city]: Nombre de la ciudad para fines descriptivos.
  /// - [userPreferences]: Preferencias del usuario (se incluyen pero no afectan la optimización).
  ///
  /// Retorna un objeto [EcoCityTour] con los detalles de la ruta optimizada.
  /// Lanza [AppException] si no se encuentra la clave API o si no se pueden obtener rutas.
  Future<EcoCityTour> getOptimizedRoute({
    required List<PointOfInterest> pois,
    required String mode,
    required String city,
    required List<String> userPreferences,
  }) async {
    // Cargar la clave API desde las variables de entorno
    String apiKey = dotenv.env['GOOGLE_DIRECTIONS_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      log.e(
          'OptimizationService: No se encontró la clave API de Google Directions');
      throw AppException("Google API Key not found");
    }

    // Convertir los POIs en coordenadas LatLng
    final List<LatLng> points = pois.map((poi) => poi.gps).toList();

    // Formatear las coordenadas para la solicitud a la API
    final coorsString =
        points.map((point) => '${point.latitude},${point.longitude}').join('|');

    const url = 'https://maps.googleapis.com/maps/api/directions/json';

    try {
      log.i(
          'OptimizationService: Solicitando optimización de ruta para $city con modo $mode y ${pois.length} POIs');

      // Realizar la solicitud a la API de Google Directions
      final response = await _dioOptimization.get(url, queryParameters: {
        'origin': '${points.first.latitude},${points.first.longitude}',
        'destination': '${points.last.latitude},${points.last.longitude}',
        'waypoints': 'optimize:true|$coorsString',
        'mode': mode,
        'key': apiKey,
      });

      log.d('Response data: ${response.data}');

      // Verifica si se encontraron rutas en la respuesta
      if (response.data['routes'] == null || response.data['routes'].isEmpty) {
        log.w('OptimizationService: No se encontraron rutas en la respuesta');
        throw AppException("No routes found in response");
      }

      // Extrae y decodifica la polilínea de la ruta
      final route = response.data['routes'][0];
      final polyline = route['overview_polyline']['points'];
      final polilynePoints = decodePolyline(polyline, accuracyExponent: 5)
          .map((coor) => LatLng(coor[0].toDouble(), coor[1].toDouble()))
          .toList();

      // Calcula distancia y duración total de las rutas (legs)
      final double distance = route['legs']
          .fold(0, (sum, leg) => sum + leg['distance']['value'])
          .toDouble();
      final double duration = route['legs']
          .fold(0, (sum, leg) => sum + leg['duration']['value'])
          .toDouble();

      log.d(
          'OptimizationService: Ruta optimizada recibida. Distancia total: $distance m, Duración total: $duration segundos.');

      // Crea y retorna el objeto EcoCityTour
      final ecoCityTour = EcoCityTour(
        city: city,
        pois: pois,
        mode: mode,
        userPreferences: userPreferences,
        duration: duration,
        distance: distance,
        polilynePoints: polilynePoints,
      );

      // Validaciones adicionales
      if (distance < 0 || duration < 0) {
        log.e(
            'OptimizationService: Valores de distancia o duración no válidos');
        throw AppException("Invalid distance or duration values");
      }
      if (distance > 1000000) {
        // Por ejemplo, 1000 km como límite razonable
        log.w('OptimizationService: Distancia mayor al rango esperado');
      }
      if (duration > 86400) {
        // Por ejemplo, 24 horas como límite razonable
        log.w('OptimizationService: Duración mayor al rango esperado');
      }
      return ecoCityTour;
    } on DioException catch (e) {
      log.e(
          'OptimizationService: Error durante la solicitud a la API de Google Directions',
          error: e);
      // Devuelve un EcoCityTour vacío con información básica
      return EcoCityTour(
        city: city,
        pois: pois,
        mode: mode,
        userPreferences: userPreferences,
        duration: 0,
        distance: 0,
        polilynePoints: [],
      );
    } catch (e, stackTrace) { // Captura cualquier otro error
      log.e(
          'OptimizationService: Error desconocido durante la optimización de la ruta',
          error: e,
          stackTrace: stackTrace);
      return EcoCityTour(
        city: city,
        pois: pois,
        mode: mode,
        userPreferences: userPreferences,
        duration: 0,
        distance: 0,
        polilynePoints: [],
      );
    }
  }
}
