import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/exceptions/exceptions.dart';
import 'package:project_app/persistence_bd/repositories/repositories.dart';
import 'package:project_app/services/services.dart';

part 'tour_event.dart';
part 'tour_state.dart';

/// [TourBloc] es el Bloc encargado de gestionar el estado de los tours.
/// 
/// Gestiona la lógica relacionada con la creación, modificación, y visualización
/// de tours turísticos, además de interactuar con servicios como Gemini, Google
/// Places y un servicio de optimización de rutas.
class TourBloc extends Bloc<TourEvent, TourState> {
  /// Servicio utilizado para optimizar rutas entre puntos de interés (POIs).
  final OptimizationService optimizationService;
  /// Bloc utilizado para gestionar los marcadores y rutas en el mapa.
  final MapBloc mapBloc; 
  /// Repositorio utilizado para la carga y guardado de tours.
  final EcoCityTourRepository ecoCityTourRepository; 

  /// Constructor de [TourBloc].
  /// 
  /// Requiere instancias de [MapBloc], [OptimizationService], y
  /// [EcoCityTourRepository].
  TourBloc({
    required this.mapBloc,
    required this.optimizationService,
    required this.ecoCityTourRepository,
  }) : super(const TourState()) {
    // Manejadores de eventos a continuación
    on<LoadTourEvent>(_onLoadTour);
    on<OnRemovePoiEvent>(_onRemovePoi);
    on<OnAddPoiEvent>(_onAddPoi);
    on<OnJoinTourEvent>(_onJoinTour);
    // Reset de Tour. Emite estado con EcoCityTour y POI's a null.
    on<ResetTourEvent>((event, emit) {
      emit(state.copyWith(ecoCityTour: null, isJoined: false));
      mapBloc.add(const OnClearMapEvent()); // Limpia el mapa al resetear el tour
    });
    on<LoadSavedToursEvent>(_onLoadSavedTours);
    on<LoadTourFromSavedEvent>(_onLoadTourFromSaved);

  }

  /// Maneja la lógica para cargar un nuevo tour basado en las preferencias del usuario.
  /// 
  /// Obtiene POIs desde Gemini, mejora su información con Google Places, y
  /// optimiza la ruta utilizando el servicio de optimización.
  Future<void> _onLoadTour(LoadTourEvent event, Emitter<TourState> emit) async {
    log.i(
        'TourBloc: Loading tour for city: ${event.city}, with ${event.numberOfSites} sites');
    emit(state.copyWith(isLoading: true, hasError: false));

    try {
      //* 1. Obtener puntos de interés (POIs) desde el servicio Gemini.
      final pois = await GeminiService.fetchGeminiData(
          city: event.city,
          nPoi: event.numberOfSites,
          userPreferences: event.userPreferences,
          maxTime: event.maxTime,
          mode: event.mode,
          systemInstruction: event.systemInstruction);
      log.d('TourBloc: Fetched ${pois.length} POIs for ${event.city}');

      //* 2. **Recuperar información adicional de Google Places**
      List<PointOfInterest> updatedPois = [];
      for (PointOfInterest poi in pois) {
        final placeData =
            await PlacesService().searchPlace(poi.name, event.city);

        if (placeData != null) {
          log.d('TourBloc: Updating POI with Google Places data: ${poi.name}');
          final String apiKey = dotenv.env['GOOGLE_PLACES_API_KEY'] ?? '';
          final location = placeData['location'];

          // Actualizar POI con información de Google Places
          final updatedPoi = PointOfInterest(
            gps: location != null
                ? LatLng(
                    location['lat']?.toDouble() ?? poi.gps.latitude,
                    location['lng']?.toDouble() ?? poi.gps.longitude,
                  )
                : poi.gps,
            name: placeData['name'] ?? poi.name,
            description: placeData['editorialSummary'] ?? poi.description,
            url: placeData['website'] ?? poi.url,
            imageUrl: placeData['photos'] != null &&
                    placeData['photos'].isNotEmpty
                ? 'https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=${placeData['photos'][0]['photo_reference']}&key=$apiKey'
                : poi.imageUrl,
            rating: placeData['rating']?.toDouble() ?? poi.rating,
            address: placeData['formatted_address'],
            userRatingsTotal: placeData['user_ratings_total'],
          );
          updatedPois.add(updatedPoi); // Añadimos el POI actualizado
        } else {
          updatedPois
              .add(poi); // Si no hay información extra, añadimos el original
        }
      }

      //* 3. Llamar al servicio de optimización de rutas con los POIs actualizados
      final ecoCityTour = await optimizationService.getOptimizedRoute(
        pois: updatedPois, // Usa la lista de POIs actualizada
        mode: event.mode,
        city: event.city,
        userPreferences: event.userPreferences,
      );

      //* 4. Emitir el estado con el tour cargado.
      emit(state.copyWith(ecoCityTour: ecoCityTour, isLoading: false));
      log.i('TourBloc: Successfully loaded tour for ${event.city}');

      //* 5. Mandar a pintar el mapa en el MapBloc**
      await mapBloc.drawEcoCityTour(ecoCityTour);
    } catch (e) {
      if (e is AppException || e is DioException) {
        log.e('TourBloc: Error loading tour: $e', error: e);
      }
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  // Manejo del evento de unirse al tour
  Future<void> _onJoinTour(
      OnJoinTourEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: User joined the tour');
    // Cambiar el valor de isJoined al valor contrario
    emit(state.copyWith(isJoined: !state.isJoined));
  }

  /// Maneja la lógica para unirse al tour. Cambia el estado [isJoined].
  Future<void> _onAddPoi(OnAddPoiEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: Añadiendo POI: ${event.poi.name}');

    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) {
      return;
    }

    // Inicia la carga
    emit(state.copyWith(isLoading: true)); // Aquí ponemos el loading en true

    try {
      // Actualizamos la lista de POIs añadiendo el nuevo POI
      final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)
        ..add(event.poi);

      // Llamamos al método que actualiza la ruta con los nuevos POIs y vuelve a optimizar el tour
      await _updateTourWithPois(updatedPois, emit);

      // Añadir el marcador del nuevo POI en el mapa
      mapBloc.add(OnAddPoiMarkerEvent(event.poi));
    } catch (e) {
      log.e('Error añadiendo el POI: $e');
      emit(state.copyWith(hasError: true));
    } finally {
      // Finalizar la carga
      emit(state.copyWith(
          isLoading: false)); // Aquí quitamos el loading al finalizar
    }
  }

