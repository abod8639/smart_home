import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/widgets/stat_badge.dart';

void main() {
  group('StatBadge Widget Tests', () {
    testWidgets('renders horizontal stat with icon, value, and label', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatBadge(
              icon: Icons.ac_unit,
              value: '22°C',
              label: 'Target Temp',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.text('22°C'), findsOneWidget);
      expect(find.text('Target Temp'), findsOneWidget);

      await tester.tap(find.byType(StatBadge));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders vertical stat chip properly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatBadge(
              value: '95%',
              label: 'Filter Status',
              isVertical: true,
            ),
          ),
        ),
      );

      expect(find.text('95%'), findsOneWidget);
      expect(find.text('Filter Status'), findsOneWidget);
    });
  });
}
