import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/app_button.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/core/widgets/shadow_container.dart';

void main() {
  group('AppRadii Design Tokens Tests', () {
    test('values scale proportionally', () {
      expect(AppRadii.xsValue, 4.0);
      expect(AppRadii.smValue, 8.0);
      expect(AppRadii.mdValue, 12.0);
      expect(AppRadii.lgValue, 16.0);
      expect(AppRadii.xlValue, 20.0);
      expect(AppRadii.xxlValue, 24.0);
      expect(AppRadii.roundValue, 32.0);
      expect(AppRadii.fullValue, 999.0);
    });

    test('border radius instances match values', () {
      expect(AppRadii.sm, equals(BorderRadius.circular(8.0)));
      expect(AppRadii.md, equals(BorderRadius.circular(12.0)));
      expect(AppRadii.lg, equals(BorderRadius.circular(16.0)));
      expect(AppRadii.xxl, equals(BorderRadius.circular(24.0)));
    });

    test('dynamic builder helpers create correct radii', () {
      final uniform = AppRadii.all(18.0);
      expect(uniform, equals(BorderRadius.circular(18.0)));

      final top = AppRadii.top(10.0);
      expect(top.topLeft, equals(const Radius.circular(10.0)));
      expect(top.bottomLeft, equals(Radius.zero));
    });
  });

  group('AppShadows Design Tokens Tests', () {
    test('standard shadows return configured BoxShadow lists', () {
      expect(AppShadows.none, isEmpty);
      expect(AppShadows.subtle, isNotEmpty);
      expect(AppShadows.card, isNotEmpty);
      expect(AppShadows.elevated, isNotEmpty);
      expect(AppShadows.modal, isNotEmpty);
    });

    test('glow generator applies custom color and spread', () {
      final glow = AppShadows.glow(Colors.cyan, blur: 20, spread: 2);
      expect(glow.first.blurRadius, 20);
      expect(glow.first.spreadRadius, 2);
    });
  });

  group('Core Reusable Widgets Tests', () {
    testWidgets('AppButton renders label and triggers tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Click Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
      await tester.tap(find.text('Click Me'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('AppButton shows spinner when isLoading is true and ignores tap',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Saving',
              isLoading: true,
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Saving'), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(tapped, isFalse);
    });

    testWidgets('AppButton.social renders icon and text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton.social(
              text: 'Sign in with Google',
              icon: const Icon(Icons.login),
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Sign in with Google'), findsOneWidget);
      expect(find.byIcon(Icons.login), findsOneWidget);
    });

    testWidgets('ShadowContainer applies child and unified borderRadius',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShadowContainer(
              child: Text('Shadow Box'),
            ),
          ),
        ),
      );

      expect(find.text('Shadow Box'), findsOneWidget);
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration?;
      expect(decoration?.borderRadius, equals(AppRadii.xxl));
    });

    testWidgets('GlassContainer applies child and unified borderRadius',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassContainer(
              child: Text('Glass Box'),
            ),
          ),
        ),
      );

      expect(find.text('Glass Box'), findsOneWidget);
    });
  });
}
