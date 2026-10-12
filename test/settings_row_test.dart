import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/widgets/settings_row.dart';

void main() {
  group('SettingsRow Widget Tests', () {
    testWidgets('renders title, subtitle, icon, and trailing widget', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SettingsRow(
              icon: Icons.wifi,
              title: 'Wi-Fi Network',
              subtitle: 'Connected to HomeNet',
              trailing: const Icon(Icons.chevron_right),
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Wi-Fi Network'), findsOneWidget);
      expect(find.text('Connected to HomeNet'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Wi-Fi Network'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });
}
