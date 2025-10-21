import 'package:bloc_test/bloc_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/blocs/tour/tour_bloc.dart';
import 'package:project_app/models/models.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:easy_localization/easy_localization.dart';

import '../test_helpers.dart';

class MockTourBloc extends MockBloc<TourEvent, TourState> implements TourBloc {}

void main() {
  late MockTourBloc mockTourBloc;

  setUp(() async {
    mockTourBloc = MockTourBloc();
    setupTestEnvironment(); // Inicializa el mock de shared_preferences
    EasyLocalization.logger.enableLevels = [];
    await EasyLocalization
        .ensureInitialized(); // Inicializa `easy_localization`
  });

  tearDown(() {
    mockTourBloc.close();
  });

  Widget createTestWidget(PointOfInterest poi) {
    return EasyLocalization(
      path: 'assets/translations', // Ruta de tus archivos JSON
      supportedLocales: const [Locale('en'), Locale('es')],
      fallbackLocale: const Locale('en'),
      child: BlocProvider<TourBloc>.value(
        value: mockTourBloc,
        child: MaterialApp(
          home: Scaffold(
            body: CustomBottomSheet(poi: poi),
          ),
        ),
      ),
    );
  }

  group('CustomBottomSheet tests', () {
    final testPoi = PointOfInterest(
      gps: const LatLng(40.4168, -3.7038), // Coordenadas de Madrid como ejemplo
      name: 'Test POI',
      description: 'This is a test POI.',
      url: 'https://example.com',
      imageUrl: 'https://example.com/image.jpg',
      rating: 4.5,
      address: '123 Main St',
      userRatingsTotal: 200,
    );

    testWidgets('Renderiza el título correctamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testPoi));

      expect(find.text('Test POI'), findsOneWidget);
    });

    testWidgets('Renderiza la imagen si la URL está disponible',
        (WidgetTester tester) async {
      final poiWithImage = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
        imageUrl: 'https://example.com/image.jpg',
      );

      await tester.pumpWidget(createTestWidget(poiWithImage));

      // Verifica que el CachedNetworkImage se muestra
      expect(find.byType(CachedNetworkImage), findsOneWidget);
    });

    testWidgets('Renderiza dirección si está disponible',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testPoi));

      expect(find.text('123 Main St'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('Renderiza rating si está disponible',
        (WidgetTester tester) async {
      final poiWithRating = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
        rating: 4.5,
        userRatingsTotal: 200,
      );

      await tester.pumpWidget(createTestWidget(poiWithRating));

      // Verifica que el RatingBarIndicator se renderiza
      expect(find.byType(RatingBarIndicator), findsOneWidget);

      // Verifica el texto del rating dinámicamente
      expect(
        find.byWidgetPredicate((widget) =>
            widget is Text && widget.data?.contains('(200 reviews)') == true),
        findsOneWidget,
      );
    });

    testWidgets('Renderiza descripción si está disponible',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testPoi));

      expect(find.text('description'.tr()), findsOneWidget);
      expect(find.text('This is a test POI.'), findsOneWidget);
    });

    testWidgets('Renderiza enlace si está disponible',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testPoi));

      expect(find.text('visit_website'.tr()), findsOneWidget);
    });

    testWidgets('Renderiza botón de eliminar POI y dispara evento al pulsarlo',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(testPoi));

      expect(find.text('remove_from_tour'.tr()), findsOneWidget);

      await tester.tap(find.text('remove_from_tour'.tr()));
      await tester.pumpAndSettle();

      verify(() => mockTourBloc.add(OnRemovePoiEvent(poi: testPoi))).called(1);
    });

    testWidgets('No renderiza imagen si no hay URL disponible',
        (WidgetTester tester) async {
      final poiWithoutImage = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
      );
      await tester.pumpWidget(createTestWidget(poiWithoutImage));

      expect(find.byType(CachedNetworkImage), findsNothing);
    });

    testWidgets('No renderiza rating si no está disponible',
        (WidgetTester tester) async {
      final poiWithoutRating = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
      );
      await tester.pumpWidget(createTestWidget(poiWithoutRating));

      expect(find.byType(RatingBarIndicator), findsNothing);
      expect(find.textContaining('/ 5.0'), findsNothing);
    });

    testWidgets('No renderiza descripción si no está disponible',
        (WidgetTester tester) async {
      final poiWithoutDescription = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
      );
      await tester.pumpWidget(createTestWidget(poiWithoutDescription));

      expect(find.text('description'.tr()), findsNothing);
    });

    testWidgets('No renderiza enlace si no está disponible',
        (WidgetTester tester) async {
      final poiWithoutUrl = PointOfInterest(
        gps: const LatLng(40.4168, -3.7038),
        name: 'Test POI',
      );
      await tester.pumpWidget(createTestWidget(poiWithoutUrl));

      expect(find.text('visit_website'.tr()), findsNothing);
    });
  });
}
