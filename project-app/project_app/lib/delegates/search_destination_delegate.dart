import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger

import 'package:project_app/models/models.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/ui/ui.dart'; // Para usar el CustomSnackbar

/// Delegate personalizado para buscar destinos y lugares utilizando Google Places.
///
/// Este `SearchDelegate` permite al usuario buscar puntos de interés en una ciudad,
/// seleccionarlos, y añadirlos tanto al mapa como al estado del tour.
class SearchDestinationDelegate extends SearchDelegate<PointOfInterest?> {
  /// Servicio de Google Places para realizar las búsquedas.
  final PlacesService _placesService = PlacesService();

  /// Clave API de Google Places, cargada desde las variables de entorno.
  final String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';

  /// Crea una instancia de [SearchDestinationDelegate].
  SearchDestinationDelegate() : super(searchFieldLabel: 'search_place_hint'.tr());

  /// Construye las acciones disponibles en el AppBar del buscador.
  ///
  /// En este caso, incluye un botón para limpiar el texto de búsqueda.
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          log.d('SearchDestinationDelegate: Buscador limpiado');
          query = ''; // Limpia la búsqueda
        },
      ),
    ];
  }

  /// Construye el widget que aparece al lado izquierdo del AppBar del buscador.
  ///
  /// En este caso, incluye un botón para regresar.
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios),
      onPressed: () {
        log.d('SearchDestinationDelegate: Volviendo atrás desde el buscador');
        close(context, null); // Cierra el buscador
      },
    );
  }

  /// Construye los resultados de búsqueda basados en el texto ingresado.
  ///
  /// Realiza una llamada al servicio de Google Places y muestra los resultados
  /// en una lista para que el usuario seleccione uno.
  Widget _buildSearchResults(BuildContext context, String city) {
    log.i(
        'SearchDestinationDelegate: Realizando búsqueda en Google Places para: "$query" en la ciudad: "$city"');

    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _placesService.searchPlaces(query, city),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData ||
            snapshot.data == null ||
            snapshot.data!.isEmpty) {
          // Muestra un Snackbar indicando que no se encontraron lugares
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (ScaffoldMessenger.of(context).mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                CustomSnackbar(msg: 'no_place_found'.tr()),
              );
            }
            close(context, null); // Cierra el buscador
          });
          return const SizedBox();
        }

        final places = snapshot.data!;
        return ListView.builder(
          itemCount: places.length,
          itemBuilder: (context, index) {
            final place = places[index];
            return ListTile(
              title: Text(place['name']),
              subtitle: Text(place['formatted_address']),
              onTap: () {
                // Crea un nuevo POI basado en la selección del usuario
                final pointOfInterest = PointOfInterest(
                  gps: LatLng(
                      place['location']['lat'], place['location']['lng']),
                  name: place['name'],
                  description: place['formatted_address'],
                  url: place['website'],
                  imageUrl: place['photos'] != null &&
                          place['photos'].isNotEmpty
                      ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${place['photos'][0]['photo_reference']}&key=$apiKey'
                      : null,
                  rating: place['rating']?.toDouble(),
                  address: place['formatted_address'],
                  userRatingsTotal: place['user_ratings_total'],
                );

                log.i(
                    'SearchDestinationDelegate: POI seleccionado: ${pointOfInterest.name}, ${pointOfInterest.address}');

                // Añade el POI al estado del TourBloc y al MapBloc
                BlocProvider.of<TourBloc>(context)
                    .add(OnAddPoiEvent(poi: pointOfInterest));
                BlocProvider.of<MapBloc>(context)
                    .add(OnAddPoiMarkerEvent(pointOfInterest));

                // Cierra el buscador
                close(context, pointOfInterest);
              },
            );
          },
        );
      },
    );
  }

  /// Construye el contenido principal al realizar una búsqueda.
  @override
  Widget buildResults(BuildContext context) {
    final tourState = BlocProvider.of<TourBloc>(context).state;

    if (tourState.ecoCityTour == null || tourState.ecoCityTour!.city.isEmpty) {
      log.w('SearchDestinationDelegate: No se ha seleccionado ninguna ciudad');
      return Center(child: Text('no_city_selected'.tr()));
    }

    return _buildSearchResults(context, tourState.ecoCityTour!.city);
  }

  /// Construye las sugerencias de búsqueda mientras el usuario escribe.
  @override
  Widget buildSuggestions(BuildContext context) {
    log.d('SearchDestinationDelegate: Mostrando sugerencias de búsqueda.');
    return Center(
        child: Text('search_suggestion_hint'.tr()));
  }
}
