// FILE: test/widgets/tag_wrap_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/widgets/tag_wrap.dart';
import 'package:project_app/helpers/icon_helpers.dart';

void main() {
  testWidgets('TagWrap displays all tags and responds to selection',
      (WidgetTester tester) async {
    // Define the initial state of selectedPreferences
    final Map<String, bool> selectedPreferences = {
      'nature': false,
      'museums': false,
      'gastronomy': false,
      'sports': false,
      'shopping': false,
      'history': false,
    };

    // Define a function to handle tag selection
    void onTagSelected(String key) {
      selectedPreferences[key] = !selectedPreferences[key]!;
    }

    // Build the TagWrap widget
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TagWrap(
            selectedPreferences: selectedPreferences,
            onTagSelected: onTagSelected,
          ),
        ),
      ),
    );

    // Verify that all tags are displayed
    for (String key in userPreferences.keys) {
      expect(find.text(key), findsOneWidget);
    }

    // Tap on the first tag and verify that the selection state changes
    await tester.tap(find.text('nature'));
    await tester.pumpAndSettle();

    expect(selectedPreferences['nature'], true);
  });
}
