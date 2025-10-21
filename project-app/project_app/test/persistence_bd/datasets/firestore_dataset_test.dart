import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/persistence_bd/datasets/firestore_dataset.dart';
import 'package:project_app/models/models.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  late FirestoreDataset firestoreDataset;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    firestoreDataset = FirestoreDataset(userId: 'testUserId', firestore: fakeFirestore);
  });

  group('FirestoreDataset Tests', () {
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

      await firestoreDataset.saveTour(tour, 'tourName');

      final snapshot = await fakeFirestore.collection('tours').doc('tourName').get();

      expect(snapshot.exists, true);
      expect(snapshot.data()?['city'], 'Ciudad de prueba');
      expect(snapshot.data()?['mode'], 'walking');
      expect(snapshot.data()?['userPreferences'], ['nature']);
    });

    test('debería recuperar tours guardados', () async {
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

      final tours = await firestoreDataset.getSavedTours();

      expect(tours.length, 1);
      expect(tours.first.city, 'Ciudad de prueba');
      expect(tours.first.mode, 'walking');
      expect(tours.first.pois.first.name, 'POI de prueba');
    });

    test('debería eliminar un tour', () async {
      await fakeFirestore.collection('tours').doc('tourName').set({
        'userId': 'testUserId',
        'city': 'Ciudad de prueba',
      });

      await firestoreDataset.deleteTour('tourName');

      final snapshot = await fakeFirestore.collection('tours').doc('tourName').get();

      expect(snapshot.exists, false);
    });
  });
}
