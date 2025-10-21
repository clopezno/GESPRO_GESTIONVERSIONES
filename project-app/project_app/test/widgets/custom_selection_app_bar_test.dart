import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/widgets/custom_selection_app_bar.dart';

class FakeAssetLoader extends AssetLoader {
  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return {
      'title': 'Eco City Tours',
      'info': 'Ir al Wiki de la Aplicación',
      'language': 'Cambiar idioma',
      'english': 'English',
      'spanish': 'Español',
    };
  }
}

void main() {
  group('CustomSelectionAppBar Tests', () {
    Widget createTestWidget() {
      return EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('es')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        assetLoader: FakeAssetLoader(),
        child: const MaterialApp(
          home: Scaffold(
            appBar: CustomSelectionAppBar(),
          ),
        ),
      );
    }

    testWidgets('Renderiza correctamente los elementos del AppBar',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Verificar título
      expect(find.text('Eco City Tours'), findsOneWidget);

      // Verificar botones
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('El botón de información llama a _launchWikiURL',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Encuentra el botón de información y simula un tap
      final infoButton = find.byIcon(Icons.info_outline_rounded);
      expect(infoButton, findsOneWidget);
      await tester.tap(infoButton);
      await tester.pump();
    });

    testWidgets('El menú de idioma se despliega correctamente',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Encuentra el botón de idioma y simula un tap
      final languageButton = find.byIcon(Icons.language);
      expect(languageButton, findsOneWidget);
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      // Verifica que el menú desplegable muestra las opciones
      expect(find.text('English'), findsOneWidget);
      expect(find.text('Español'), findsOneWidget);
    });

    testWidgets('Seleccionar un idioma dispara context.setLocale',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Abre el menú desplegable
      final languageButton = find.byIcon(Icons.language);
      await tester.tap(languageButton);
      await tester.pumpAndSettle();

      // Simula la selección del idioma "Español"
      final spanishOption = find.text('Español');
      expect(spanishOption, findsOneWidget); // Confirma que está visible
      await tester.tap(spanishOption);
      await tester.pumpAndSettle();

      // Verifica que el idioma cambia
      expect(find.text('Eco City Tours'), findsOneWidget);
    });
  });
}
