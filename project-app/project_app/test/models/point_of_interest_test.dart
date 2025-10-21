import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/point_of_interest.dart';

void main() {
  group('PointOfInterest Tests', () {
    test('debería crear una instancia', () {
      // Crear una instancia de PointOfInterest
      final poi = PointOfInterest(
        gps: const LatLng(0.0, 0.0),
        name: 'POI de prueba',
        description: 'Un punto de interés de prueba',
      );

      // Verificar que la instancia no es nula
      expect(poi, isNotNull);

      // Verificar que los valores de los atributos son los esperados
      expect(poi.name, 'POI de prueba');
      expect(poi.description, 'Un punto de interés de prueba');
      expect(poi.gps.latitude, 0.0);
      expect(poi.gps.longitude, 0.0);
    });

    test('debería convertir a JSON', () {
      // Crear una instancia de PointOfInterest
      final poi = PointOfInterest(
        gps: const LatLng(0.0, 0.0),
        name: 'POI de prueba',
        description: 'Un punto de interés de prueba',
      );

      // Convertir la instancia a JSON
      final json = poi.toJson();

      // Verificar que los valores en el JSON son los esperados
      expect(json['name'], 'POI de prueba');
      expect(json['description'], 'Un punto de interés de prueba');
      expect(json['gps']['latitude'], 0.0);
      expect(json['gps']['longitude'], 0.0);
    });

    test('debería crear desde JSON', () {
      // JSON de prueba
      final json = {
        'gps': {'latitude': 0.0, 'longitude': 0.0},
        'name': 'POI de prueba',
        'description': 'Un punto de interés de prueba',
      };

      // Crear una instancia de PointOfInterest desde el JSON
      final poi = PointOfInterest.fromJson(json);

      // Verificar que los valores de los atributos son los esperados
      expect(poi.name, 'POI de prueba');
      expect(poi.description, 'Un punto de interés de prueba');
      expect(poi.gps.latitude, 0.0);
      expect(poi.gps.longitude, 0.0);
    });
  });
}