import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/widgets/custom_selection_app_bar.dart';
import 'package:project_app/widgets/widgets.dart';

/// Pantalla de selección de tour Eco City.
///
/// Permite a los usuarios configurar su experiencia, seleccionando lugar, número
/// de sitios, modo de transporte, tiempo máximo y preferencias personales.
class TourSelectionScreen extends StatefulWidget {
  const TourSelectionScreen({super.key});

  @override
  TourSelectionScreenState createState() => TourSelectionScreenState();
}

class TourSelectionScreenState extends State<TourSelectionScreen> {
  /// Lugar seleccionado por el usuario.
  String selectedPlace = '';

  /// Número de sitios a visitar.
  double numberOfSites = 2;

  /// Modo de transporte seleccionado.
  String selectedMode = 'walking';

  /// Estado del selector de modo de transporte.
  final List<bool> _isSelected = [true, false];

  /// Tiempo máximo permitido para la ruta en minutos.
  double maxTimeInMinutes = 90;

  /// Asistente seleccionado por el usuario (puede ser nulo).
  int? selectedAssistant;

  /// Preferencias seleccionadas por el usuario.
  final Map<String, bool> selectedPreferences = {
    'nature': false,
    'museums': false,
    'gastronomy': false,
    'sports': false,
    'shopping': false,
    'history': false,
  };

  /// Método para alternar el estado de las preferencias.
  void _onTagSelected(String key) {
    setState(() {
      selectedPreferences[key] = !selectedPreferences[key]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false, // Desactiva el botón de retroceso
      child: Scaffold(
        appBar: const CustomSelectionAppBar(),
        body: GestureDetector(
          onTap: () => FocusScope.of(context)
              .unfocus(), // Oculta el teclado al tocar fuera
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 20.0,
              bottom: bottomInset, // Ajusta para el teclado
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selección de lugar
                Text(
                  'place_to_visit'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                TextField(
                  onChanged: (value) {
                    setState(() {
                      selectedPlace = value;
                    });
                    log.i('Lugar seleccionado: $selectedPlace');
                  },
                  decoration: InputDecoration(
                    hintText: 'enter_place'.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                ),
                const SizedBox(height: 5),

                // Número de sitios (Slider)
                NumberOfSitesSlider(
                  numberOfSites: numberOfSites,
                  onChanged: (value) {
                    setState(() {
                      numberOfSites = value;
                    });
                    log.i(
                        'Número de sitios seleccionado: ${numberOfSites.round()}');
                  },
                ),
                const SizedBox(height: 5),

                // Selección de asistente de IA
                SelectAIAssistant(
                  onAssistantSelected: (index) {
                    setState(() {
                      selectedAssistant = index;
                    });
                    log.i(
                        'Asistente seleccionado: ${index ?? "Sin selección"}');
                  },
                ),
                const SizedBox(height: 5),

                // Selector de modo de transporte
                TransportModeSelector(
                  isSelected: _isSelected,
                  onPressed: (index) {
                    setState(() {
                      for (int i = 0; i < _isSelected.length; i++) {
                        _isSelected[i] = i == index;
                      }
                      selectedMode = index == 0 ? 'walking' : 'cycling';
                    });
                    log.i('Modo de transporte seleccionado: $selectedMode');
                  },
                ),
                const SizedBox(height: 15),

                // Preferencias del usuario (Chips)
                Text(
                  'your_interests'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 10),
                Center(
                  child: TagWrap(
                    selectedPreferences: selectedPreferences,
                    onTagSelected: _onTagSelected,
                  ),
                ),
                const SizedBox(height: 20),

                // Tiempo máximo para la ruta (Slider)
                TimeSlider(
                  maxTimeInMinutes: maxTimeInMinutes,
                  onChanged: (value) {
                    setState(() {
                      maxTimeInMinutes = value;
                    });
                    log.i(
                        'Tiempo máximo de ruta seleccionado: ${maxTimeInMinutes.round()} minutos');
                  },
                  formatTime: formatTime,
                ),
                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botón para realizar un Eco-City Tour
                    MaterialButton(
                      minWidth: MediaQuery.of(context).size.width - 60,
                      color: Theme.of(context).primaryColor,
                      elevation: 0,
                      height: 50, // Altura consistente
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      onPressed: _requestTour,
                      child: Text(
                        'eco_city_tour'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20), // Espaciado entre los botones

                    // Botón para cargar una ruta guardada
                    MaterialButton(
                      minWidth: MediaQuery.of(context).size.width - 60,
                      color: Colors.grey[400],
                      elevation: 0,
                      height: 50, // Altura consistente
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25.0),
                      ),
                      onPressed: _loadSavedTours, // Nueva función
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.folder_open, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            'load_saved_route'.tr(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Lógica para cargar una ruta guardada.
  void _loadSavedTours() async {
    // Lógica para cargar el evento
    BlocProvider.of<TourBloc>(context).add(const LoadSavedToursEvent());

    await Future.delayed(const Duration(milliseconds: 500));

    // Verifica si el widget sigue montado antes de usar el contexto
    if (!mounted) return;

    // Usa el contexto de la clase State con la verificación correcta
    context.pushNamed('saved-tours');
  }

  /// Realiza la petición del tour con los datos seleccionados.
  void _requestTour() {
    if (selectedPlace.isEmpty) {
      selectedPlace = 'Salamanca, España';
      log.w('Lugar vacío, usando "Salamanca, España" por defecto.');
    }

    final assistants = [
      'family_safe_places'.tr(),
      'romantic_experiences'.tr(),
      'vibrant_places'.tr(),
    ];
    final systemInstruction =
        selectedAssistant == null ? '' : assistants[selectedAssistant!];

    LoadingMessageHelper.showLoadingMessage(context);

    BlocProvider.of<TourBloc>(context).add(LoadTourEvent(
      mode: selectedMode,
      city: selectedPlace,
      numberOfSites: numberOfSites.round(),
      userPreferences: selectedPreferences.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList(),
      maxTime: maxTimeInMinutes,
      systemInstruction: systemInstruction,
    ));

    late StreamSubscription listener;
    listener = BlocProvider.of<TourBloc>(context).stream.listen((tourState) {
      if (!mounted) return;

      if (!tourState.isLoading &&
          !tourState.hasError &&
          tourState.ecoCityTour != null) {
        Navigator.of(context).pop();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MapScreen(tour: tourState.ecoCityTour!),
          ),
        );
        listener.cancel();
      }

      if (tourState.hasError) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('load_tour_error'.tr())),
        );
        listener.cancel();
      }
    });
  }
}
