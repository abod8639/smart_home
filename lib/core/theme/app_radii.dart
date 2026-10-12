import 'package:flutter/material.dart';

/// Centralized border radius design tokens for consistent curvature across the app.
abstract final class AppRadii {
  // ── Raw Radius Values (double) ─────────────────────────────────────────────
  /// Extra small radius (4.0) - tags, indicators, micro-badges.
  static const double xsValue = 4.0;

  /// Small radius (8.0) - chips, small buttons, input fields.
  static const double smValue = 8.0;

  /// Medium radius (12.0) - buttons, items, list tiles.
  static const double mdValue = 12.0;

  /// Large radius (16.0) - dialogs, sheets, medium cards.
  static const double lgValue = 16.0;

  /// Extra large radius (20.0) - prominent cards, sliders.
  static const double xlValue = 20.0;

  /// 2X Large radius (24.0) - standard dashboard cards, glass containers.
  static const double xxlValue = 24.0;

  /// Round radius (32.0) - navigation bars, floating pills.
  static const double roundValue = 32.0;

  /// Fully rounded / pill (999.0) - badges, circular buttons.
  static const double fullValue = 999.0;

  // ── Radius Instances ───────────────────────────────────────────────────────
  static const Radius radiusXs = Radius.circular(xsValue);
  static const Radius radiusSm = Radius.circular(smValue);
  static const Radius radiusMd = Radius.circular(mdValue);
  static const Radius radiusLg = Radius.circular(lgValue);
  static const Radius radiusXl = Radius.circular(xlValue);
  static const Radius radiusXxl = Radius.circular(xxlValue);
  static const Radius radiusRound = Radius.circular(roundValue);
  static const Radius radiusFull = Radius.circular(fullValue);

  // ── BorderRadius Instances ─────────────────────────────────────────────────
  static const BorderRadius xs = BorderRadius.all(radiusXs);
  static const BorderRadius sm = BorderRadius.all(radiusSm);
  static const BorderRadius md = BorderRadius.all(radiusMd);
  static const BorderRadius lg = BorderRadius.all(radiusLg);
  static const BorderRadius xl = BorderRadius.all(radiusXl);
  static const BorderRadius xxl = BorderRadius.all(radiusXxl);
  static const BorderRadius round = BorderRadius.all(radiusRound);
  static const BorderRadius full = BorderRadius.all(radiusFull);

  // ── Shape Borders (RoundedRectangleBorder) ─────────────────────────────────
  static const RoundedRectangleBorder shapeXs =
      RoundedRectangleBorder(borderRadius: xs);
  static const RoundedRectangleBorder shapeSm =
      RoundedRectangleBorder(borderRadius: sm);
  static const RoundedRectangleBorder shapeMd =
      RoundedRectangleBorder(borderRadius: md);
  static const RoundedRectangleBorder shapeLg =
      RoundedRectangleBorder(borderRadius: lg);
  static const RoundedRectangleBorder shapeXl =
      RoundedRectangleBorder(borderRadius: xl);
  static const RoundedRectangleBorder shapeXxl =
      RoundedRectangleBorder(borderRadius: xxl);
  static const RoundedRectangleBorder shapeRound =
      RoundedRectangleBorder(borderRadius: round);
  static const RoundedRectangleBorder shapeFull =
      RoundedRectangleBorder(borderRadius: full);

  // ── Dynamic Builders ───────────────────────────────────────────────────────
  /// Creates a [BorderRadius] with uniform radius of [radius].
  static BorderRadius all(double radius) =>
      BorderRadius.all(Radius.circular(radius));

  /// Creates a [BorderRadius] with top-only corners rounded by [radius].
  static BorderRadius top(double radius) => BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );

  /// Creates a [BorderRadius] with bottom-only corners rounded by [radius].
  static BorderRadius bottom(double radius) => BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
}
