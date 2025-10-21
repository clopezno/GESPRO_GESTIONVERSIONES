import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:go_router/go_router.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/widgets/custom_app_bar.dart';
import '../test_helpers.dart'; // Importa el helper

class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

class FakeTourEvent extends Fake implements TourEvent {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  late MockTourBloc mockTourBloc;

  setUpAll(() {
    setupTestEnvironment(); // Configura el entorno de pruebas
    registerFallbackValue(FakeTourEvent());
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() {
    mockTourBloc = MockTourBloc();
  });

  Widget createTestWidget({required TourState tourState}) {
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              appBar: CustomAppBar(
                title: 'Test AppBar',
                tourState: tourState,
              ),
              body: const Center(child: Text('Body Content')),
            ),
          ),
          GoRoute(
            path: '/tour-selection',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Tour Selection'))),
          ),
          GoRoute(
            path: '/tour-summary',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('Tour Summary'))),
          ),
        ],
      ),
    );
  }

  group('CustomAppBar Tests', () {
    testWidgets('Renderiza correctamente el título y acciones',
        (WidgetTester tester) async {
      const tourState = TourState(ecoCityTour: null);
      await tester.pumpWidget(createTestWidget(tourState: tourState));

      // Verificar que el título está presente
      expect(find.text('Test AppBar'), findsOneWidget);

      // Verificar que el botón de retroceso está presente
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // No debería haber botón de resumen porque `ecoCityTour` es null
      expect(find.byIcon(Icons.list), findsNothing);
    });

    testWidgets('Muestra el botón de resumen si ecoCityTour no es null',
        (WidgetTester tester) async {
      final tourState = TourState(
        ecoCityTour: EcoCityTour(
          city: 'Test City',
          pois: [],
          mode: 'walking',
          userPreferences: ['Nature'],
          polilynePoints: [],
        ),
      );
      await tester.pumpWidget(createTestWidget(tourState: tourState));

      // Verificar que el botón de resumen está presente
      expect(find.byIcon(Icons.list), findsOneWidget);
    });

    testWidgets('Navega a TourSelection al presionar el botón de retroceso',
        (WidgetTester tester) async {
      const tourState = TourState(ecoCityTour: null);
      await tester.pumpWidget(createTestWidget(tourState: tourState));

      // Simula un tap en el botón de retroceso
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verificar que navega a la pantalla de selección de tours
      expect(find.text('Tour Selection'), findsOneWidget);
    });

    testWidgets(
        'Muestra diálogo de confirmación antes de reiniciar y navegar si ecoCityTour no es null',
        (WidgetTester tester) async {
      final tourState = TourState(
        ecoCityTour: EcoCityTour(
          city: 'Test City',
          pois: [],
          mode: 'walking',
          userPreferences: ['Nature'],
          polilynePoints: [],
        ),
      );
      when(() => mockTourBloc.state).thenReturn(tourState);

      await tester.pumpWidget(
        BlocProvider<TourBloc>.value(
          value: mockTourBloc,
          child: createTestWidget(tourState: tourState),
        ),
      );

      // Simula un tap en el botón de retroceso
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verificar que se muestra el diálogo de confirmación
      expect(find.text('generate_new_tour'.tr()), findsOneWidget);
      expect(find.text('confirm_delete_current_tour'.tr()), findsOneWidget);

      // Tap en "Sí" para confirmar
      await tester.tap(find.text('yes'.tr()));
      await tester.pumpAndSettle();

      // Verificar que navega a la pantalla de selección de tours
      expect(find.text('Tour Selection'), findsOneWidget);

      // Verificar que se dispara el evento de reinicio del tour
      verify(() => mockTourBloc.add(const ResetTourEvent())).called(1);
    });

    testWidgets('Navega a TourSummary al presionar el botón de resumen',
        (WidgetTester tester) async {
      final tourState = TourState(
        ecoCityTour: EcoCityTour(
          city: 'Test City',
          pois: [],
          mode: 'walking',
          userPreferences: ['Nature'],
          polilynePoints: [],
        ),
      );
      await tester.pumpWidget(createTestWidget(tourState: tourState));

      // Simula un tap en el botón de resumen
      await tester.tap(find.byIcon(Icons.list));
      await tester.pumpAndSettle();

      // Verificar que navega a la pantalla de resumen del tour
      expect(find.text('Tour Summary'), findsOneWidget);
    });
  });
}
