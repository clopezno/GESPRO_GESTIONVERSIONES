import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/persistence_bd/repositories/repositories.dart';

class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

class MockLocationBloc extends MockBloc<LocationEvent, LocationState>
    implements LocationBloc {}

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

class MockEcoCityTourRepository extends Mock implements EcoCityTourRepository {}

// Fake para EcoCityTour
class FakeEcoCityTour extends Fake implements EcoCityTour {}

void main() {
  late MockTourBloc mockTourBloc;
  late MockLocationBloc mockLocationBloc;
  late MockMapBloc mockMapBloc;
  late MockEcoCityTourRepository mockEcoCityTourRepository;

  setUpAll(() {
    // Registrar el Fake
    registerFallbackValue(FakeEcoCityTour());
  });

  setUp(() {
    mockTourBloc = MockTourBloc();
    mockLocationBloc = MockLocationBloc();
    mockMapBloc = MockMapBloc();
    mockEcoCityTourRepository = MockEcoCityTourRepository();

    // Registrar valores por defecto
    registerFallbackValue(const ResetTourEvent());
    registerFallbackValue(const TourState());
    registerFallbackValue(const LocationState());
    registerFallbackValue(const MapState());

    // Configurar el TourBloc con el repositorio mock
    when(() => mockTourBloc.ecoCityTourRepository)
        .thenReturn(mockEcoCityTourRepository);

    // Configurar el MapBloc para manejar drawEcoCityTour
    when(() => mockMapBloc.drawEcoCityTour(any()))
        .thenAnswer((_) async => Future.value());
  });

  tearDown(() {
    mockTourBloc.close();
    mockLocationBloc.close();
    mockMapBloc.close();
  });

  Widget createTestWidget(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TourBloc>.value(value: mockTourBloc),
        BlocProvider<LocationBloc>.value(value: mockLocationBloc),
        BlocProvider<MapBloc>.value(value: mockMapBloc),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('SavedToursScreen Tests', () {
    testWidgets('Muestra el estado vacío cuando no hay tours guardados',
        (WidgetTester tester) async {
      when(() => mockTourBloc.state).thenReturn(
        const TourState(savedTours: []),
      );

      await tester.pumpWidget(createTestWidget(const SavedToursScreen()));

      expect(find.text('saved_tours_empty_message'.tr()), findsOneWidget);
      expect(
        find.textContaining('saved_tours_empty_submessage'.tr()),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Navega correctamente al seleccionar un tour guardado',
        (WidgetTester tester) async {
      final mockTour = EcoCityTour(
        city: 'Madrid',
        mode: 'walking',
        userPreferences: ['historical'],
        distance: 3000,
        duration: 3600,
        pois: [],
        polilynePoints: const [],
        documentId: '1234',
      );

      when(() => mockTourBloc.state).thenReturn(
        TourState(savedTours: [mockTour]),
      );

      when(() => mockLocationBloc.state).thenReturn(const LocationState());
      when(() => mockMapBloc.state).thenReturn(const MapState());

      await tester.pumpWidget(createTestWidget(const SavedToursScreen()));

      // Verificar que el tour esté presente
      expect(find.textContaining('Madrid'), findsOneWidget);

      // Tocar el tour guardado
      await tester.tap(find.textContaining('Madrid'));
      await tester.pumpAndSettle();

      // Verificar que el evento correcto se haya emitido
      verify(() => mockTourBloc.add(const LoadTourFromSavedEvent(documentId: '1234')))
          .called(1);

      // Verificar que el mapa dibuje el tour
      verify(() => mockMapBloc.drawEcoCityTour(mockTour)).called(1);
    });

    testWidgets('Elimina un tour guardado correctamente',
        (WidgetTester tester) async {
      final mockTour = EcoCityTour(
        city: 'Madrid',
        mode: 'walking',
        userPreferences: ['historical'],
        distance: 3000,
        duration: 3600,
        pois: [],
        polilynePoints: const [],
        documentId: '1234',
      );

      when(() => mockTourBloc.state).thenReturn(
        TourState(savedTours: [mockTour]),
      );

      when(() => mockEcoCityTourRepository.deleteTour('1234'))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createTestWidget(const SavedToursScreen()));

      expect(find.textContaining('Madrid'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      await tester.tap(find.text('delete'.tr()));
      await tester.pumpAndSettle();

      verify(() => mockEcoCityTourRepository.deleteTour('1234')).called(1);
    });
  });
}
