import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';

/// Un botón que permite al usuario alternar la visualización de la ruta en el mapa.
///
/// Este widget utiliza [MapBloc] para gestionar el estado que controla si la ruta del usuario
/// debe mostrarse o no. Su apariencia cambia en función del estado actual de la ruta.
class BtnToggleUserRoute extends StatelessWidget {
  /// Crea una instancia de [BtnToggleUserRoute].
  const BtnToggleUserRoute({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene la instancia de MapBloc desde el contexto actual.
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        maxRadius: 25,
        // Construye el contenido del botón en función del estado actual del MapBloc.
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return IconButton(
              // Cambia el ícono según si la ruta del usuario se está mostrando o no.
              icon: Icon(
                state.showUserRoute ? Icons.mode_rounded : Icons.draw_rounded,
                color: Colors.white,
              ),
              // Envía un evento para alternar la visualización de la ruta del usuario.
              onPressed: () {
                mapBloc.add(const OnToggleShowUserRouteEvent());
              },
            );
          },
        ),
      ),
    );
  }
}
