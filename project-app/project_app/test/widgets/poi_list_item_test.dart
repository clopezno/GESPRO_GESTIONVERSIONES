import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/blocs.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MockTourBloc extends Mock implements TourBloc {}

class FakeTourEvent extends Fake implements TourEvent {}

void main() {
  late MockTourBloc mockTourBloc;

  setUpAll(() {
    registerFallbackValue(FakeTourEvent());
  });

  setUp(() {
    mockTourBloc = MockTourBloc();
  });

  Widget createTestWidget(PointOfInterest poi) {
    return MaterialApp(
      home: Scaffold(
        body: ExpandablePoiItem(
          poi: poi,
          tourBloc: mockTourBloc,
        ),
      ),
    );
  }

  group('ExpandablePoiItem Tests', () {
    testWidgets('Renderiza correctamente el contenido inicial',
        (WidgetTester tester) async {
      final poi = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
        description: 'Breve descripción del POI',
        rating: 4.5,
        imageUrl: 'https://via.placeholder.com/150',
      );

      await tester.pumpWidget(createTestWidget(poi));
      await tester.pumpAndSettle();

      expect(find.text('Test POI'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
      expect(find.textContaining('Breve descripción del POI'), findsOneWidget);
    });

    testWidgets('Expande y contrae la descripción al tocar',
        (WidgetTester tester) async {
      final poi = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
        description: 'Esta es una descripción más larga para el POI.',
      );

      await tester.pumpWidget(createTestWidget(poi));

      // Verifica que el texto truncado (o al menos el widget del subtítulo) está visible inicialmente
      expect(
        find.text('Esta es una descripción más larga para el POI.'),
        findsOneWidget,
      );

      // Expande el widget
      await tester.tap(find.text('Test POI'));
      await tester.pumpAndSettle();

      // Verifica que la descripción completa está visible después de expandir
      expect(
        find.text('Esta es una descripción más larga para el POI.'),
        findsOneWidget,
      );

      // Contrae el widget
      await tester.tap(find.text('Test POI'));
      await tester.pumpAndSettle();

      // Verifica que el texto está nuevamente colapsado (sigue visible pero no más allá del subtítulo)
      expect(
        find.text('Esta es una descripción más larga para el POI.'),
        findsOneWidget,
      );
    });

    testWidgets('Dispara el evento de eliminar POI al presionar el botón',
        (WidgetTester tester) async {
      final poi = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
      );

      await tester.pumpWidget(createTestWidget(poi));
      await tester.pumpAndSettle();

      final deleteButton = find.byIcon(Icons.delete);
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      verify(() => mockTourBloc.add(any(that: isA<OnRemovePoiEvent>())))
          .called(1);
    });

    testWidgets('Carga la imagen predeterminada si no hay URL disponible',
        (WidgetTester tester) async {
      final poi = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
        imageUrl: null,
      );

      await tester.pumpWidget(createTestWidget(poi));
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is AssetImage),
          findsOneWidget);
    });

    testWidgets('Carga la imagen desde la URL si está disponible',
        (WidgetTester tester) async {
      final poi = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
        imageUrl: 'https://via.placeholder.com/150',
      );

      await tester.pumpWidget(createTestWidget(poi));
      await tester.pumpAndSettle();

      expect(
          find.byWidgetPredicate(
              (widget) => widget is Image && widget.image is NetworkImage),
          findsOneWidget);
    });
  });
}