  /// Maneja la lógica para eliminar un POI del tour actual.
  Future<void> _onRemovePoi(
      OnRemovePoiEvent event, Emitter<TourState> emit) async {
    log.i('TourBloc: Eliminando POI: ${event.poi.name}');

    final ecoCityTour = state.ecoCityTour;
    if (ecoCityTour == null) return;

    // Iniciar la carga
    emit(state.copyWith(isLoading: true)); // Aquí ponemos el loading en true

    try {
      // Actualizamos la lista de POIs eliminando el POI
      final updatedPois = List<PointOfInterest>.from(ecoCityTour.pois)
        ..remove(event.poi);

      // Actualizamos el tour y recalculamos la ruta con los POIs restantes
      await _updateTourWithPois(updatedPois, emit);

      // Eliminar el marcador del POI en el mapa
      mapBloc.add(OnRemovePoiMarkerEvent(event.poi.name));
    } catch (e) {
      log.e('Error eliminando el POI: $e');
      emit(state.copyWith(hasError: true));
    } finally {
      // Finalizar la carga
      emit(state.copyWith(
          isLoading: false)); // Aquí quitamos el loading al finalizar
    }
  }

  /// Recalcula y optimiza un tour basado en una lista actualizada de POIs.
  Future<void> _updateTourWithPois(
    List<PointOfInterest> pois,
    Emitter<TourState> emit,
  ) async {
    log.d('TourBloc: Updating tour with ${pois.length} POIs');
    if (pois.isNotEmpty) {
      try {
        // Recalcular la ruta optimizada
        final ecoCityTour = await optimizationService.getOptimizedRoute(
          pois: pois,
          mode: state.ecoCityTour!.mode,
          city: state.ecoCityTour!.city,
          userPreferences: state.ecoCityTour!.userPreferences,
        );

        // Emitir el nuevo estado del tour
        emit(state.copyWith(ecoCityTour: ecoCityTour));

        // Llamar al método drawRoutePolyline del MapBloc para actualizar el mapa
        await mapBloc.drawEcoCityTour(ecoCityTour);
      } catch (e) {
        emit(state.copyWith(hasError: true));
      }
    } else {
      // Si no quedan POIs, emitimos el estado sin una ruta actual

      emit(state.copyWithNull());
    }
  }

  /// Guarda el tour actual en el repositorio con el nombre proporcionado.
  Future<void> saveCurrentTour(String tourName) async {
    if (state.ecoCityTour == null) return;
    await ecoCityTourRepository.saveTour(state.ecoCityTour!, tourName);
  }

  /// Maneja la lógica para cargar los tours guardados desde el repositorio.
  Future<void> _onLoadSavedTours(
      LoadSavedToursEvent event, Emitter<TourState> emit) async {
    emit(state.copyWith(isLoading: true)); // Estado de carga

    try {
      final savedTours = await ecoCityTourRepository.getSavedTours();
      emit(state.copyWith(isLoading: false, savedTours: savedTours));
      log.i('Tours guardados cargados exitosamente');
    } catch (e) {
      log.e('Error al cargar los tours guardados: $e');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  }

  /// Maneja la lógica para cargar un tour guardado específico desde el repositorio.
  Future<void> _onLoadTourFromSaved(LoadTourFromSavedEvent event, Emitter<TourState> emit) async {
  emit(state.copyWith(isLoading: true, hasError: false));

  try {
    // Cargar el tour desde Firestore utilizando el documentId
    final savedTour = await ecoCityTourRepository.getTourById(event.documentId);

    if (savedTour != null) {
      // Emitir el nuevo estado con el tour cargado
      emit(state.copyWith(ecoCityTour: savedTour, isLoading: false));
      log.i('Tour cargado correctamente desde Firestore: ${savedTour.city}');
      
      // Mandar a pintar la ruta y los POIs en el mapa
      await mapBloc.drawEcoCityTour(savedTour);
    } else {
      log.w('El tour no existe o es nulo.');
      emit(state.copyWith(isLoading: false, hasError: true));
    }
  } catch (e) {
    log.e('Error al cargar el tour desde Firestore: $e');
    emit(state.copyWith(isLoading: false, hasError: true));
  }
}


}