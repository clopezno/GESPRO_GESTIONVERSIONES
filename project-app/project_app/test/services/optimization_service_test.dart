import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/exceptions/app_exception.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/services/optimization_service.dart';

class MockDio extends Mock implements Dio {}

void main() {
  late OptimizationService optimizationService;
  late MockDio mockDio;

  setUpAll(() async {
    registerFallbackValue(
      Response(
        requestOptions: RequestOptions(path: ''),
        data: {},
      ),
    );
    registerFallbackValue(RequestOptions(path: ''));
  });

  setUp(() async {
    dotenv.testLoad(fileInput: '''GOOGLE_DIRECTIONS_API_KEY=test_key''');
    mockDio = MockDio();
    optimizationService = OptimizationService(dio: mockDio);
  });

  tearDown(() async {
    dotenv.clean();
  });

  group('OptimizationService - getOptimizedRoute', () {
    test('Devuelve un EcoCityTour cuando la API responde correctamente',
        () async {
      final pois = [
        PointOfInterest(gps: const LatLng(37.7749, -122.4194), name: "Place A"),
        PointOfInterest(gps: const LatLng(37.7849, -122.4294), name: "Place B"),
      ];

      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'routes': [
                    {
                      'overview_polyline': {'points': 'abcd1234'},
                      'legs': [
                        {
                          'distance': {'value': 1000},
                          'duration': {'value': 600}
                        },
                        {
                          'distance': {'value': 1500},
                          'duration': {'value': 900}
                        },
                      ]
                    }
                  ]
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await optimizationService.getOptimizedRoute(
        pois: pois,
        mode: 'walking',
        city: 'San Francisco',
        userPreferences: ['Nature'],
      );

      expect(result, isA<EcoCityTour>());
      expect(result.distance, 2500);
      expect(result.duration, 1500);
      expect(result.polilynePoints, isNotEmpty);
    });

    test('Lanza AppException cuando no se encuentra la clave API', () async {
      dotenv.clean(); // Simula la ausencia de la clave API

      expect(
        () async => await optimizationService.getOptimizedRoute(
          pois: [],
          mode: 'walking',
          city: 'San Francisco',
          userPreferences: [],
        ),
        throwsA(isA<AppException>()), // Verifica que se lanza AppException
      );
    });

    test(
        'Devuelve un EcoCityTour vacío si no se encuentran rutas en la respuesta',
        () async {
      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {'routes': []},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      final result = await optimizationService.getOptimizedRoute(
        pois: [
          PointOfInterest(
              gps: const LatLng(37.7749, -122.4194), name: "Place A")
        ],
        mode: 'driving',
        city: 'San Francisco',
        userPreferences: [],
      );

      expect(result.distance, 0);
      expect(result.duration, 0);
      expect(result.polilynePoints, isEmpty);
    });

    test('Devuelve un EcoCityTour vacío si ocurre un error de red', () async {
      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Error de red',
      ));

      final result = await optimizationService.getOptimizedRoute(
        pois: [
          PointOfInterest(
              gps: const LatLng(37.7749, -122.4194), name: "Place A")
        ],
        mode: 'bicycling',
        city: 'San Francisco',
        userPreferences: [],
      );

      expect(result.distance, 0);
      expect(result.duration, 0);
      expect(result.polilynePoints, isEmpty);
    });

    test('Devuelve un EcoCityTour vacío para errores desconocidos', () async {
      when(() => mockDio.get(any(),
              queryParameters: any(named: 'queryParameters')))
          .thenThrow(Exception('Unexpected error'));

      final result = await optimizationService.getOptimizedRoute(
        pois: [
          PointOfInterest(
              gps: const LatLng(37.7749, -122.4194), name: "Place A")
        ],
        mode: 'walking',
        city: 'San Francisco',
        userPreferences: [],
      );

      expect(result.distance, 0);
      expect(result.duration, 0);
      expect(result.polilynePoints, isEmpty);
    });
  });
}
