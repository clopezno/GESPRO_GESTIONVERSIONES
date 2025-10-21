import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Modelo que representa un punto de interés turístico.
///
/// Contiene información sobre la ubicación, nombre, descripción, calificación,
/// dirección y otros detalles relevantes para un punto de interés.
class PointOfInterest {
  /// Coordenadas GPS del punto de interés.
  final LatLng gps;

  /// Nombre del punto de interés.
  final String name;

  /// Descripción opcional del punto de interés.
  final String? description;

  /// URL opcional con información adicional del punto de interés.
  final String? url;

  /// URL opcional de una imagen representativa del punto de interés.
  final String? imageUrl;

  /// Calificación opcional del punto de interés (0-5).
  final double? rating;

  /// Dirección opcional del punto de interés.
  final String? address;

  /// Número opcional de valoraciones del punto de interés.
  final int? userRatingsTotal;

  /// Crea una instancia de [PointOfInterest].
  ///
  /// - [gps]: Coordenadas GPS (obligatorio).
  /// - [name]: Nombre del punto de interés (obligatorio).
  /// - [description]: Descripción del punto de interés (opcional).
  /// - [url]: Enlace a más información (opcional).
  /// - [imageUrl]: URL de una imagen del lugar (opcional).
  /// - [rating]: Calificación del lugar (opcional).
  /// - [address]: Dirección del lugar (opcional).
  /// - [userRatingsTotal]: Número de valoraciones (opcional).
  PointOfInterest({
    required this.gps,
    required this.name,
    this.description,
    this.url,
    this.imageUrl,
    this.rating,
    this.address,
    this.userRatingsTotal,
  });

  /// Convierte una instancia de [PointOfInterest] a un mapa JSON.
  ///
  /// Retorna un mapa que representa los atributos del punto de interés en formato JSON.
  Map<String, dynamic> toJson() {
    return {
      'gps': {'latitude': gps.latitude, 'longitude': gps.longitude},
      'name': name,
      'description': description,
      'url': url,
      'imageUrl': imageUrl,
      'rating': rating,
      'address': address,
      'userRatingsTotal': userRatingsTotal,
    };
  }

  /// Crea una instancia de [PointOfInterest] a partir de un mapa JSON.
  ///
  /// - [json]: Mapa con los datos del punto de interés en formato JSON.
  ///
  /// Retorna un objeto [PointOfInterest].
  factory PointOfInterest.fromJson(Map<String, dynamic> json) {
    return PointOfInterest(
      gps: LatLng(json['gps']['latitude'], json['gps']['longitude']),
      name: json['name'],
      description: json['description'],
      url: json['url'],
      imageUrl: json['imageUrl'],
      rating: (json['rating'] as num?)?.toDouble(),
      address: json['address'],
      userRatingsTotal: json['userRatingsTotal'],
    );
  }
}
