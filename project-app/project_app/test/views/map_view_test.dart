import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

import 'package:project_app/blocs/map/map_bloc.dart';
import 'package:project_app/views/map_view.dart';

// Crear un mock del MapBloc
class MockMapBloc extends Mock implements MapBloc {}

// Crear un mock del GoogleMapController
class MockGoogleMapController extends Mock implements GoogleMapController {}

// Crear un Fake para MapEvent para poder usar `any()` en los tests
class FakeMapEvent extends Fake implements MapEvent {}

void main() {
  late MockMapBloc mockMapBloc;
  late LatLng initialPosition;
  late Set<Polyline> polylines;
  late Set<Marker> markers;

  setUpAll(() {
    // Registrar el Fake de MapEvent para mocktail
    registerFallbackValue(FakeMapEvent());
  });

  setUp(() {
    mockMapBloc = MockMapBloc();
    
    // Mockear el stream para prevenir errores en el BlocProvider
    when(() => mockMapBloc.stream).thenAnswer((_) => const Stream.empty());
    
    initialPosition = const LatLng(37.7749, -122.4194); // Coordenadas de ejemplo
    polylines = {
      const Polyline(
        polylineId: PolylineId('test_polyline'),
        points: [LatLng(37.7749, -122.4194), LatLng(37.8049, -122.4294)],
        color: Colors.blue,
        width: 5,
      ),
    };
    markers = {
      const Marker(
        markerId: MarkerId('test_marker'),
        position: LatLng(37.7749, -122.4194),
        infoWindow: InfoWindow(title: 'Test Marker'),
      ),
    };
  });

  Widget createTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: BlocProvider<MapBloc>.value(
          value: mockMapBloc,
          child: MapView(
            initialPosition: initialPosition,
            polylines: polylines,
            markers: markers,
          ),
        ),
      ),
    );
  }

  testWidgets('MapView renders correctly and initializes map', (tester) async {
    await tester.pumpWidget(createTestableWidget());

    // Verifica si el widget GoogleMap está presente en el árbol de widgets
    expect(find.byType(GoogleMap), findsOneWidget);

    // Simula el evento onMapCreated y verifica que se haya enviado el evento OnMapInitializedEvent
    final mapController = Completer<GoogleMapController>();
    mapController.complete(MockGoogleMapController()); // Completa el `Completer` con un mock del controlador

    await tester.runAsync(() async {
      final onMapCreated = tester.widget<GoogleMap>(find.byType(GoogleMap)).onMapCreated;
      onMapCreated!(await mapController.future); // Ejecuta el callback onMapCreated con el mock del controlador
      await tester.pumpAndSettle();
    });

    verify(() => mockMapBloc.add(any(that: isA<OnMapInitializedEvent>()))).called(1);
  });

  testWidgets('Updates map center on camera move', (tester) async {
    await tester.pumpWidget(createTestableWidget());

    final googleMapFinder = find.byType(GoogleMap);
    expect(googleMapFinder, findsOneWidget);

    // Simula el movimiento de la cámara
    final onCameraMove = tester.widget<GoogleMap>(googleMapFinder).onCameraMove;
    const newPosition = CameraPosition(target: LatLng(37.8049, -122.4294));

    onCameraMove!(newPosition);

    // Verifica que el centro del mapa en el Bloc sea actualizado
    verify(() => mockMapBloc.mapCenter = newPosition.target).called(1);
  });

  testWidgets('Stops following user on map move', (tester) async {
    await tester.pumpWidget(createTestableWidget());

    // Busca el widget Listener y simula el movimiento en el mapa
    final listenerFinder = find.byType(Listener);
    expect(listenerFinder, findsWidgets); // Verifica que existen varios Listeners

    // Encuentra el Listener que tiene el onPointerMove
    final listener = tester.widgetList<Listener>(listenerFinder).where((l) => l.onPointerMove != null).first;
    listener.onPointerMove!(const PointerMoveEvent());

    // Verifica que el evento OnStopFollowingUserEvent sea añadido al Bloc
    verify(() => mockMapBloc.add(const OnStopFollowingUserEvent())).called(1);
  });
}
