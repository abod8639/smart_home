import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Centralized box shadow design tokens for consistent depth and elevation across the app.
abstract final class AppShadows {
  /// No shadow.
  static const List<BoxShadow> none = [];

  /// Subtle shadow for micro elements, chips, tags.
  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  /// Standard card elevation shadow for containers and dashboard widgets.
  static List<BoxShadow> get card => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  /// Elevated shadow for floating elements, dropdowns, hovered items.
  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 16,
          spreadRadius: 1,
          offset: const Offset(0, 6),
        ),
      ];

  /// Modal and dialog deep shadow.
  static List<BoxShadow> get modal => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.50),
          blurRadius: 28,
          spreadRadius: 2,
          offset: const Offset(0, 12),
        ),
      ];

  /// Soft glow effect around IoT device indicators, active switches, or branded items.
  static List<BoxShadow> glow(
    Color color, {
    double blur = 12.0,
    double spread = 0.0,
    double alpha = 0.35,
  }) =>
      [
        BoxShadow(
          color: color.withValues(alpha: alpha),
          blurRadius: blur,
          spreadRadius: spread,
        ),
      ];

  /// Primary neon/accent glow using [AppTheme.primaryBlue].
  static List<BoxShadow> get primaryGlow => glow(AppTheme.primaryBlue);

  /// Secondary accent glow using [AppTheme.primaryPurple].
  static List<BoxShadow> get secondaryGlow => glow(AppTheme.primaryPurple);

  /// Cyan accent glow using [AppTheme.accentCyan].
  static List<BoxShadow> get cyanGlow => glow(AppTheme.accentCyan);
}
