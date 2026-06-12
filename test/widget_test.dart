import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/main.dart';

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'MQTT_BROKER_URL=broker.hivemq.com');
  });

  testWidgets('Smart Home Dashboard App smoke test', (WidgetTester tester) async {
    // Set a tablet/desktop screen size (1440x900)
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(() => Get.reset());

    // Build our app and trigger a frame.
    await tester.pumpWidget(const SmartHomeApp());
    await tester.pumpAndSettle();

    // Verify that the main rooms from our mock data are present on screen.
    expect(find.text('Bedroom'), findsOneWidget);

    final roomsListView = find.descendant(
      of: find.byType(DashboardMainView),
      matching: find.byType(Scrollable),
    ).first;
    await tester.scrollUntilVisible(
      find.text('Living room'),
      50.0,
      scrollable: roomsListView,
    );
    await tester.pumpAndSettle();

    expect(find.text('Living room'), findsOneWidget);
  });
}
