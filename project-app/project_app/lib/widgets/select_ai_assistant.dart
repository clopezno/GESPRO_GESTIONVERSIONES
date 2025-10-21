import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Widget para seleccionar un asistente turístico basado en diferentes estilos de viaje.
///
/// Este widget muestra una lista de asistentes turísticos con imágenes y descripciones.
/// Permite al usuario seleccionar un asistente, actualizando el estado visual y
/// enviando la selección al controlador mediante [onAssistantSelected].
class SelectAIAssistant extends StatefulWidget {
  /// Función que se invoca cuando el usuario selecciona o deselecciona un asistente.
  /// Proporciona el índice del asistente seleccionado o `null` si no hay selección.
  final ValueChanged<int?> onAssistantSelected;

  /// Crea una instancia de [SelectAIAssistant].
  /// 
  /// - [onAssistantSelected] es el callback para manejar la selección del asistente.
  const SelectAIAssistant({super.key, required this.onAssistantSelected});

  @override
  State<SelectAIAssistant> createState() => _SelectAIAssistantState();
}

class _SelectAIAssistantState extends State<SelectAIAssistant> {
  /// Índice del asistente seleccionado. Es `null` si no hay selección.
  int? selectedAssistant;

  /// Lista de asistentes turísticos con sus propiedades.
  final List<Map<String, dynamic>> assistants = [
    {
      'title': 'family_tour', // Clave para el título
      'description': 'family_tour_description', // Clave para la descripción
      'image': 'assets/images/family2.png',
    },
    {
      'title': 'romantic_tour',
      'description': 'romantic_tour_description',
      'image': 'assets/images/romantic2.png',
    },
    {
      'title': 'adventure_tour',
      'description': 'adventure_tour_description',
      'image': 'assets/images/adventure2.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la sección
        Text(
          'select_ai_assistant'.tr(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        // Mostrar las opciones de asistentes en un row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(assistants.length, (index) {
            final assistant = assistants[index];
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (selectedAssistant == index) {
                    selectedAssistant = null; // Deselecciona si ya está seleccionado
                  } else {
                    selectedAssistant = index; // Selecciona el nuevo asistente
                  }
                });
                // Invoca el callback con el índice seleccionado
                widget.onAssistantSelected(selectedAssistant);
              },
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedAssistant == index
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    width: 4,
                  ),
                  borderRadius: BorderRadius.circular(12.0),
                  image: DecorationImage(
                    image: AssetImage(assistant['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        // Descripción del asistente seleccionado
        Text(
          selectedAssistant != null
              ? (assistants[selectedAssistant!]['description'] as String).tr()
              : 'no_assistant_selected'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
