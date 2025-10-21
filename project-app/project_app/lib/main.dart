import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/persistence_bd/datasets/datasets.dart';
import 'package:project_app/firebase_options.dart';
import 'package:project_app/persistence_bd/repositories/repositories.dart';
import 'package:project_app/router/app_router.dart';
import 'package:project_app/services/services.dart';
import 'package:project_app/themes/themes.dart';
import 'package:project_app/logger/logger.dart';

/// Punto de entrada principal de la aplicación.
///
/// Esta función inicializa servicios esenciales como Firebase, Crashlytics,
/// autenticación anónima, y configura los blocs necesarios para la lógica de la aplicación.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Carga variables de entorno desde el archivo .env
  await dotenv.load(fileName: ".env");

  // Inicializa Firebase con las opciones predeterminadas según la plataforma
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura Firebase Crashlytics para capturar errores de Flutter
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

  // Configura Crashlytics para capturar errores fuera del framework de Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  // Autentica al usuario de forma anónima y obtener su instancia
  final User? user = await _authenticateUser();

  // Establece el observador de blocs para depuración
  Bloc.observer = MyBlocObserver();

  // Crea instancias de repositorios y datasets necesarios
  final firestoreDataset = FirestoreDataset(userId: user?.uid);
  final ecoCityTourRepository = EcoCityTourRepository(firestoreDataset);

  // Ejecuta la aplicación con los blocs configurados
  runApp(EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('es')],
    path: 'assets/translations', // Ruta a los archivos JSON
    fallbackLocale: const Locale('es'),
    child: MultiBlocProvider(
      providers: [
        // Bloc para manejar el estado del GPS
        BlocProvider(create: (context) => GpsBloc()),

        // Bloc para manejar la ubicación del usuario
        BlocProvider(create: (context) => LocationBloc()),

        // Bloc para la lógica del mapa, dependiente del Bloc de ubicación
        BlocProvider(
            create: (context) =>
                MapBloc(locationBloc: BlocProvider.of<LocationBloc>(context))),

        // Bloc para manejar la lógica de tours, dependiente de otros blocs y repositorios
        BlocProvider(
            create: (context) => TourBloc(
                optimizationService: OptimizationService(),
                mapBloc: BlocProvider.of<MapBloc>(context),
                ecoCityTourRepository: ecoCityTourRepository)),
      ],
      child: const ProjectApp(),
    ),
  ));
}

/// Widget principal de la aplicación.
///
/// Configura la interfaz gráfica, tema y rutas de navegación mediante [MaterialApp.router].
class ProjectApp extends StatelessWidget {
  const ProjectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Eco City Tours',
      theme: AppTheme.lightTheme, // Tema de la aplicación
      locale: context.locale, // Configura el idioma actual
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: AppRouter.router, // Configuración de rutas
    );
  }
}

/// Autentica al usuario de forma anónima utilizando Firebase Authentication.
///
/// Si ya existe un usuario autenticado, lo retorna. Si no, realiza un inicio
/// de sesión anónimo y registra el usuario en el logger.
///
/// Retorna la instancia del [User] autenticado, o `null` si ocurre un error.
Future<User?> _authenticateUser() async {
  try {
    final auth = FirebaseAuth.instance;

    // Verifica si el usuario ya está autenticado
    if (auth.currentUser != null) {
      return auth.currentUser;
    }

    // Realiza inicio de sesión anónimo
    final userCredential = await auth.signInAnonymously();
    log.i("Usuario autenticado de forma anónima: ${userCredential.user?.uid}");
    return userCredential.user;
  } catch (e) {
    log.e("Error en autenticación anónima: $e");
    return null;
  }
}
