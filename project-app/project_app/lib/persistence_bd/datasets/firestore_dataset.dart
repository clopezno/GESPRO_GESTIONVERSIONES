import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';

/// Clase para interactuar con la colección de tours en Firestore.
///
/// Proporciona métodos para guardar, recuperar y eliminar tours asociados a un usuario.
class FirestoreDataset {
  /// Instancia de Firebase Firestore para interactuar con la base de datos.
  final FirebaseFirestore firestore;

  /// ID del usuario asociado a las operaciones de Firestore.
  final String? userId;

  /// Crea una instancia de [FirestoreDataset].
  ///
  /// - [userId]: ID del usuario (obligatorio).
  /// - [firestore]: Instancia de FirebaseFirestore (opcional, útil para pruebas).
  FirestoreDataset({
    required this.userId,
    FirebaseFirestore? firestore,
  }) : firestore = firestore ?? FirebaseFirestore.instance;

  /// Guarda un tour en Firestore bajo un nombre específico.
  ///
  /// - [tour]: Objeto [EcoCityTour] que se desea guardar.
  /// - [tourName]: Nombre con el cual se guardará el tour.
  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    try {
      // Construye los datos del tour en formato compatible con Firestore.
      final tourData = {
        'userId': userId,
        'city': tour.city,
        'mode': tour.mode,
        'userPreferences': tour.userPreferences,
        'duration': tour.duration,
        'distance': tour.distance,
        'polilynePoints': tour.polilynePoints
            .map((point) => {'lat': point.latitude, 'lng': point.longitude})
            .toList(),
        'pois': tour.pois
            .map((poi) => {
                  'name': poi.name,
                  'gps': {'lat': poi.gps.latitude, 'lng': poi.gps.longitude},
                  'description': poi.description,
                  'url': poi.url,
                  'imageUrl': poi.imageUrl,
                  'rating': poi.rating,
                  'address': poi.address,
                  'userRatingsTotal': poi.userRatingsTotal,
                })
            .toList(),
      };

      log.d('Intentando guardar el tour con nombre: $tourName');
      await firestore.collection('tours').doc(tourName).set(tourData);
      log.i('Tour guardado con éxito: $tourName');
    } catch (e) {
      log.e('Error al guardar el tour: $e');
    }
  }

  /// Recupera todos los tours guardados para el usuario actual.
  ///
  /// Retorna una lista de [EcoCityTour].
  Future<List<EcoCityTour>> getSavedTours() async {
    try {
      final querySnapshot = await firestore
          .collection('tours')
          .where('userId', isEqualTo: userId)
          .get();

      log.i('Tours guardados recuperados: ${querySnapshot.docs.length} tours');

      return querySnapshot.docs.map((doc) {
        return EcoCityTour.fromFirestore(doc);
      }).toList();
    } catch (e) {
      log.e('Error al recuperar los tours guardados: $e');
      return [];
    }
  }

  /// Elimina un tour específico por su nombre en Firestore.
  ///
  /// - [tourName]: Nombre del tour que se desea eliminar.
  Future<void> deleteTour(String tourName) async {
    try {
      log.d('Intentando eliminar el tour con nombre: $tourName');
      await firestore.collection('tours').doc(tourName).delete();
      log.i('Tour eliminado con éxito: $tourName');
    } catch (e) {
      log.e('Error al eliminar el tour: $e');
    }
  }

  /// Recupera un tour específico por su ID de documento en Firestore.
  ///
  /// - [documentId]: ID del documento a buscar.
  ///
  /// Retorna un [DocumentSnapshot] con los datos del tour.
  Future<DocumentSnapshot> getTourById(String documentId) async {
    return await firestore.collection('tours').doc(documentId).get();
  }
}
