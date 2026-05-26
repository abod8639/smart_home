import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/main.dart';

void main() {
  testWidgets('Smart Home Dashboard App smoke test', (WidgetTester tester) async {
    // Set a tablet/desktop screen size (1440x900)
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pumpAndSettle();

    // Verify that the main rooms from our mock data are present on screen.
    expect(find.text('Bedroom'), findsOneWidget);
    expect(find.text('Living room'), findsOneWidget);
  });
}
