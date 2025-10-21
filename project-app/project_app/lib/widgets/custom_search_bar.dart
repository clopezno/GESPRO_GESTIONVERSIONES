import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:project_app/delegates/delegates.dart';

import '../models/models.dart';

/// Un widget que muestra una barra de búsqueda personalizada.
///
/// Al interactuar con esta barra, se abre un [SearchDelegate] para buscar y seleccionar
/// un punto de interés ([PointOfInterest]). El diseño está optimizado para encajar
/// de forma limpia en la interfaz general.
class CustomSearchBar extends StatelessWidget {
  /// Crea una instancia de [CustomSearchBar].
  const CustomSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsetsDirectional.only(top: 10),
        padding: const EdgeInsets.symmetric(horizontal: 30),
        width: double.infinity,
        child: GestureDetector(
          onTap: () async {
            // Abre el SearchDelegate y espera el resultado
            final result = await showSearch<PointOfInterest?>(
              context: context,
              delegate: SearchDestinationDelegate(),
            );

            // Si no se selecciona un resultado, no se realiza ninguna acción
            if (result == null) return;
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(100),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 5,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            // Texto que invita al usuario a interactuar con la barra de búsqueda
            child: Text(
              'add_poi_prompt'.tr(),
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
