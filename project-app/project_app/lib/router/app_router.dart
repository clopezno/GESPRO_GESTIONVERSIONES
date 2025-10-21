import 'package:go_router/go_router.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/screens/screens.dart';

/// Clase que gestiona las rutas de la aplicación utilizando [GoRouter].
///
/// Define las rutas principales, las pantallas asociadas y las reglas de navegación
/// para garantizar una experiencia fluida.
class AppRouter {
  /// Configuración principal del enrutador de la aplicación.
  ///
  /// Incluye las rutas iniciales, rutas nombradas y las pantallas correspondientes.
  static final GoRouter router = GoRouter(
    // Ubicación inicial al iniciar la aplicación
    initialLocation: '/',

    // Definición de las rutas
    routes: [
      // Ruta para la pantalla de carga inicial
      GoRoute(
        path: '/',
        name: 'loading',
        builder: (context, state) => const LoadingScreen(),
      ),

      // Ruta para la selección de tours
      GoRoute(
        path: '/tour-selection',
        name: 'tour-selection',
        builder: (context, state) => const TourSelectionScreen(),
      ),

      // Ruta para la pantalla de acceso al GPS
      GoRoute(
        path: '/gps-access',
        name: 'gps-access',
        builder: (context, state) => const GpsAccessScreen(),
      ),

      // Ruta para el resumen del tour
      GoRoute(
        path: '/tour-summary',
        name: 'tour-summary',
        builder: (context, state) => const TourSummaryScreen(),
      ),

      // Ruta para la pantalla del mapa, recibe un [EcoCityTour] como parámetro
      GoRoute(
        path: '/map',
        name: 'map',
        builder: (context, state) {
          // Recupera y deserializa el objeto EcoCityTour desde los datos extra
          final ecoCityTourJson = state.extra as Map<String, dynamic>;
          final ecoCityTour = EcoCityTour.fromJson(ecoCityTourJson);
          return MapScreen(tour: ecoCityTour);
        },
      ),

      // Ruta para la pantalla de tours guardados
      GoRoute(
        path: '/saved-tours',
        name: 'saved-tours',
        builder: (context, state) => const SavedToursScreen(),
      ),
    ],
  );
}
