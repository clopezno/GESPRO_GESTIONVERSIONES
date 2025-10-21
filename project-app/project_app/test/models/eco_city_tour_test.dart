import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/eco_city_tour.dart';
import 'package:project_app/models/point_of_interest.dart';

void main() {
  group('EcoCityTour Tests', () {
    test('debería crear una instancia', () {
      // Crear una lista de puntos de interés de prueba
      final pois = [
        PointOfInterest(
          gps: const LatLng(0.0, 0.0),
          name: 'POI de prueba 1',
          description: 'Un punto de interés de prueba 1',
        ),
        PointOfInterest(
          gps: const LatLng(1.0, 1.0),
          name: 'POI de prueba 2',
          description: 'Un punto de interés de prueba 2',
        ),
      ];

      // Crear una lista de puntos de polilínea de prueba
      final polilynePoints = [
        const LatLng(0.0, 0.0),
        const LatLng(1.0, 1.0),
      ];

      // Crear una instancia de EcoCityTour
      final tour = EcoCityTour(
        city: 'Ciudad de prueba',
        pois: pois,
        mode: 'walking',
        userPreferences: ['nature', 'history'],
        polilynePoints: polilynePoints,
      );

      // Verificar que la instancia no es nula
      expect(tour, isNotNull);

      // Verificar que los valores de los atributos son los esperados
      expect(tour.city, 'Ciudad de prueba');
      expect(tour.pois.length, 2);
      expect(tour.mode, 'walking');
      expect(tour.userPreferences, ['nature', 'history']);
      expect(tour.polilynePoints.length, 2);
    });

    test('debería convertir a JSON', () {
      // Crear una lista de puntos de interés de prueba
      final pois = [
        PointOfInterest(
          gps: const LatLng(0.0, 0.0),
          name: 'POI de prueba 1',
          description: 'Un punto de interés de prueba 1',
        ),
        PointOfInterest(
          gps: const LatLng(1.0, 1.0),
          name: 'POI de prueba 2',
          description: 'Un punto de interés de prueba 2',
        ),
      ];

      // Crear una lista de puntos de polilínea de prueba
      final polilynePoints = [
        const LatLng(0.0, 0.0),
        const LatLng(1.0, 1.0),
      ];

      // Crear una instancia de EcoCityTour
      final tour = EcoCityTour(
        city: 'Ciudad de prueba',
        pois: pois,
        mode: 'walking',
        userPreferences: ['nature', 'history'],
        polilynePoints: polilynePoints,
      );

      // Convertir la instancia a JSON
      final json = tour.toJson();

      // Verificar que los valores en el JSON son los esperados
      expect(json['city'], 'Ciudad de prueba');
      expect(json['pois'].length, 2);
      expect(json['mode'], 'walking');
      expect(json['userPreferences'], ['nature', 'history']);
      expect(json['polilynePoints'].length, 2);
    });

    test('debería crear desde JSON', () {
      // JSON de prueba
      final json = {
        'city': 'Ciudad de prueba',
        'pois': [
          {
            'gps': {'latitude': 0.0, 'longitude': 0.0},
            'name': 'POI de prueba 1',
            'description': 'Un punto de interés de prueba 1',
          },
          {
            'gps': {'latitude': 1.0, 'longitude': 1.0},
            'name': 'POI de prueba 2',
            'description': 'Un punto de interés de prueba 2',
          },
        ],
        'mode': 'walking',
        'userPreferences': ['nature', 'history'],
        'polilynePoints': [
          {'latitude': 0.0, 'longitude': 0.0},
          {'latitude': 1.0, 'longitude': 1.0},
        ],
        'duration': null,
        'distance': null,
      };

      // Crear una instancia de EcoCityTour desde el JSON
      final tour = EcoCityTour.fromJson(json);

      // Verificar que los valores de los atributos son los esperados
      expect(tour.city, 'Ciudad de prueba');
      expect(tour.pois.length, 2);
      expect(tour.mode, 'walking');
      expect(tour.userPreferences, ['nature', 'history']);
      expect(tour.polilynePoints.length, 2);
    });
  });
}