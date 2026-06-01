import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1100;

  static ScreenType screenTypeOf(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      screenTypeOf(context) == ScreenType.mobile;

  static bool isTablet(BuildContext context) =>
      screenTypeOf(context) == ScreenType.tablet;

  static bool isDesktop(BuildContext context) =>
      screenTypeOf(context) == ScreenType.desktop;

  static double pagePadding(BuildContext context) {
    return switch (screenTypeOf(context)) {
      ScreenType.mobile => 12,
      ScreenType.tablet => 16,
      ScreenType.desktop => 24,
    };
  }

  static double contentGap(BuildContext context) {
    return switch (screenTypeOf(context)) {
      ScreenType.mobile => 12,
      ScreenType.tablet => 16,
      ScreenType.desktop => 20,
    };
  }

  static double deviceCardsHeight(BuildContext context) {
    return switch (screenTypeOf(context)) {
      ScreenType.mobile => 220,
      ScreenType.tablet => 230,
      ScreenType.desktop => 240,
    };
  }

  static double? sidebarWidth(BuildContext context) {
    return switch (screenTypeOf(context)) {
      ScreenType.mobile => null,
      ScreenType.tablet => 72,
      ScreenType.desktop => 80,
    };
  }
}
