import 'package:flutter/material.dart';

/// Clase que define los temas personalizados de la aplicación.
///
/// Contiene los colores principales y secundarios, así como configuraciones
/// predeterminadas para los widgets principales como botones, textos y AppBar.
class AppTheme {
  /// Color primario de la aplicación (verde).
  static const primary = Color(0xFF00A86B);

  /// Color secundario de la aplicación (azul).
  static const secundary = Color(0xFF0047AB);

  /// Tema claro de la aplicación.
  ///
  /// Define el esquema de colores, estilos de texto, botones, y otros componentes
  /// visuales utilizando el color primario y secundario.
  static ThemeData get lightTheme {
    return ThemeData(
      // Esquema de colores
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secundary,
        surface: Colors.white, // Color de fondo de superficies
      ),
      scaffoldBackgroundColor: Colors.grey[200], // Fondo del Scaffold

      // Estilos de texto
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 14,
          color: Colors.black54,
        ),
      ),

      // Estilos para botones elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary, // Color de fondo del botón
          foregroundColor: Colors.white, // Color del texto del botón
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8), // Bordes redondeados
          ),
        ),
      ),

      // Estilo del AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: primary, // Color de fondo del AppBar
        elevation: 4, // Elevación/sombra del AppBar
        titleTextStyle: TextStyle(
          color: Colors.white, // Color del texto del título
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
