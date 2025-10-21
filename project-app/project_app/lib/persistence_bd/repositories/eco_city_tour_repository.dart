import 'package:project_app/persistence_bd/datasets/firestore_dataset.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/logger/logger.dart';

/// Repositorio para gestionar los tours de EcoCity en Firestore.
///
/// Este repositorio actúa como intermediario entre la aplicación y el dataset de Firestore,
/// proporcionando métodos para guardar, recuperar y eliminar tours.
class EcoCityTourRepository {
  /// Dataset que interactúa directamente con Firestore.
  final FirestoreDataset _dataset;

  /// Crea una instancia de [EcoCityTourRepository].
  ///
  /// - [_dataset]: Dataset de Firestore que se utiliza para las operaciones.
  EcoCityTourRepository(this._dataset);

  /// Guarda un tour en Firestore.
  ///
  /// - [tour]: Objeto [EcoCityTour] que se quiere guardar.
  /// - [tourName]: Nombre del tour bajo el cual se almacenará.
  Future<void> saveTour(EcoCityTour tour, String tourName) async {
    log.d('Intentando guardar el tour: $tourName');
    await _dataset.saveTour(tour, tourName);
  }

  /// Recupera todos los tours guardados desde Firestore.
  ///
  /// Retorna una lista de [EcoCityTour].
  Future<List<EcoCityTour>> getSavedTours() async {
    log.d('Intentando recuperar los tours guardados');
    return await _dataset.getSavedTours();
  }

  /// Elimina un tour de Firestore por su nombre.
  ///
  /// - [tourName]: Nombre del tour que se desea eliminar.
  Future<void> deleteTour(String tourName) async {
    log.d('Intentando eliminar el tour: $tourName');
    await _dataset.deleteTour(tourName);
  }

  /// Recupera un tour desde Firestore utilizando su ID de documento.
  ///
  /// - [documentId]: ID del documento en Firestore.
  ///
  /// Retorna un objeto [EcoCityTour] si el documento existe, o `null` si no se encuentra.
  Future<EcoCityTour?> getTourById(String documentId) async {
    try {
      final docSnapshot = await _dataset.getTourById(documentId);
      if (docSnapshot.exists) {
        return EcoCityTour.fromFirestore(docSnapshot);
      }
      log.w('El documento con ID $documentId no existe en Firestore.');
      return null;
    } catch (e) {
      log.e('Error al obtener el tour con ID $documentId: $e');
      return null;
    }
  }
}
