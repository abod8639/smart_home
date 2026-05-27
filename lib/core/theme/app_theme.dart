import 'package:flutter/material.dart';

class AppTheme {
  // Premium Dark Color Palette
  static const Color backgroundDark = Color(0xFF101014);
  static const Color cardBackground = Color(0xFF1E1E24);
  static const Color primaryBlue = Color(0xFF00E5FF);
  static const Color primaryPurple = Color(0xFFA135FF);
  static const Color textWhite = Color(0xFFF5F5F5);
  static const Color textGrey = Color(0xFF8B8B8D);
  static const Color accentCyan = Color(0xFF00E5FF);

  // Legacy compatibility colors
  static const Color neonCyan = Color(0xFF08F7FE);
  static const Color neonPink = Color(0xFFFE53BB);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      primaryColor: Color(0xFF00E5FF),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF00E5FF),
        secondary: primaryPurple,
        surface: cardBackground,
      ),
      fontFamily:
          'Roboto', // Defaulting to Roboto, but simulating a sleek sans-serif
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(color: textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: textGrey, fontSize: 14),
        labelLarge: TextStyle(color: textGrey, fontSize: 12),
      ),
      useMaterial3: true,
    );
  }
}
