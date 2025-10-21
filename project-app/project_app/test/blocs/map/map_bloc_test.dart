import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';


class MockGoogleMapController extends Mock implements GoogleMapController {}
class MockLocationBloc extends Mock implements LocationBloc {}
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  // Asegúrate de inicializar los bindings de Flutter antes de los tests
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocationBloc locationBloc;
  late MapBloc mapBloc;

  setUp(() {
    locationBloc = MockLocationBloc();
    
    // Simula el estado inicial de LocationBloc
    when(() => locationBloc.state).thenReturn(const LocationState(
      lastKnownLocation: LatLng(0, 0),  // Configura el valor inicial del LocationBloc
      myLocationHistory: [LatLng(0, 0)], // Historial de ubicaciones
    ));
    
    // Mock del stream de LocationBloc
    when(() => locationBloc.stream).thenAnswer((_) => const Stream.empty());

    
    mapBloc = MapBloc(locationBloc: locationBloc);
  });

  tearDown(() {
    mapBloc.close();
  });

  group('MapBloc Tests', () {
    test('Initial state is MapState with default values', () {
      expect(mapBloc.state, const MapState());
    });

    blocTest<MapBloc, MapState>(
      'emits [MapInitialized] when OnMapInitializedEvent is added',
      build: () => mapBloc,
      act: (bloc) => bloc.add(OnMapInitializedEvent(
        MockGoogleMapController(),  // Mock del GoogleMapController
        MockBuildContext(),         // Mock del BuildContext
      )),
      expect: () => [
        isA<MapState>()
          .having((state) => state.isMapInitialized, 'isMapInitialized', true)
          .having((state) => state.mapContext, 'mapContext', isA<BuildContext>()),
      ],
    );

    blocTest<MapBloc, MapState>(
      'emits [isFollowingUser: true] when OnStartFollowingUserEvent is added',
      build: () => mapBloc,
      act: (bloc) => bloc.add(const OnStartFollowingUserEvent()),
      expect: () => [
        isA<MapState>()
          .having((state) => state.isFollowingUser, 'isFollowingUser', true),
      ],
    );


  });
}