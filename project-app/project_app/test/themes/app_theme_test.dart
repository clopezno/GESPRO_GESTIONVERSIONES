import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project_app/themes/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('lightTheme should have correct primary color', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.colorScheme.primary, const Color(0xFF00A86B));
    });

    test('lightTheme should have correct secondary color', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.colorScheme.secondary, const Color(0xFF0047AB));
    });

    test('lightTheme should use white for scaffold background', () {
      final lightTheme = AppTheme.lightTheme;
      expect(lightTheme.scaffoldBackgroundColor, Colors.grey[200]);
    });

   
  });
}
