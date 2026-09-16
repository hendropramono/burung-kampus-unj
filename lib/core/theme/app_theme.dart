import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color greenBrand = Color(0xFF3C5D65);
  static const Color yellowBrand = Color(0xFFE8D84D);
  static const Color blackBrand = Colors.black;
  static const Color whiteBrand = Colors.white;

  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: greenBrand,
        onPrimary: whiteBrand,
        secondary: yellowBrand,
        onSecondary: blackBrand,
        surface: whiteBrand,
        onSurface: blackBrand,
        error: Colors.red.shade700,
        onError: whiteBrand,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: greenBrand,
        foregroundColor: whiteBrand,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellowBrand,
        foregroundColor: blackBrand,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: greenBrand,
          foregroundColor: whiteBrand,
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: greenBrand,
        onPrimary: whiteBrand,
        secondary: yellowBrand,
        onSecondary: blackBrand,
        surface: const Color(0xFF121212),
        onSurface: whiteBrand,
        error: Colors.red.shade400,
        onError: blackBrand,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F1F1F),
        foregroundColor: whiteBrand,
        elevation: 0,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: yellowBrand,
        foregroundColor: blackBrand,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: greenBrand,
          foregroundColor: whiteBrand,
        ),
      ),
    );
  }
}
