import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/screens/screens.dart';

class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

void main() {
  late MockTourBloc mockTourBloc;

  // Configuración de GoRouter para los tests
  late GoRouter goRouter;

  setUpAll(() {
    registerFallbackValue(const LoadTourEvent(
      mode: 'walking',
      city: '',
      numberOfSites: 2,
      userPreferences: [],
      maxTime: 90,
      systemInstruction: '',
    ));
    registerFallbackValue(const LoadSavedToursEvent());
  });

  setUp(() {
    // Inicializar el mock del Bloc
    mockTourBloc = MockTourBloc();

    // Configuración de GoRouter con `BlocProvider` a nivel raíz
    goRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => BlocProvider<TourBloc>.value(
            value: mockTourBloc,
            child: const TourSelectionScreen(),
          ),
        ),
        GoRoute(
          path: '/saved-tours',
          name: 'saved-tours',
          builder: (context, state) => BlocProvider<TourBloc>.value(
            value: mockTourBloc,
            child: const SavedToursScreen(),
          ),
        ),
      ],
    );
  });

  tearDown(() {
    mockTourBloc.close();
  });

  Widget createTestWidget() {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations', // Ruta de tus archivos de traducción
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'), // Localización inicial para los tests
      child: MaterialApp.router(
        routerConfig: goRouter,
      ),
    );
  }

  group('TourSelectionScreen Tests', () {
    testWidgets('Renderiza correctamente todos los widgets principales',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('place_to_visit'.tr()), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('number_of_sites'.tr()), findsOneWidget);
      expect(find.byType(Slider), findsNWidgets(2));
      expect(find.text('your_transport_mode'.tr()), findsOneWidget);
      expect(find.byType(ToggleButtons), findsOneWidget);
      expect(find.text('your_interests'.tr()), findsOneWidget);
      expect(find.byType(ChoiceChip), findsNWidgets(6));
      expect(find.text('eco_city_tour'.tr()), findsOneWidget);
    });

    testWidgets(
        'Dispara LoadTourEvent al pulsar el botón "eco_city_tour"',
        (WidgetTester tester) async {
      when(() => mockTourBloc.state).thenReturn(const TourState());

      await tester.pumpWidget(createTestWidget());
      final requestButton = find.text('eco_city_tour'.tr());
      expect(requestButton, findsOneWidget);

      await tester.ensureVisible(requestButton);
      await tester.tap(requestButton);
      await tester.pump();

      verify(() => mockTourBloc.add(any(that: isA<LoadTourEvent>()))).called(1);
    });

    testWidgets('Navega a SavedToursScreen al pulsar "load_saved_route"',
        (WidgetTester tester) async {
      // Simula el estado inicial del Bloc
      when(() => mockTourBloc.state).thenReturn(const TourState());

      // Construye el widget de prueba
      await tester.pumpWidget(createTestWidget());

      // Encuentra el botón "load_saved_route" usando su texto
      final loadSavedToursButton = find.text('load_saved_route'.tr());
      expect(loadSavedToursButton, findsOneWidget);

      // Asegúrate de que el botón sea visible desplazando hacia abajo si es necesario
      await tester.ensureVisible(loadSavedToursButton);

      // Simula el tap en el botón
      await tester.tap(loadSavedToursButton);

      // Espera a que se complete cualquier animación o navegación
      await tester.pumpAndSettle();

      // Verifica que el evento LoadSavedToursEvent fue agregado al Bloc
      verify(() => mockTourBloc.add(any(that: isA<LoadSavedToursEvent>()))).called(1);

      // Verifica que se navega a 'saved-tours'
      expect(find.byType(SavedToursScreen), findsOneWidget);
    });
  });
}
