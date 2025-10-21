import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:project_app/blocs/blocs.dart';

/// Pantalla que solicita acceso al GPS.
///
/// Esta pantalla se muestra si el acceso al GPS no está habilitado y permite
/// al usuario habilitarlo para continuar con la aplicación.
class GpsAccessScreen extends StatelessWidget {
  const GpsAccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<GpsBloc, GpsState>(
        /// Escucha los cambios en el estado del GPS.
        listener: (context, state) {
          if (state.isGpsEnabled) {
            // Si el GPS está habilitado, navega a la pantalla de selección de tour.
            context.go('/tour-selection');
          }
        },
        child: Center(
          child: BlocBuilder<GpsBloc, GpsState>(
            /// Construye la interfaz basada en el estado del GPS.
            builder: (context, state) {
              if (state.isGpsEnabled) {
                return const _AccessButton();
              } else {
                return const _EnableGpsMessage();
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Botón que solicita acceso al GPS.
///
/// Muestra un mensaje y un botón para solicitar acceso al GPS si aún no está habilitado.
class _AccessButton extends StatelessWidget {
  const _AccessButton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'gps_required_message'.tr(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontSize: 18,
                color: Theme.of(context).primaryColor, // Color del tema
              ),
        ),
        const SizedBox(height: 20), // Espacio entre el texto y el botón
        MaterialButton(
          minWidth:
              MediaQuery.of(context).size.width - 120, // Ancho personalizado
          color: Theme.of(context).primaryColor, // Color del botón
          elevation: 0,
          height: 50,
          shape: const StadiumBorder(), // Bordes redondeados
          onPressed: () {
            // Solicita acceso al GPS
            final gpsBloc = BlocProvider.of<GpsBloc>(context);
            gpsBloc.askGpsAccess();
          },
          child: Text(
            'ask_gps_access'.tr(),
            style: const TextStyle(
              color: Colors.white, // Texto en blanco
              fontWeight: FontWeight.w600, // Peso del texto
            ),
          ),
        ),
      ],
    );
  }
}

/// Mensaje que indica al usuario que habilite el GPS.
///
/// Este widget se muestra si el GPS no está habilitado.
class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      'enable_gps_message'.tr(),
      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Theme.of(context).primaryColor,
          ),
    );
  }
}
