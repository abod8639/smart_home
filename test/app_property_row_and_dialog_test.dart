import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/app_dialog.dart';
import 'package:smart_home/core/widgets/app_property_row.dart';

void main() {
  group('AppPropertyRow Widget Tests', () {
    testWidgets('renders label and value correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPropertyRow(
              label: 'Total Devices',
              value: '5 devices',
            ),
          ),
        ),
      );

      expect(find.text('Total Devices'), findsOneWidget);
      expect(find.text('5 devices'), findsOneWidget);
    });

    testWidgets('renders trailing widget when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppPropertyRow(
              label: 'Status',
              value: 'Online',
              trailing: Icon(Icons.check, key: Key('status_icon')),
            ),
          ),
        ),
      );

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.byKey(const Key('status_icon')), findsOneWidget);
    });
  });

  group('AppDialog Widget Tests', () {
    testWidgets('renders standard AppDialog with title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppDialog.show(
                      context: context,
                      builder: (ctx) => AppDialog.standard(
                        title: 'Test Dialog',
                        icon: Icons.info_outline,
                        content: const Text('Dialog body message'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('OK'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Dialog body message'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog body message'), findsNothing);
    });
  });
}
