import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_app/helpers/helpers.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/screens/screens.dart';

/// Pantalla que muestra los Eco City Tours guardados del usuario.
///
/// Permite visualizar, cargar y eliminar tours guardados.
class SavedToursScreen extends StatelessWidget {
  const SavedToursScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('saved_tours_title'.tr()),
        backgroundColor: Theme.of(context).primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go(
                '/tour-selection'); // Navega a la pantalla de selección de tours
          },
        ),
      ),
      body: BlocBuilder<TourBloc, TourState>(
        builder: (context, state) {
          final savedTours = state.savedTours;

          if (savedTours.isEmpty) {
            return _buildEmptyState(
                context); // Muestra un mensaje si no hay tours guardados
          }

          return ListView.builder(
            itemCount: savedTours.length,
            itemBuilder: (context, index) {
              final tour = savedTours[index];
              final tourName = '${tour.documentId ?? 'Tour'} - ${tour.city}';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    tourName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                          '${'distance'.tr()}: ${formatDistance(tour.distance ?? 0)}'),
                      Text(
                          '${'duration'.tr()}: ${formatDuration((tour.duration ?? 0).toInt())}'),
                      const SizedBox(height: 4),
                      Row(
                        children: tour.userPreferences.map((preference) {
                          final prefIconData = userPreferences[preference];
                          if (prefIconData != null) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                prefIconData['icon'],
                                color: prefIconData['color'],
                                size: 24,
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                  leading: Icon(
                    transportIcons[tour.mode] ?? Icons.directions_walk,
                    color: Theme.of(context).primaryColor,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteTour(context, tour.documentId),
                  ),
                  onTap: () {
                    log.d('Usuario seleccionó el tour: ${tour.documentId}');
                    BlocProvider.of<TourBloc>(context).add(
                      LoadTourFromSavedEvent(documentId: tour.documentId!),
                    );
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: BlocProvider.of<TourBloc>(context),
                          child: MapScreen(tour: tour),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Construye la interfaz para el estado vacío (sin tours guardados).
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline,
                size: 80, color: Theme.of(context).primaryColor),
            const SizedBox(height: 20),
            Text(
              'saved_tours_empty_message'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'saved_tours_empty_submessage'.tr(),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.search, color: Colors.white),
              label: Text(
                'explore_tours'.tr(),
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                context.go(
                    '/tour-selection'); // Navega a la pantalla de selección de tours
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Maneja la eliminación de un tour guardado.
  ///
  /// - [context]: El contexto de la aplicación.
  /// - [documentId]: ID del documento del tour a eliminar.
  void _deleteTour(BuildContext context, String? documentId) async {
    if (documentId == null) {
      log.e('No se puede eliminar el tour: documentId es null');
      return;
    }

    final tourBloc = BlocProvider.of<TourBloc>(context);
    log.d('Usuario intentó eliminar el tour con documentId: $documentId');

    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('delete_tour_title'.tr()),
          content: Text('delete_tour_message'.tr()),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('delete'.tr(),
                  style: const TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      try {
        log.i('Intentando eliminar el tour con documentId: $documentId');
        await tourBloc.ecoCityTourRepository.deleteTour(documentId);
        log.i('Tour eliminado exitosamente con documentId: $documentId');

        // Recargar la lista de tours guardados después de eliminar
        tourBloc.add(const LoadSavedToursEvent());
      } catch (e) {
        log.e('Error al eliminar el tour con documentId $documentId: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('delete_tour_error'.tr())),
          );
        }
      }
    }
  }
}
