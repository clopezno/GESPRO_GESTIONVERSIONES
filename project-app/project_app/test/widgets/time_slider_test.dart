import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:project_app/widgets/widgets.dart';
import 'package:project_app/helpers/helpers.dart';
import '../test_helpers.dart';

void main() {
  group('TimeSlider Widget Tests', () {
    setUp(() async {
      setupTestEnvironment(); // Inicializa el mock de shared_preferences
      await EasyLocalization.ensureInitialized();
    });

    Widget createTestableWidget(Widget child) {
      return EasyLocalization(
        path: 'assets/translations', // Ruta a tus archivos JSON
        supportedLocales: const [Locale('en'), Locale('es')],
        fallbackLocale: const Locale('en'),
        child: MaterialApp(
          home: Scaffold(
            body: child,
          ),
        ),
      );
    }

    testWidgets('Displays correct initial value and labels',
        (WidgetTester tester) async {
      double sliderValue = 15.0;

      await tester.pumpWidget(
        createTestableWidget(
          TimeSlider(
            maxTimeInMinutes: sliderValue,
            onChanged: (value) => sliderValue = value,
            formatTime: formatTime,
          ),
        ),
      );

      // Verifica que los textos de los extremos estén correctos
      expect(find.text('15m'), findsOneWidget);
      expect(find.text('3h'), findsOneWidget);

      // Verifica que el slider inicial tenga el valor correcto
      expect(find.text('15m'), findsWidgets);
    });

    testWidgets('Slider updates value and calls onChanged',
        (WidgetTester tester) async {
      double sliderValue = 15.0;

      await tester.pumpWidget(
        createTestableWidget(
          TimeSlider(
            maxTimeInMinutes: sliderValue,
            onChanged: (value) => sliderValue = value,
            formatTime: formatTime,
          ),
        ),
      );

      // Encuentra el slider
      final sliderFinder = find.byType(Slider);

      // Mueve el slider
      await tester.drag(sliderFinder,
          const Offset(300, 0)); // Mueve el deslizador hacia la derecha
      await tester.pumpAndSettle();

      // Verifica que el valor del slider haya cambiado
      expect(sliderValue, greaterThan(15.0));
    });

    testWidgets('Correctly formats the slider label',
        (WidgetTester tester) async {
      double sliderValue = 75.0; // Representa 1 hora y 15 minutos
      String? capturedLabel;

      await tester.pumpWidget(
        createTestableWidget(
          TimeSlider(
            maxTimeInMinutes: sliderValue,
            onChanged: (value) {
              sliderValue = value;
            },
            formatTime: (minutes) {
              final label = formatTime(minutes);
              capturedLabel = label; // Capturamos el texto del label
              return label;
            },
          ),
        ),
      );

      // Encuentra el slider
      final sliderFinder = find.byType(Slider);

      // Mueve el slider para cambiar el valor
      await tester.drag(sliderFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      // Verifica que el texto del label se haya actualizado correctamente
      expect(capturedLabel, '1 hour 15m');
    });
  });
}
