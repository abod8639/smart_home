import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/widgets/collapsible_card.dart';

void main() {
  group('CollapsibleCard Widget Tests', () {
    testWidgets('renders title, subtitle, icon, and expands on tap', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleCard(
              title: 'AC Settings',
              subtitle: 'Configure modes and fan',
              icon: Icons.ac_unit,
              child: Text('Expanded Content Details'),
            ),
          ),
        ),
      );

      expect(find.text('AC Settings'), findsOneWidget);
      expect(find.text('Configure modes and fan'), findsOneWidget);
      expect(find.byIcon(Icons.ac_unit), findsOneWidget);

      // Initially closed (firstChild is SizedBox.shrink)
      expect(find.text('Expanded Content Details'), findsNothing);

      // Tap to expand
      await tester.tap(find.text('AC Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Expanded Content Details'), findsOneWidget);

      // Tap to collapse
      await tester.tap(find.text('AC Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Expanded Content Details'), findsNothing);
    });

    testWidgets('respects initiallyExpanded property', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CollapsibleCard(
              title: 'Preset Card',
              subtitle: 'Open by default',
              icon: Icons.tune,
              initiallyExpanded: true,
              child: Text('Already Open'),
            ),
          ),
        ),
      );

      expect(find.text('Already Open'), findsOneWidget);
    });
  });
}
