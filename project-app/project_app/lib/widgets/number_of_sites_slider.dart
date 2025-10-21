import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Un widget que muestra un control deslizante para seleccionar la cantidad de sitios a visitar.
///
/// Este widget permite al usuario elegir un número entre 2 y 8 sitios, mostrando
/// un texto descriptivo y etiquetas en los extremos del control deslizante.
class NumberOfSitesSlider extends StatelessWidget {
  /// Valor actual del control deslizante, que representa la cantidad de sitios seleccionados.
  final double numberOfSites;

  /// Función que se llama cuando el usuario cambia el valor del control deslizante.
  final ValueChanged<double> onChanged;

  /// Crea una instancia de [NumberOfSitesSlider].
  ///
  /// - [numberOfSites] es el valor inicial del control deslizante.
  /// - [onChanged] es la función que se invoca cuando el usuario cambia el valor.
  const NumberOfSitesSlider({
    super.key,
    required this.numberOfSites,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        // Título que explica la función del control deslizante
        Text(
          'number_of_sites'.tr(), // Clave para el título
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Etiqueta para el valor mínimo
            Text('2', style: Theme.of(context).textTheme.headlineSmall),
            Expanded(
              child: Slider(
                // Valor actual del control deslizante
                value: numberOfSites,
                min: 2,
                max: 8,
                divisions: 6, // Divisiones del control deslizante
                label: numberOfSites.round().toString(), // Etiqueta flotante
                onChanged: onChanged,
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ),
            // Etiqueta para el valor máximo
            Text('8', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ],
    );
  }
}
