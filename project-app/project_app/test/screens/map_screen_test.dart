import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/screens/screens.dart';
import 'package:project_app/views/views.dart';


// Mock y fakes
class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

class MockLocationBloc extends MockBloc<LocationEvent, LocationState>
    implements LocationBloc {}

class MockMapBloc extends MockBloc<MapEvent, MapState> implements MapBloc {}

void main() {
  late MockTourBloc mockTourBloc;
  late MockLocationBloc mockLocationBloc;
  late MockMapBloc mockMapBloc;

  setUpAll(() {
    // Registro de fakes y valores iniciales
    registerFallbackValue(const LatLng(0, 0)); // LatLng dummy
    registerFallbackValue( EcoCityTour(
      city: '',
      pois: [],
      mode: '',
      userPreferences: [],
      polilynePoints: [],
      duration: 0,
      distance: 0,
      documentId: '',
    ));
  });

  setUp(() {
    // Inicialización de los mocks antes de cada test
    mockTourBloc = MockTourBloc();
    mockLocationBloc = MockLocationBloc();
    mockMapBloc = MockMapBloc();

    when(() => mockLocationBloc.startFollowingUser()).thenAnswer((_) async {});
    when(() => mockMapBloc.drawEcoCityTour(any())).thenAnswer((_) async {});
    when(() => mockMapBloc.moveCamera(any())).thenAnswer((_) async{});
  });

  tearDown(() {
    // Cierre de los mocks después de cada test
    mockTourBloc.close();
    mockLocationBloc.close();
    mockMapBloc.close();
  });

  Widget createTestWidget({
    required EcoCityTour tour,
    required MockLocationBloc locationBloc,
    required MockTourBloc tourBloc,
    required MockMapBloc mapBloc,
  }) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocationBloc>.value(value: locationBloc),
        BlocProvider<TourBloc>.value(value: tourBloc),
        BlocProvider<MapBloc>.value(value: mapBloc),
      ],
      child: MaterialApp(
        home: MapScreen(tour: tour),
      ),
    );
  }

  final testTour = EcoCityTour(
    city: 'Madrid',
    pois: [
      PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Museo del Prado',
        description: 'Un famoso museo de arte en Madrid',
      ),
    ],
    mode: 'walking',
    userPreferences: ['historical', 'parks'],
    polilynePoints: const [
      LatLng(40.4168, -3.7038),
      LatLng(40.4170, -3.7035),
    ],
    duration: 3600,
    distance: 3000,
    documentId: '1234',
  );

  group('MapScreen Tests', () {
    testWidgets('Verifica que los blocs reciben eventos al iniciar la pantalla', (WidgetTester tester) async {
      when(() => mockLocationBloc.state).thenReturn(const LocationState());
      when(() => mockTourBloc.state).thenReturn(const TourState(savedTours: []));
      when(() => mockMapBloc.state).thenReturn(const MapState());

      await tester.pumpWidget(
        createTestWidget(
          tour: testTour,
          locationBloc: mockLocationBloc,
          tourBloc: mockTourBloc,
          mapBloc: mockMapBloc,
        ),
      );

      verify(() => mockLocationBloc.startFollowingUser()).called(1);
      verify(() => mockMapBloc.drawEcoCityTour(testTour)).called(1);
    });

    testWidgets('Renderiza correctamente el estado inicial sin ubicación', (WidgetTester tester) async {
      when(() => mockLocationBloc.state).thenReturn(const LocationState());
      when(() => mockTourBloc.state).thenReturn(const TourState(savedTours: []));
      when(() => mockMapBloc.state).thenReturn(const MapState());

      await tester.pumpWidget(
        createTestWidget(
          tour: testTour,
          locationBloc: mockLocationBloc,
          tourBloc: mockTourBloc,
          mapBloc: mockMapBloc,
        ),
      );

      expect(find.textContaining('loading_eco_city_tour'.tr()), findsOneWidget);
      expect(find.textContaining('waiting_for_gps'.tr()), findsOneWidget);
    });

    testWidgets('Renderiza correctamente el mapa con ubicación', (WidgetTester tester) async {
      when(() => mockLocationBloc.state).thenReturn(const LocationState(
        lastKnownLocation: LatLng(40.4168, -3.7038),
      ));
      when(() => mockTourBloc.state).thenReturn(TourState(ecoCityTour: testTour));
      when(() => mockMapBloc.state).thenReturn(const MapState());

      await tester.pumpWidget(
        createTestWidget(
          tour: testTour,
          locationBloc: mockLocationBloc,
          tourBloc: mockTourBloc,
          mapBloc: mockMapBloc,
        ),
      );

      expect(find.byType(MapView), findsOneWidget);
      expect(find.text('add_poi_prompt'.tr()), findsOneWidget);
    });

  });
}
