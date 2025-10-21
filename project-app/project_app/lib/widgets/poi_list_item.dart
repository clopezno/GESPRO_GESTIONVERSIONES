import 'package:flutter/material.dart';
import 'package:project_app/logger/logger.dart'; // Importar logger para registrar eventos y errores
import 'package:project_app/models/models.dart';
import 'package:project_app/blocs/blocs.dart';

/// Widget que muestra un elemento expandible con información de un punto de interés (POI).
///
/// Este widget incluye:
/// - Imagen del POI (cargada desde la red o un asset predeterminado en caso de error).
/// - Título, calificación y descripción del POI.
/// - Funcionalidad para expandir/colapsar la descripción.
/// - Botón para eliminar el POI del tour.
///
/// Utiliza un `FutureBuilder` para gestionar la carga de imágenes y permite alternar
/// entre la vista expandida y colapsada con un clic.
class ExpandablePoiItem extends StatefulWidget {
  /// El punto de interés que se representará.
  final PointOfInterest poi;

  /// Bloc encargado de manejar los eventos relacionados con el tour.
  final TourBloc tourBloc;

  /// Crea una instancia de [ExpandablePoiItem].
  ///
  /// - [poi] es el punto de interés que se mostrará.
  /// - [tourBloc] es el bloc que gestionará eventos como la eliminación del POI.
  const ExpandablePoiItem({
    super.key,
    required this.poi,
    required this.tourBloc,
  });

  @override
  ExpandablePoiItemState createState() => ExpandablePoiItemState();
}

class ExpandablePoiItemState extends State<ExpandablePoiItem> {
  /// Indica si la descripción del POI está expandida.
  bool isExpanded = false;

  /// Future que representa la imagen del POI.
  late Future<Widget> _imageWidget;

  @override
  void initState() {
    super.initState();
    // Cargar la imagen del POI al iniciar el widget
    _imageWidget = _loadImage();
  }

  /// Carga la imagen del POI o utiliza una predeterminada en caso de error.
  Future<Widget> _loadImage() async {
    if (widget.poi.imageUrl == null) {
      log.w(
          'ExpandablePoiItem: No se encontró imagen para el POI ${widget.poi.name}, usando imagen predeterminada');
      return Image.asset(
        'assets/icon/icon.png',
        fit: BoxFit.cover,
      );
    } else {
      log.i('ExpandablePoiItem: Cargando imagen desde ${widget.poi.imageUrl}');
      return Image.network(
        widget.poi.imageUrl!,
        fit: BoxFit.cover,
        loadingBuilder:
            (BuildContext context, Widget child, ImageChunkEvent? progress) {
          if (progress == null) return child;
          // Indicador de progreso durante la carga de la imagen
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).primaryColor,
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          log.e(
              'ExpandablePoiItem: Error al cargar la imagen desde ${widget.poi.imageUrl}',
              error: error,
              stackTrace: stackTrace);
          return Image.asset(
            'assets/location_troll_bg.png',
            fit: BoxFit.cover,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          // Imagen circular con borde
          Container(
            margin: const EdgeInsets.all(8),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 3,
              ),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: FutureBuilder<Widget>(
                future: _imageWidget,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
          // Información del POI y opciones
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.only(left: 8),
              title: Text(
                widget.poi.name,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar calificación del POI si está disponible
                  if (widget.poi.rating != null)
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text('${widget.poi.rating}',
                            style: const TextStyle(fontSize: 14)),
                      ],
                    ),
                  // Descripción expandida o colapsada
                  if (!isExpanded && widget.poi.description != null)
                    Text(
                      widget.poi.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (isExpanded && widget.poi.description != null)
                    Text(widget.poi.description!),
                ],
              ),
              onTap: () {
                setState(() {
                  isExpanded = !isExpanded;
                  log.i(
                      'ExpandablePoiItem: Descripción de ${widget.poi.name} ${isExpanded ? "expandida" : "colapsada"}');
                });
              },
            ),
          ),
          // Botón de eliminar el POI
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(),
            onPressed: () {
              log.i(
                  'ExpandablePoiItem: Eliminando POI ${widget.poi.name} del EcoCityTour');
              widget.tourBloc.add(
                  OnRemovePoiEvent(poi: widget.poi, shouldUpdateMap: false));
            },
          ),
        ],
      ),
    );
  }
}
