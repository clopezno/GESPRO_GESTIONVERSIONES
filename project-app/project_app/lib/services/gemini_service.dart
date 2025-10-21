import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar errores
import 'package:project_app/models/models.dart';

/// Servicio para interactuar con la API de Gemini y generar puntos de interés turísticos.
///
/// Este servicio utiliza un modelo generativo de Gemini para obtener una lista de puntos
/// de interés (POIs) en formato JSON, basándose en la ciudad, preferencias del usuario,
/// tiempo máximo de trayecto y el modo de transporte.
class GeminiService {
  /// Obtiene puntos de interés turísticos basados en los parámetros proporcionados.
  ///
  /// - [city]: Nombre de la ciudad para la búsqueda de POIs.
  /// - [nPoi]: Número de puntos de interés a generar.
  /// - [userPreferences]: Lista de intereses del usuario.
  /// - [maxTime]: Tiempo máximo permitido para moverse entre POIs en minutos.
  /// - [mode]: Modo de transporte ("walking" o "cycling").
  /// - [systemInstruction]: Instrucción personalizada para ajustar el comportamiento del modelo.
  ///
  /// Retorna una lista de [PointOfInterest] o una lista vacía si ocurre algún error.
  static Future<List<PointOfInterest>> fetchGeminiData({
    required String city,
    required int nPoi,
    required List<String> userPreferences,
    required double maxTime,
    required String mode,
    required String systemInstruction,
  }) async {
    // Cargar las variables de entorno
    await dotenv.load();
    String geminiApi = dotenv.env['GEMINI_API_KEY'] ?? '';

    // Validar si la clave de API está disponible
    if (geminiApi.isEmpty) {
      log.e(
          'GeminiService: No se encontró la variable de entorno \$GEMINI_API_KEY');
      return [];
    }

    // Instrucción básica para el modelo desde internacionalización
    String baserol = 'system_instruction'.tr();

    // Configuración del modelo generativo
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: geminiApi,
      generationConfig: GenerationConfig(
        temperature: 1,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'application/json', // Respuesta en formato JSON
        responseSchema: Schema(
          SchemaType.array, // Esperamos un array de POIs
          items: Schema(
            SchemaType.object,
            properties: {
              "gps": Schema(SchemaType.array, items: Schema(SchemaType.number)),
              "name": Schema(SchemaType.string),
              "description": Schema(SchemaType.string),
            },
            requiredProperties: ['gps', 'name'], // Propiedades obligatorias
          ),
        ),
      ),
      systemInstruction: Content.system(baserol + systemInstruction),
    );

    // Configuración del mensaje al modelo
    final chat = model.startChat();
    // Mensaje al modelo usando textos internacionalizados
    final message = 'generate_poi_message'.tr(namedArgs: {
      'nPoi': nPoi.toString(),
      'city': city,
      'maxTime': maxTime.toString(),
      'mode': mode,
      'userPreferences': userPreferences.join(', '),
    });

    final content = Content.text(message);

    // Enviar mensaje al modelo y obtener respuesta
    final response = await chat.sendMessage(content);

    if (response.text == null || response.text!.isEmpty) {
      log.w('GeminiService: No se recibió respuesta del modelo.');
      return [];
    }

    // Procesar la respuesta y convertirla a objetos [PointOfInterest]
    List<PointOfInterest> pointsOfInterest = [];
    try {
      // Decodifica el JSON como una lista de mapas
      List<dynamic> jsonResponse = json.decode(response.text!);
      // Mapea los datos del JSON a una lista de objetos PointOfInterest
      pointsOfInterest = jsonResponse.map((poiJson) {
        List<dynamic> gps = poiJson['gps'];
        LatLng gpsPoint = LatLng(gps[0].toDouble(), gps[1].toDouble());

        return PointOfInterest(
          gps: gpsPoint,
          name: poiJson['name'] ?? '',
          description: poiJson['description'],
        );
      }).toList();

      log.i(
          'GeminiService: Se obtuvieron ${pointsOfInterest.length} puntos de interés en $city');
    } catch (e, stackTrace) {
      log.e('GeminiService: Error al parsear la respuesta JSON',
          error: e, stackTrace: stackTrace);
      return []; // Devuelve lista vacía si hay un error para no generar crashes.
    }

    return pointsOfInterest;
  }
}
