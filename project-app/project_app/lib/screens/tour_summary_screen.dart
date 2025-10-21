import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/helpers/helpers.dart'; // Importar el archivo de helpers
import 'package:project_app/ui/ui.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:project_app/blocs/blocs.dart';

/// Pantalla que muestra un resumen del **Eco City Tour** actual.
///
/// Permite visualizar información como la ciudad seleccionada, distancia,
/// duración, medio de transporte y los puntos de interés (POIs) del tour.
/// Además, ofrece la opción de **guardar el tour** con un nombre personalizado.
class TourSummaryScreen extends StatelessWidget {
  const TourSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth =
        screenWidth * 0.9; // Define el ancho de la tarjeta principal.

    return BlocBuilder<TourBloc, TourState>(
      builder: (context, state) {
        // Verifica si el Eco City Tour no existe en el estado actual.
        if (state.ecoCityTour == null) {
          // Muestra un Snackbar y navega atrás cuando el tour es nulo.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomSnackbar.show(context, 'empty_tour_message'.tr());
            Navigator.pop(context);
          });
          return const SizedBox.shrink();
        }

        // Construcción de la pantalla principal
        return Scaffold(
          appBar: AppBar(
            iconTheme:
                const IconThemeData(color: Colors.white), // Iconos en blanco
            centerTitle: true,
            title: Text(
              'tour_summary_title'.tr(),
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Theme.of(context).primaryColor, // Color del AppBar
            actions: [
              // Botón para guardar el tour
              IconButton(
                icon: const Icon(Icons.save_as_rounded),
                tooltip: 'save_tour_tooltip'.tr(),
                onPressed: () async {
                  // Abre un diálogo para solicitar el nombre del tour
                  final tourName = await showDialog<String>(
                    context: context,
                    builder: (BuildContext context) {
                      String inputText = '';
                      return AlertDialog(
                        title: Text('save_tour_name'.tr()),
                        content: TextField(
                          onChanged: (value) => inputText = value,
                          decoration: InputDecoration(
                              hintText: "save_tour_placeholder".tr()),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.pop(context, inputText),
                            child: Text('save_button'.tr()),
                          ),
                        ],
                      );
                    },
                  );

                  // Guarda el tour si el nombre es válido
                  if (tourName != null &&
                      tourName.isNotEmpty &&
                      context.mounted) {
                    await BlocProvider.of<TourBloc>(context)
                        .saveCurrentTour(tourName);
                    if (context.mounted) {
                      CustomSnackbar.show(context, 'tour_saved_success'.tr());
                    }
                  }
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // Tarjeta que muestra los detalles principales del tour
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Center(
                  child: SizedBox(
                    width:
                        cardWidth, // Ajusta el tamaño al 90% del ancho de la pantalla
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información de la ciudad
                            Text(
                              '${'city'.tr()}: ${state.ecoCityTour!.city}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Información de la distancia total
                            Text(
                              '${'distance'.tr()}: ${formatDistance(state.ecoCityTour!.distance ?? 0)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),

                            // Información de la duración total
                            Text(
                              '${'duration'.tr()}: ${formatDuration((state.ecoCityTour!.duration ?? 0).toInt())}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),

                            // Información del medio de transporte
                            Row(
                              children: [
                                Text('${'transport_mode'.tr()}:',
                                    style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 8),
                                Icon(
                                  transportIcons[state.ecoCityTour!.mode],
                                  size: 24,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Lista de puntos de interés (POIs)
              Expanded(
                child: ListView.builder(
                  itemCount: state.ecoCityTour!.pois.length,
                  itemBuilder: (context, index) {
                    final poi = state.ecoCityTour!.pois[index];
                    return ExpandablePoiItem(
                        poi: poi, tourBloc: BlocProvider.of<TourBloc>(context));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
