import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:project_app/logger/logger.dart';

/// Servicio para interactuar con la API de Google Places.
///
/// Este servicio permite buscar información sobre lugares específicos
/// o realizar búsquedas más generales de lugares en una ciudad.
class PlacesService {
  /// Cliente HTTP para realizar solicitudes.
  final Dio _dio;

  /// Clave de la API de Google Places.
  final String _apiKey;

  /// Crea una instancia de [PlacesService].
  ///
  /// - [dio]: Cliente HTTP personalizado (opcional, útil para pruebas).
  PlacesService({Dio? dio})
      : _dio = dio ?? Dio(),
        _apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Busca un lugar específico por nombre en una ciudad.
  ///
  /// - [placeName]: Nombre del lugar que se quiere buscar.
  /// - [city]: Ciudad donde se buscará el lugar.
  ///
  /// Retorna un mapa con información del lugar o `null` si no se encuentra.
  Future<Map<String, dynamic>?> searchPlace(
      String placeName, String city) async {
    const String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json';

    if (_apiKey.isEmpty) {
      log.e('PlacesService: No se encontró la clave API de Google Places');
      return null;
    }

    try {
      log.i('PlacesService: Busca "$placeName" en la ciudad $city');

      final response = await _dio.get(url, queryParameters: {
        'query': '$placeName, $city',
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200 &&
          response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        final result = response.data['results'][0];

        log.i('PlacesService: Lugar encontrado: ${result['name']} en $city');
        return {
          'name': result['name'],
          'location': result['geometry']['location'],
          'formatted_address': result['formatted_address'],
          'rating': result['rating'],
          'user_ratings_total': result['user_ratings_total'],
          'photos': result['photos'],
          'website': result['website'],
        };
      }
    } catch (e, stackTrace) {
      log.e('PlacesService: Error durante la búsqueda del lugar "$placeName"',
          error: e, stackTrace: stackTrace);
    }
    return null;
  }

  /// Busca múltiples lugares basados en una consulta general en una ciudad.
  ///
  /// - [query]: Término de búsqueda (puede ser una categoría o descripción).
  /// - [city]: Ciudad donde se buscarán los lugares.
  ///
  /// Retorna una lista de mapas con información sobre cada lugar o una lista vacía si no se encuentran resultados.
  Future<List<Map<String, dynamic>>> searchPlaces(
      String query, String city) async {
    const String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json';

    if (_apiKey.isEmpty) {
      log.e('PlacesService: No se encontró la clave API de Google Places');
      return [];
    }

    try {
      log.i('PlacesService: Busca lugares para "$query" en la ciudad $city');

      final response = await _dio.get(url, queryParameters: {
        'query': '$query, $city',
        'key': _apiKey,
        'language': 'es',
      });

      if (response.statusCode == 200 &&
          response.data['results'] != null &&
          response.data['results'].isNotEmpty) {
        final results = response.data['results'] as List;

        return results.map((result) {
          return {
            'name': result['name'],
            'location': result['geometry']['location'],
            'formatted_address': result['formatted_address'],
            'rating': result['rating'],
            'user_ratings_total': result['user_ratings_total'],
            'photos': result['photos'],
            'website': result['website'],
          };
        }).toList();
      }
    } catch (e, stackTrace) {
      log.e('PlacesService: Error durante la búsqueda de lugares "$query"',
          error: e, stackTrace: stackTrace);
    }
    return [];
  }
}
