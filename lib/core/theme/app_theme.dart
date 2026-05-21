import 'package:flutter/material.dart';

class AppTheme {
  // Cyberpunk Color Palette
  static const Color backgroundDark = Color(0xFF090A0F);
  static const Color surfaceDark = Color(0xFF12141D);
  static const Color neonCyan = Color(0xFF08F7FE);
  static const Color neonPink = Color(0xFFFE53BB);
  static const Color cyberYellow = Color(0xFFF5D300);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPink,
        tertiary: cyberYellow,
        surface: surfaceDark,
      ),
      fontFamily: 'Roboto', // Modern tech font (assumes default or can be customized)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.w900,
          letterSpacing: 2.0,
          shadows: [
            Shadow(color: neonPink, blurRadius: 10),
          ],
        ),
        iconTheme: IconThemeData(color: neonCyan),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 1.1),
        bodyMedium: TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 1.1),
        titleLarge: TextStyle(
          color: Colors.white, 
          fontSize: 20, 
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
      useMaterial3: true,
    );
  }
}
