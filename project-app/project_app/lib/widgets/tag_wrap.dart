// FILE: widgets/tag_wrap.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_app/helpers/icon_helpers.dart'; // Importar icon_helpers.dart

/// Widget que muestra una lista de etiquetas interactivas en un diseño ajustable (wrap).
///
/// Cada etiqueta representa una preferencia seleccionable, mostrando un ícono y un texto.
/// El estado de selección de cada etiqueta se gestiona externamente y se pasa como
/// [selectedPreferences]. Al seleccionar o deseleccionar una etiqueta, se invoca
/// [onTagSelected] con el nombre de la etiqueta seleccionada.
class TagWrap extends StatelessWidget {
  /// Mapa que contiene las preferencias seleccionadas por el usuario.
  ///
  /// La clave es el nombre de la preferencia, y el valor indica si está seleccionada.
  final Map<String, bool> selectedPreferences;

  /// Callback que se invoca cuando se selecciona o deselecciona una etiqueta.
  ///
  /// Proporciona el nombre de la etiqueta seleccionada.
  final Function(String) onTagSelected;

  /// Crea una instancia de [TagWrap].
  ///
  /// - [selectedPreferences] es el estado de selección de las etiquetas.
  /// - [onTagSelected] maneja los cambios en la selección de etiquetas.
  const TagWrap({
    super.key,
    required this.selectedPreferences,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // Espaciado horizontal entre chips
      runSpacing: 8.0, // Espaciado vertical entre filas
      alignment: WrapAlignment.center, // Alineación centrada
      children: userPreferences.keys.map((String key) {
        final bool isSelected = selectedPreferences[key] ?? false;

        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ícono de la etiqueta
              Icon(
                userPreferences[key]?['icon'],
                size: 20.0,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6.0),
              // Texto de la etiqueta
              Text(
                key.tr(),
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
          // Forma y borde del chip
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0),
            side: BorderSide(
              color: isSelected
                  ? userPreferences[key]!['color']
                  : Colors.grey.shade400,
            ),
          ),
          selectedColor:
              userPreferences[key]!['color'], // Color cuando está seleccionado
          backgroundColor: isSelected
              ? userPreferences[key]!['color']
              : userPreferences[key]!['color']!
                  .withOpacity(0.1), // Fondo cuando no está seleccionado
          elevation: isSelected ? 4.0 : 1.0, // Sombra según el estado
          shadowColor: Colors.grey.shade300, // Color de la sombra
          selected: isSelected, // Estado de selección
          // Acción al seleccionar/deseleccionar
          onSelected: (bool selected) {
            onTagSelected(key);
          },
        );
      }).toList(),
    );
  }
}
