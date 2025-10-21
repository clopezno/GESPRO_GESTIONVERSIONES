import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar eventos y errores
import 'package:project_app/models/models.dart';
import 'package:project_app/blocs/tour/tour_bloc.dart'; // Importa el bloc correcto

/// Muestra un cuadro inferior con información detallada sobre un punto de interés (POI).
///
/// Este widget incluye:
/// - Título, imagen, dirección, calificación y descripción del POI (si están disponibles).
/// - Un enlace al sitio web del POI.
/// - Un botón para eliminar el POI del EcoCityTour.
///
/// Además, utiliza `BlocProvider` para gestionar eventos relacionados con el tour
/// y registra eventos importantes mediante el logger.
class CustomBottomSheet extends StatelessWidget {
  /// Punto de interés (POI) que se mostrará en el cuadro inferior.
  final PointOfInterest poi;

  /// Crea una instancia de [CustomBottomSheet].
  ///
  /// - [poi] es el punto de interés del que se mostrarán los detalles.
  const CustomBottomSheet({super.key, required this.poi});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título del POI
          Text(
            poi.name,
            style: const TextStyle(
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 10.0),

          // Imagen del POI
          if (poi.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: poi.imageUrl!,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) {
                  log.e(
                      'CustomBottomSheet: Error al cargar la imagen desde $url');
                  return const Icon(Icons.error);
                },
                fit: BoxFit.cover,
                width: double.infinity,
                height: 200.0,
              ),
            ),
          const SizedBox(height: 10.0),

          // Dirección del POI
          if (poi.address != null)
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.redAccent),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Text(
                    poi.address!,
                    style: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10.0),

          // Calificación del POI
          if (poi.rating != null && poi.rating! > 0) ...[
            Row(
              children: [
                RatingBarIndicator(
                  rating: poi.rating!,
                  itemBuilder: (context, _) => const Icon(
                    Icons.star,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 20.0,
                ),
                const SizedBox(width: 10.0),
                Text(
                  '${poi.rating!} / 5.0',
                  style: const TextStyle(fontSize: 16.0, color: Colors.black87),
                ),
                if (poi.userRatingsTotal != null)
                  Text('  (${poi.userRatingsTotal} ${'reviews'.tr()})'),
              ],
            ),
            const SizedBox(height: 10.0),
          ],

          // Descripción del POI
          if (poi.description != null) ...[
            Text(
              'description'.tr(),
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5.0),
            Text(
              poi.description!,
              style: const TextStyle(fontSize: 14.0, color: Colors.black54),
            ),
            const SizedBox(height: 10.0),
          ],

          // Enlace al sitio web
          if (poi.url != null) ...[
            GestureDetector(
              onTap: () async {
                final Uri url = Uri.parse(poi.url!);
                try {
                  if (await canLaunchUrl(url)) {
                    log.i('CustomBottomSheet: Abriendo enlace $url');
                    await launchUrl(url);
                  } else {
                    log.e('CustomBottomSheet: No se pudo abrir el enlace $url');
                    throw 'No se pudo abrir el enlace $url';
                  }
                } catch (e) {
                  log.e('CustomBottomSheet: Error al intentar abrir el enlace',
                      error: e);
                }
              },
              child: Text(
                'visit_website'.tr(),
                style: const TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                  fontSize: 16.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
          ],

          // Botón para eliminar el POI
          const SizedBox(height: 20.0),
          Center(
            child: ElevatedButton(
              onPressed: () {
                log.i(
                    'CustomBottomSheet: Eliminando POI ${poi.name} del EcoCityTour');
                BlocProvider.of<TourBloc>(context)
                    .add(OnRemovePoiEvent(poi: poi));
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
              ),
              child: Text(
                'remove_from_tour'.tr(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
