import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/widgets/celestial_indicator.dart';
import 'package:smart_home/features/weather/presentation/controllers/weather_controller.dart';
import 'package:smart_home/features/weather/presentation/widgets/weather_update_widget.dart';

void main() {
  group('CelestialIndicator Widget Tests', () {
    testWidgets('renders sun painter for day mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelestialIndicator(
              isDay: true,
              size: 100.0,
            ),
          ),
        ),
      );

      expect(find.byType(CelestialIndicator), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders moon painter for night mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CelestialIndicator(
              isDay: false,
              glowColor: Colors.blueAccent,
              size: 100.0,
            ),
          ),
        ),
      );

      expect(find.byType(CelestialIndicator), findsOneWidget);
    });
  });

  group('WeatherUpdateWidget Widget Tests', () {
    testWidgets('renders loading state initially or displays weather telemetry', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            weatherControllerProvider.overrideWith(
              () => _StaticWeatherController(
                const WeatherState(
                  isWeatherLoading: false,
                  weatherLocation: 'Dubai, UAE',
                  weatherTemp: '34°C',
                  weatherCondition: 'Sunny Day',
                  weatherDate: 'Tue, 13 Oct',
                  isDay: 1,
                  weatherCode: 0,
                ),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: WeatherUpdateWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Dubai, UAE'), findsOneWidget);
      expect(find.text('34°C'), findsOneWidget);
      expect(find.text('Sunny Day'), findsOneWidget);
      expect(find.text('Tue, 13 Oct'), findsOneWidget);
      expect(find.byType(CelestialIndicator), findsOneWidget);
    });
  });
}

class _StaticWeatherController extends WeatherController {
  final WeatherState initial;
  _StaticWeatherController(this.initial);

  @override
  WeatherState build() => initial;

  @override
  Future<void> fetchLiveWeather() async {}
}
