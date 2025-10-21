import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_app/blocs/tour/tour_bloc.dart';
import 'package:project_app/models/eco_city_tour.dart';
import 'package:project_app/screens/screens.dart';
import '../test_helpers.dart';

class MockTourBloc extends Mock implements TourBloc {}

void main() {
  late MockTourBloc mockTourBloc;

  setUpAll(() async {
    setupTestEnvironment(); // Configura EasyLocalization
    await EasyLocalization.ensureInitialized();
  });

  setUp(() {
    mockTourBloc = MockTourBloc();

    whenListen(
      mockTourBloc,
      const Stream<TourState>.empty(),
      initialState: const TourState(ecoCityTour: null),
    );
  });

  Widget createTestWidget(Widget child) {
    return EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('es')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: BlocProvider<TourBloc>.value(
        value: mockTourBloc,
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      ),
    );
  }

  group('TourSummary Widget Tests', () {
    testWidgets(
        'Muestra Snackbar y navega hacia atrás cuando ecoCityTour es null',
        (WidgetTester tester) async {
      when(() => mockTourBloc.state)
          .thenReturn(const TourState(ecoCityTour: null));

      await tester.pumpWidget(createTestWidget(const TourSummaryScreen()));

      // Permite que se ejecute el `addPostFrameCallback` para el Snackbar
      await tester.pump();
      expect(find.text('empty_tour_message'.tr()), findsOneWidget);
    });

    testWidgets('Muestra cuadro de diálogo al tocar el botón de guardar',
        (WidgetTester tester) async {
      final ecoCityTour = EcoCityTour(
        city: 'Ciudad de prueba',
        pois: [],
        mode: 'walking',
        userPreferences: [],
        duration: 120,
        distance: 5.0,
        polilynePoints: [],
      );

      when(() => mockTourBloc.state)
          .thenReturn(TourState(ecoCityTour: ecoCityTour));

      await tester.pumpWidget(createTestWidget(const TourSummaryScreen()));

      await tester.tap(find.byIcon(Icons.save_as_rounded));
      await tester.pumpAndSettle();

      expect(find.text('save_tour_name'.tr()), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
