// FILE: widgets/transport_mode_selector.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_app/helpers/icon_helpers.dart'; // Importar icon_helpers.dart

/// Un widget para seleccionar el modo de transporte mediante un grupo de botones interactivos.
///
/// Este widget utiliza `ToggleButtons` para representar diferentes modos de transporte
/// (por ejemplo, caminar o andar en bicicleta). La selección actual se controla mediante
/// [isSelected], y los cambios se manejan con [onPressed].
class TransportModeSelector extends StatelessWidget {
  /// Lista que indica qué botones están seleccionados.
  ///
  /// Cada índice corresponde a un modo de transporte, siendo `true` si está seleccionado.
  final List<bool> isSelected;

  /// Callback que se invoca cuando el usuario selecciona un modo de transporte.
  ///
  /// Proporciona el índice del botón seleccionado.
  final ValueChanged<int> onPressed;

  /// Crea una instancia de [TransportModeSelector].
  ///
  /// - [isSelected] controla el estado actual de selección de los botones.
  /// - [onPressed] maneja los cambios en la selección.
  const TransportModeSelector({
    super.key,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        // Título explicativo para el selector de modo de transporte
        Text(
          'your_transport_mode'.tr(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        // Botones interactivos para seleccionar un modo de transporte
        Center(
          child: ToggleButtons(
            borderRadius: BorderRadius.circular(25.0),
            isSelected: isSelected, // Estado actual de los botones
            onPressed: onPressed, // Callback al presionar un botón
            children: [
              // Botón para caminar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(transportIcons['walking']),
              ),
              // Botón para andar en bicicleta
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(transportIcons['cycling']),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
