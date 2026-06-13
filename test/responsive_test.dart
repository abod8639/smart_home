import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/utils/responsive.dart';

void main() {
  group('Responsive Utils Tests', () {
    testWidgets('identifies mobile screen correctly', (tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.screenTypeOf(context), ScreenType.mobile);
              expect(Responsive.isMobile(context), isTrue);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isFalse);
              expect(Responsive.pagePadding(context), 12.0);
              expect(Responsive.sidebarWidth(context), isNull);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('identifies tablet screen correctly', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.screenTypeOf(context), ScreenType.tablet);
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isTrue);
              expect(Responsive.isDesktop(context), isFalse);
              expect(Responsive.pagePadding(context), 16.0);
              expect(Responsive.sidebarWidth(context), 72.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('identifies desktop screen correctly', (tester) async {
      tester.view.physicalSize = const Size(1200, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.screenTypeOf(context), ScreenType.desktop);
              expect(Responsive.isMobile(context), isFalse);
              expect(Responsive.isTablet(context), isFalse);
              expect(Responsive.isDesktop(context), isTrue);
              expect(Responsive.pagePadding(context), 24.0);
              expect(Responsive.sidebarWidth(context), 80.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('returns correct content gap and device cards height', (tester) async {
       tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(Responsive.contentGap(context), 12.0);
              expect(Responsive.deviceCardsHeight(context), 220.0);
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
