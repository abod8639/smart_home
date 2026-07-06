import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/features/weather/presentation/providers/weather_provider.dart';

ProviderContainer createContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('WeatherController Tests', () {
    test('initial state has isWeatherLoading = true', () {
      final container = createContainer();
      // Before any microtask runs the loading flag should be true
      expect(container.read(weatherControllerProvider).isWeatherLoading, isTrue);
    });

    test('fetchLiveWeather handles network failure and sets fallback values', () async {
      final container = createContainer();
      final controller = container.read(weatherControllerProvider.notifier);

      // Replace the internal Dio adapter with one that always throws
      controller.dio.httpClientAdapter = _MockDioAdapter((options) async {
        throw DioException(
          requestOptions: options,
          error: 'Simulated network failure',
        );
      });

      // Wait for initial microtask to settle, then call manually
      await Future.microtask(() {});
      await controller.fetchLiveWeather();

      final state = container.read(weatherControllerProvider);
      expect(state.isWeatherLoading, isFalse);
      expect(state.weatherLocation, 'Jakarta, Indonesia');
      expect(state.weatherTemp, '27°C');
      expect(state.weatherCondition, 'Clear Evening');
    });

    test('fetchLiveWeather updates state correctly on success', () async {
      final container = createContainer();
      final controller = container.read(weatherControllerProvider.notifier);

      controller.dio.httpClientAdapter = _MockDioAdapter((options) async {
        if (options.path.contains('ipapi.co')) {
          return ResponseBody.fromString(
            jsonEncode({
              'city': 'Paris',
              'country_name': 'France',
              'latitude': 48.8566,
              'longitude': 2.3522,
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        } else if (options.path.contains('open-meteo.com')) {
          return ResponseBody.fromString(
            jsonEncode({
              'current_weather': {
                'temperature': 18.2,
                'weathercode': 3, // Partly Cloudy
                'is_day': 1,
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw DioException(requestOptions: options, error: 'Not found');
      });

      await Future.microtask(() {});
      await controller.fetchLiveWeather();

      final state = container.read(weatherControllerProvider);
      expect(state.isWeatherLoading, isFalse);
      expect(state.weatherLocation, 'Paris, France');
      expect(state.weatherTemp, '18°C');
      expect(state.weatherCondition, 'Partly Cloudy');
    });

    test('fetchLiveWeather sets isDay = 1 for daytime weather code', () async {
      final container = createContainer();
      final controller = container.read(weatherControllerProvider.notifier);

      controller.dio.httpClientAdapter = _MockDioAdapter((options) async {
        if (options.path.contains('ipapi.co')) {
          return ResponseBody.fromString(
            jsonEncode({'city': 'Cairo', 'country_name': 'Egypt', 'latitude': 30.05, 'longitude': 31.24}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        } else if (options.path.contains('open-meteo.com')) {
          return ResponseBody.fromString(
            jsonEncode({
              'current_weather': {'temperature': 35.0, 'weathercode': 0, 'is_day': 1}
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw DioException(requestOptions: options, error: 'Not found');
      });

      await Future.microtask(() {});
      await controller.fetchLiveWeather();

      final state = container.read(weatherControllerProvider);
      expect(state.isDay, 1);
      expect(state.weatherCondition, 'Sunny Day');
    });

    test('fetchLiveWeather sets isDay = 0 for nighttime clear weather', () async {
      final container = createContainer();
      final controller = container.read(weatherControllerProvider.notifier);

      controller.dio.httpClientAdapter = _MockDioAdapter((options) async {
        if (options.path.contains('ipapi.co')) {
          return ResponseBody.fromString(
            jsonEncode({'city': 'Dubai', 'country_name': 'UAE', 'latitude': 25.2, 'longitude': 55.27}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        } else if (options.path.contains('open-meteo.com')) {
          return ResponseBody.fromString(
            jsonEncode({
              'current_weather': {'temperature': 28.0, 'weathercode': 0, 'is_day': 0}
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw DioException(requestOptions: options, error: 'Not found');
      });

      await Future.microtask(() {});
      await controller.fetchLiveWeather();

      final state = container.read(weatherControllerProvider);
      expect(state.isDay, 0);
      expect(state.weatherCondition, 'Clear Evening');
    });

    test('weatherDate is set to non-empty string after fetch', () async {
      final container = createContainer();
      await Future.microtask(() {});
      // After the initial auto-fetch fails silently, date should be set
      // Manually trigger a failed fetch to see date was set
      final controller = container.read(weatherControllerProvider.notifier);
      controller.dio.httpClientAdapter = _MockDioAdapter((options) async {
        throw DioException(requestOptions: options, error: 'network error');
      });
      await controller.fetchLiveWeather();
      expect(container.read(weatherControllerProvider).weatherDate, isNotEmpty);
    });
  });
}

/// A minimal Dio HTTP adapter that delegates to a callback.
class _MockDioAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) onFetch;
  _MockDioAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}
