import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/widgets/glass_switch.dart';

void main() {
  group('GlassSwitch Widget Tests', () {
    testWidgets('renders properly when switch is off', (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassSwitch(
              onToggle: () => toggled = true,
              isDeviceOn: false,
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);

      await tester.tap(find.byType(GlassSwitch));
      await tester.pump();

      expect(toggled, isTrue);
    });

    testWidgets('renders properly when switch is on', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassSwitch(
              onToggle: () {},
              isDeviceOn: true,
            ),
          ),
        ),
      );

      expect(find.byType(GlassSwitch), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows progress indicator and ignores taps when isPending is true', (tester) async {
      bool toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassSwitch(
              onToggle: () => toggled = true,
              isDeviceOn: false,
              isPending: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.tap(find.byType(GlassSwitch));
      await tester.pump();

      expect(toggled, isFalse);
    });
  });
}
