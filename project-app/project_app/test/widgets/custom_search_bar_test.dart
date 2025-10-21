import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:project_app/delegates/search_destination_delegate.dart';
import 'package:project_app/widgets/custom_search_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockSearchDestinationDelegate extends Mock
    implements SearchDestinationDelegate {}

class FakeBuildContext extends Fake implements BuildContext {}

void main() {
  setUpAll(() {
    // Registrar valores de respaldo necesarios
    registerFallbackValue(FakeBuildContext());
  });

  setUp(() async {
    // Simula la inicialización de dotenv
    dotenv.testLoad(fileInput: '''
    GOOGLE_PLACES_API_KEY=fake-api-key
    ''');
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: Scaffold(
        body: CustomSearchBar(),
      ),
    );
  }

  group('CustomSearchBar Tests', () {
    testWidgets('Renderiza correctamente el texto inicial',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar que el texto inicial está presente
      expect(find.text('add_poi_prompt'.tr()), findsOneWidget);
    });

    testWidgets('Abre SearchDelegate al hacer tap en la barra',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Simula el tap en el GestureDetector
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Verifica que se abre un modal para el SearchDelegate
      expect(find.byType(ModalBarrier), findsOneWidget);
      expect(find.text('search_place_hint'.tr()), findsOneWidget);
    });

    testWidgets('Muestra un diseño adecuado', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verifica que el diseño contiene los elementos esperados
      final searchBar = find.byType(Container);
      expect(searchBar, findsNWidgets(2)); // Contenedor exterior e interior

      // Verifica que la decoración incluye borde redondeado y sombra
      final Container innerContainer =
          tester.widget(find.byType(Container).last);
      final BoxDecoration decoration =
          innerContainer.decoration as BoxDecoration;

      expect(decoration.color, Colors.white);
      expect(decoration.borderRadius, BorderRadius.circular(100));
      expect(decoration.boxShadow, isNotNull);
    });
  });
}
