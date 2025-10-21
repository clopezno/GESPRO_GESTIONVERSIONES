import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/persistence_bd/datasets/firestore_dataset.dart';
import 'package:project_app/models/eco_city_tour.dart';
import 'package:project_app/models/point_of_interest.dart';
import 'package:project_app/persistence_bd/repositories/eco_city_tour_repository.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  late EcoCityTourRepository repository;
  late FirestoreDataset dataset;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    dataset = FirestoreDataset(userId: 'testUserId', firestore: fakeFirestore);
    repository = EcoCityTourRepository(dataset);
  });

  group('EcoCityTourRepository Tests', () {
    test('debería guardar un tour', () async {
      final tour = EcoCityTour(
        city: 'Ciudad de prueba',
        pois: [
          PointOfInterest(
            gps: const LatLng(0.0, 0.0),
            name: 'POI de prueba',
            description: 'Un punto de interés de prueba',
            url: 'http://example.com',
            imageUrl: 'http://image.com',
            rating: 4.5,
            address: 'Dirección de prueba',
            userRatingsTotal: 100,
          ),
        ],
        mode: 'walking',
        userPreferences: ['nature'],
        duration: 120,
        distance: 5.0,
        polilynePoints: [const LatLng(0.0, 0.0)],
      );

      await repository.saveTour(tour, 'tourName');

      // Verificar que el tour fue guardado en Firestore
      final snapshot = await fakeFirestore.collection('tours').doc('tourName').get();

      expect(snapshot.exists, true);
      expect(snapshot.data()?['city'], 'Ciudad de prueba');
      expect(snapshot.data()?['mode'], 'walking');
      expect(snapshot.data()?['userPreferences'], ['nature']);
    });

    test('debería recuperar tours guardados', () async {
      // Agregar un tour de prueba directamente en Firestore simulado
      await fakeFirestore.collection('tours').doc('tourName').set({
        'userId': 'testUserId',
        'city': 'Ciudad de prueba',
        'pois': [
          {
            'gps': {'lat': 0.0, 'lng': 0.0},
            'name': 'POI de prueba',
            'description': 'Un punto de interés de prueba',
            'url': 'http://example.com',
            'imageUrl': 'http://image.com',
            'rating': 4.5,
            'address': 'Dirección de prueba',
            'userRatingsTotal': 100,
          },
        ],
        'mode': 'walking',
        'userPreferences': ['nature'],
        'duration': 120,
        'distance': 5.0,
        'polilynePoints': [
          {'lat': 0.0, 'lng': 0.0},
        ],
      });

      final tours = await repository.getSavedTours();

      expect(tours.length, 1);
      expect(tours.first.city, 'Ciudad de prueba');
      expect(tours.first.mode, 'walking');
      expect(tours.first.pois.first.name, 'POI de prueba');
    });

    test('debería eliminar un tour', () async {
      // Guardar un tour de prueba en Firestore simulado
      await fakeFirestore.collection('tours').doc('tourName').set({
        'userId': 'testUserId',
        'city': 'Ciudad de prueba',
      });

      // Eliminar el tour usando el repositorio
      await repository.deleteTour('tourName');

      // Verificar que el documento no existe
      final snapshot = await fakeFirestore.collection('tours').doc('tourName').get();

      expect(snapshot.exists, false);
    });

    test('debería recuperar un tour por ID', () async {
      // Guardar un tour de prueba en Firestore simulado
      await fakeFirestore.collection('tours').doc('tourName').set({
        'userId': 'testUserId',
        'city': 'Ciudad de prueba',
        'pois': [
          {
            'gps': {'lat': 0.0, 'lng': 0.0},
            'name': 'POI de prueba',
            'description': 'Un punto de interés de prueba',
          },
        ],
        'mode': 'walking',
        'userPreferences': ['nature'],
        'duration': 120,
        'distance': 5.0,
        'polilynePoints': [
          {'lat': 0.0, 'lng': 0.0},
        ],
      });

      final tour = await repository.getTourById('tourName');

      expect(tour, isNotNull);
      expect(tour?.city, 'Ciudad de prueba');
      expect(tour?.mode, 'walking');
      expect(tour?.pois.first.name, 'POI de prueba');
    });

    test('debería devolver null si el tour con ID no existe', () async {
      final tour = await repository.getTourById('invalidTourId');
      expect(tour, isNull);
    });
  });
}
