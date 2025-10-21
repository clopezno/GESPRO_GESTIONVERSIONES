import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/blocs.dart';

/// Un botón que permite al usuario alternar entre seguir o no su ubicación en el mapa.
///
/// Este widget utiliza [MapBloc] para gestionar el estado actual y responder a
/// eventos relacionados con la ubicación del usuario. Su apariencia cambia en función
/// de si el usuario está siendo seguido o no.
class BtnFollowUser extends StatelessWidget {
  /// Crea una instancia de [BtnFollowUser].
  const BtnFollowUser({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtiene la instancia de MapBloc desde el contexto actual.
    final mapBloc = BlocProvider.of<MapBloc>(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: CircleAvatar(
        backgroundColor: Theme.of(context).primaryColor,
        maxRadius: 25,
        // Construye el contenido del botón según el estado actual del MapBloc.
        child: BlocBuilder<MapBloc, MapState>(
          builder: (context, state) {
            return IconButton(
              // El ícono depende de si se está siguiendo al usuario.
              icon: Icon(
                state.isFollowingUser 
                    ? Icons.directions_run_outlined 
                    : Icons.my_location_outlined,
                color: Colors.white,
              ),
              // Envía un evento para comenzar a seguir al usuario al presionar el botón.
              onPressed: () {
                mapBloc.add(const OnStartFollowingUserEvent());
              },
            );
          },
        ),
      ),
    );
  }
}
