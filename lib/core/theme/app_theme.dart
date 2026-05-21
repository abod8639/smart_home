import 'package:flutter/material.dart';

class AppTheme {
  static const Color backgroundDark = Color(0xFF0F111A);
  static const Color neonBlue = Color(0xFF00F0FF);
  static const Color neonPurple = Color(0xFFB026FF);
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% white

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: neonBlue,
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPurple,
        surface: backgroundDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
        titleLarge: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      useMaterial3: true,
    );
  }
}
