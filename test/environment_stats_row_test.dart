import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/environment/presentation/controllers/environment_controller.dart';
import 'package:smart_home/features/environment/presentation/widgets/environment_stats_row.dart';

void main() {
  group('EnvironmentStatsRow Widget Tests', () {
    testWidgets('renders all environment metrics from state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            environmentControllerProvider.overrideWith(() => _MockEnvironmentController()),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnvironmentStatsRow(),
            ),
          ),
        ),
      );

      expect(find.byType(EnvironmentStatsRow), findsOneWidget);
      expect(find.text('48%'), findsOneWidget); // humidity
      expect(find.text('70%'), findsOneWidget); // airflow
      expect(find.text('22°'), findsOneWidget); // temperature
      expect(find.text('-55 dBm'), findsOneWidget); // wifi
      expect(find.text('210 KB'), findsOneWidget); // heap
    });
  });
}

class _MockEnvironmentController extends EnvironmentController {
  @override
  EnvironmentState build() {
    return const EnvironmentState(
      humidity: '48%',
      airflow: '70%',
      temperature: '22°',
      powerUsage: '310W',
      wifiRssi: '-55 dBm',
      heapFree: '210 KB',
    );
  }
}
