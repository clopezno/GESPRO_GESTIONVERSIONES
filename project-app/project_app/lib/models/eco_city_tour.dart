import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/models/point_of_interest.dart';

/// Modelo que representa un EcoCityTour.
///
/// Contiene información sobre la ciudad, puntos de interés (POIs), modo de transporte,
/// preferencias del usuario, duración, distancia y los puntos necesarios para trazar
/// la ruta en el mapa.
class EcoCityTour {
  /// Nombre de la ciudad asociada al tour.
  final String city;

  /// Lista de puntos de interés incluidos en el tour.
  final List<PointOfInterest> pois;

  /// Modo de transporte utilizado (por ejemplo, "walking" o "cycling").
  final String mode;

  /// Lista de preferencias del usuario para personalizar el tour.
  final List<String> userPreferences;

  /// Duración estimada del tour en segundos (opcional).
  final double? duration;

  /// Distancia total del tour en metros (opcional).
  final double? distance;

  /// Puntos para trazar la ruta en el mapa.
  final List<LatLng> polilynePoints;

  /// ID del documento en Firestore (opcional).
  final String? documentId;

  /// Crea una instancia de [EcoCityTour].
  ///
  /// - [city]: Nombre de la ciudad (obligatorio).
  /// - [pois]: Lista de puntos de interés (obligatorio).
  /// - [mode]: Modo de transporte (obligatorio).
  /// - [userPreferences]: Preferencias del usuario (obligatorio).
  /// - [polilynePoints]: Puntos para la polilínea de la ruta (obligatorio).
  /// - [duration]: Duración estimada del tour (opcional).
  /// - [distance]: Distancia total del tour (opcional).
  /// - [documentId]: ID del documento en Firestore (opcional).
  EcoCityTour({
    this.duration,
    this.distance,
    required this.polilynePoints,
    required this.city,
    required this.pois,
    required this.mode,
    required this.userPreferences,
    this.documentId,
  });

  /// Convierte una instancia de [EcoCityTour] a un mapa JSON.
  ///
  /// Retorna un mapa con todos los atributos del tour, listo para ser almacenado o enviado.
  Map<String, dynamic> toJson() {
    return {
      'city': city,
      'pois': pois.map((poi) => poi.toJson()).toList(),
      'mode': mode,
      'userPreferences': userPreferences,
      'duration': duration,
      'distance': distance,
      'polilynePoints': polilynePoints
          .map((point) =>
              {'latitude': point.latitude, 'longitude': point.longitude})
          .toList(),
      'documentId': documentId,
    };
  }

  /// Crea una instancia de [EcoCityTour] a partir de un mapa JSON.
  ///
  /// - [json]: Mapa que representa los datos del tour.
  ///
  /// Retorna un objeto [EcoCityTour].
  factory EcoCityTour.fromJson(Map<String, dynamic> json) {
    return EcoCityTour(
      city: json['city'],
      pois: (json['pois'] as List)
          .map((poi) => PointOfInterest.fromJson(poi))
          .toList(),
      mode: json['mode'],
      userPreferences: List<String>.from(json['userPreferences']),
      duration: (json['duration'] as num?)?.toDouble(),
      distance: (json['distance'] as num?)?.toDouble(),
      polilynePoints: (json['polilynePoints'] as List)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
      documentId: json['documentId'],
    );
  }

  /// Crea una instancia de [EcoCityTour] desde un documento de Firestore.
  ///
  /// - [doc]: Documento de Firestore que contiene los datos del tour.
  ///
  /// Retorna un objeto [EcoCityTour].
  factory EcoCityTour.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EcoCityTour(
      documentId: doc.id,
      city: data['city'],
      mode: data['mode'],
      userPreferences: List<String>.from(data['userPreferences']),
      duration: (data['duration'] as num?)?.toDouble(),
      distance: (data['distance'] as num?)?.toDouble(),
      polilynePoints: (data['polilynePoints'] as List)
          .map((point) => LatLng(point['lat'], point['lng']))
          .toList(),
      pois: (data['pois'] as List).map((poiData) {
        final poiGps = poiData['gps'];
        return PointOfInterest(
          gps: LatLng(poiGps['lat'], poiGps['lng']),
          name: poiData['name'],
          description: poiData['description'],
          url: poiData['url'],
          imageUrl: poiData['imageUrl'],
          rating: (poiData['rating'] as num?)?.toDouble(),
          address: poiData['address'],
          userRatingsTotal: poiData['userRatingsTotal'],
        );
      }).toList(),
    );
  }

  // Getter para el mensaje del logger.
  String get name => city;

  /// Crea una copia del tour con los valores proporcionados sobrescribiendo los existentes.
  ///
  /// - [city]: Nombre de la ciudad (opcional).
  /// - [pois]: Lista de puntos de interés (opcional).
  /// - [mode]: Modo de transporte (opcional).
  /// - [userPreferences]: Preferencias del usuario (opcional).
  /// - [duration]: Duración estimada del tour (opcional).
  /// - [distance]: Distancia total del tour (opcional).
  /// - [polilynePoints]: Puntos de la polilínea (opcional).
  ///
  /// Retorna un nuevo objeto [EcoCityTour].
  EcoCityTour copyWith({
    String? city,
    List<PointOfInterest>? pois,
    String? mode,
    List<String>? userPreferences,
    double? duration,
    double? distance,
    List<LatLng>? polilynePoints,
  }) {
    return EcoCityTour(
      city: city ?? this.city,
      pois: pois ?? this.pois,
      mode: mode ?? this.mode,
      userPreferences: userPreferences ?? this.userPreferences,
      duration: duration ?? this.duration,
      distance: distance ?? this.distance,
      polilynePoints: polilynePoints ?? this.polilynePoints,
    );
  }
}
