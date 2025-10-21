import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/logger/logger.dart';

/// Una barra de navegación personalizada para gestionar la navegación y opciones del EcoCityTour.
///
/// Incluye un botón de retroceso con confirmación opcional y, si el tour está activo,
/// un botón para acceder al resumen. Se adapta al tema actual de la aplicación.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// El título que se muestra en el centro de la barra de navegación.
  final String title;

  /// El estado actual del tour, utilizado para determinar si mostrar opciones
  /// relacionadas con el EcoCityTour.
  final TourState tourState;

  /// Crea una instancia de [CustomAppBar].
  ///
  /// - [title] es el texto que se muestra como título.
  /// - [tourState] es el estado actual del EcoCityTour.
  const CustomAppBar({
    super.key,
    required this.title,
    required this.tourState,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        title,
        style: Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
      ),
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: Theme.of(context).appBarTheme.elevation,
      iconTheme: const IconThemeData(color: Colors.white), // Iconos en blanco
      leading: IconButton(
        icon: const Icon(Icons.arrow_back), // Icono de retroceso
        onPressed: () async {
          // Si ecoCityTour es null, no mostramos el diálogo y simplemente navegamos.
          if (tourState.ecoCityTour == null) {
            log.i(
                'MapScreen: ecoCityTour es null, navegando sin confirmación.');
            context.push('/tour-selection');
            return;
          }

          // Mostrar diálogo de confirmación antes de regresar.
          final shouldReset = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('generate_new_tour'.tr()),
              content: Text('confirm_delete_current_tour'.tr()),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(false), // Cerrar sin acción.
                  child: Text('cancel'.tr()),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pop(true), // Confirmar acción.
                  child: Text('yes'.tr()),
                ),
              ],
            ),
          );

          // Verifica si el widget sigue montado antes de usar el contexto.
          if (!context.mounted || shouldReset != true) return;

          log.i('MapScreen: Regresando a la selección de EcoCityTour.');
          // Reiniciar el estado del tour antes de volver.
          BlocProvider.of<TourBloc>(context).add(const ResetTourEvent());
          // Navegar a la pantalla de selección de tours.
          context.push('/tour-selection');
        },
      ),
      actions: [
        if (tourState.ecoCityTour != null)
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              log.i('MapScreen: Abriendo resumen del EcoCityTour');
              context.push('/tour-summary'); // Abrir resumen del tour.
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
