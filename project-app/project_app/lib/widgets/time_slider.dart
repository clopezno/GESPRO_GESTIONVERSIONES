import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Un widget que permite seleccionar el tiempo máximo deseado para un trayecto.
///
/// Este control deslizante permite al usuario elegir un tiempo entre 15 minutos y 3 horas.
/// El valor seleccionado se muestra en el indicador flotante y puede ser personalizado
/// mediante el formato proporcionado por [formatTime].
class TimeSlider extends StatelessWidget {
  /// Tiempo máximo en minutos seleccionado actualmente.
  final double maxTimeInMinutes;

  /// Callback que se invoca cuando el valor del control deslizante cambia.
  /// Proporciona el nuevo valor seleccionado en minutos.
  final ValueChanged<double> onChanged;

  /// Función para formatear el tiempo mostrado en el indicador flotante.
  /// Recibe el tiempo en minutos y devuelve un [String] representativo.
  final String Function(double) formatTime;

  /// Crea una instancia de [TimeSlider].
  ///
  /// - [maxTimeInMinutes] es el valor inicial del control deslizante.
  /// - [onChanged] maneja los cambios en el valor seleccionado.
  /// - [formatTime] formatea el tiempo mostrado en el indicador flotante.
  const TimeSlider({
    super.key,
    required this.maxTimeInMinutes,
    required this.onChanged,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        // Título explicativo para el control deslizante
        Text(
          'max_time'.tr(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            // Etiqueta para el valor mínimo
            Text('15m', style: Theme.of(context).textTheme.headlineSmall),
            Expanded(
              child: Slider(
                // Valor actual del control deslizante
                value: maxTimeInMinutes,
                min: 15, // Mínimo 15 minutos
                max: 180, // Máximo 3 horas
                divisions: 11, // Divisiones de 15 minutos
                label: formatTime(maxTimeInMinutes)
                    .toString(), // Etiqueta flotante
                onChanged: onChanged, // Callback al cambiar el valor
                activeColor: Theme.of(context).primaryColor,
                inactiveColor: Theme.of(context).primaryColor.withOpacity(0.8),
              ),
            ),
            // Etiqueta para el valor máximo
            Text('3h', style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ],
    );
  }
}
