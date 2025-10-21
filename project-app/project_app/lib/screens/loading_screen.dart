import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart'; // Importamos GoRouter para la navegación

import 'package:project_app/blocs/blocs.dart';

/// Pantalla de carga inicial.
///
/// Esta pantalla valida si el GPS y los permisos necesarios están habilitados
/// antes de redirigir al usuario a la siguiente pantalla apropiada.
class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GpsBloc, GpsState>(
      /// Escucha los cambios en el estado del [GpsBloc] para manejar la navegación.
      listener: (context, state) {
        if (state.isAllReady) {
          // Si el GPS y los permisos están listos, redirige a la pantalla de selección de tours.
          context.go(
              '/tour-selection'); // Navega a la pantalla de selección de tours
        } else {
          // Si no están listos, redirige a la pantalla de acceso al GPS.
          context.go('/gps-access'); // Navega a la pantalla de acceso al GPS
        }
      },
      child: const Scaffold(
        body: Center(
          /// Muestra un indicador de carga mientras se verifica el estado.
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
