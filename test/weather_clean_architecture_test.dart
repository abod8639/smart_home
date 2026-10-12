import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/weather/domain/entities/weather_entity.dart';
import 'package:smart_home/features/weather/domain/repositories/weather_repository.dart';
import 'package:smart_home/features/weather/domain/usecases/get_current_weather_usecase.dart';
import 'package:smart_home/features/weather/data/models/weather_model.dart';
import 'package:smart_home/features/weather/data/datasources/weather_remote_datasource.dart';
import 'package:smart_home/features/weather/data/repositories/weather_repository_impl.dart';

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

class FakeWeatherRepository implements WeatherRepository {
  WeatherEntity currentWeather = const WeatherEntity();

  @override
  Future<WeatherEntity> getCurrentWeather({double? latitude, double? longitude}) async {
    return currentWeather;
  }

  @override
  Future<Map<String, dynamic>> getGeoLocation() async {
    return {
      'city': 'Tokyo',
      'country_name': 'Japan',
      'latitude': 35.6762,
      'longitude': 139.6503,
    };
  }
}

void main() {
  group('WeatherEntity & WeatherModel Tests', () {
    test('WeatherEntity default values and copyWith', () {
      const entity = WeatherEntity();
      expect(entity.weatherLocation, 'Loading...');
      expect(entity.weatherTemp, '--°C');
      expect(entity.isWeatherLoading, isTrue);
      expect(entity.isDay, 1);

      final updated = entity.copyWith(
        weatherLocation: 'Rome, Italy',
        weatherTemp: '22°C',
        weatherCondition: 'Sunny Day',
        isWeatherLoading: false,
      );

      expect(updated.weatherLocation, 'Rome, Italy');
      expect(updated.weatherTemp, '22°C');
      expect(updated.weatherCondition, 'Sunny Day');
      expect(updated.isWeatherLoading, isFalse);
    });

    test('WeatherModel toMap and fromMap serialization', () {
      const model = WeatherModel(
        weatherLocation: 'Madrid, Spain',
        weatherTemp: '29°C',
        weatherCondition: 'Clear Day',
        weatherDate: 'Mon, 12 Oct',
        weatherSuggestion: 'Stay hydrated',
        isWeatherLoading: false,
        isDay: 1,
        weatherCode: 0,
      );

      final map = model.toMap();
      expect(map['weatherLocation'], 'Madrid, Spain');
      expect(map['weatherTemp'], '29°C');
      expect(map['isDay'], 1);

      final restored = WeatherModel.fromMap(map);
      expect(restored.weatherLocation, model.weatherLocation);
      expect(restored.weatherTemp, model.weatherTemp);
      expect(restored.weatherCondition, model.weatherCondition);
      expect(restored.weatherDate, model.weatherDate);
      expect(restored.weatherSuggestion, model.weatherSuggestion);
      expect(restored.isWeatherLoading, model.isWeatherLoading);
      expect(restored.isDay, model.isDay);
      expect(restored.weatherCode, model.weatherCode);
    });

    test('WeatherModel fromEntity creates matching model', () {
      const entity = WeatherEntity(
        weatherLocation: 'Berlin, Germany',
        weatherTemp: '16°C',
      );
      final model = WeatherModel.fromEntity(entity);
      expect(model.weatherLocation, 'Berlin, Germany');
      expect(model.weatherTemp, '16°C');
    });
  });

  group('WeatherRemoteDatasource Tests', () {
    late Dio dio;
    late WeatherRemoteDatasource datasource;

    setUp(() {
      dio = Dio();
      datasource = WeatherRemoteDatasource(dio: dio);
    });

    test('fetchGeoLocation succeeds on 200 response', () async {
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        return ResponseBody.fromString(
          jsonEncode({
            'city': 'Seoul',
            'country_name': 'South Korea',
            'latitude': 37.5665,
            'longitude': 126.9780,
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final geo = await datasource.fetchGeoLocation();
      expect(geo['city'], 'Seoul');
      expect(geo['country_name'], 'South Korea');
    });

    test('fetchLiveWeather parses open-meteo response accurately', () async {
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        if (options.path.contains('ipapi.co')) {
          return ResponseBody.fromString(
            jsonEncode({
              'city': 'London',
              'country_name': 'UK',
              'latitude': 51.5074,
              'longitude': -0.1278,
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        } else if (options.path.contains('open-meteo.com')) {
          return ResponseBody.fromString(
            jsonEncode({
              'current_weather': {
                'temperature': 15.6,
                'weathercode': 61, // Rainy
                'is_day': 0,
              }
            }),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        throw DioException(requestOptions: options, error: 'Not found');
      });

      final result = await datasource.fetchLiveWeather();
      expect(result.weatherLocation, 'London, UK');
      expect(result.weatherTemp, '16°C');
      expect(result.weatherCondition, 'Rainy');
      expect(result.isDay, 0);
      expect(result.isWeatherLoading, isFalse);
    });

    test('fetchLiveWeather falls back to defaults on total network failure', () async {
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        throw DioException(requestOptions: options, error: 'Connection refused');
      });

      final fallback = await datasource.fetchLiveWeather();
      expect(fallback.weatherLocation, 'Jakarta, Indonesia');
      expect(fallback.weatherTemp, '27°C');
      expect(fallback.weatherCondition, 'Clear Evening');
      expect(fallback.isWeatherLoading, isFalse);
    });

    test('mapWeatherCode maps conditions properly across various codes', () {
      expect(WeatherRemoteDatasource.mapWeatherCode(0, 1), 'Sunny Day');
      expect(WeatherRemoteDatasource.mapWeatherCode(0, 0), 'Clear Evening');
      expect(WeatherRemoteDatasource.mapWeatherCode(2, 1), 'Partly Cloudy');
      expect(WeatherRemoteDatasource.mapWeatherCode(45, 1), 'Foggy');
      expect(WeatherRemoteDatasource.mapWeatherCode(51, 1), 'Light Drizzle');
      expect(WeatherRemoteDatasource.mapWeatherCode(61, 1), 'Rainy');
      expect(WeatherRemoteDatasource.mapWeatherCode(71, 1), 'Snowy');
      expect(WeatherRemoteDatasource.mapWeatherCode(80, 1), 'Rain Showers');
      expect(WeatherRemoteDatasource.mapWeatherCode(95, 1), 'Thunderstorm');
    });

    test('generateSuggestion generates context-appropriate text', () {
      expect(WeatherRemoteDatasource.generateSuggestion(32.0, 0), contains("Lowering the AC"));
      expect(WeatherRemoteDatasource.generateSuggestion(15.0, 0), contains("Activating heating mode"));
      expect(WeatherRemoteDatasource.generateSuggestion(22.0, 61), contains("Rainy weather"));
      expect(WeatherRemoteDatasource.generateSuggestion(22.0, 0), contains("Weather is pleasant"));
    });
  });

  group('WeatherRepositoryImpl Tests', () {
    test('delegates calls to WeatherRemoteDatasource', () async {
      final dio = Dio();
      dio.httpClientAdapter = _MockDioAdapter((options) async {
        if (options.path.contains('ipapi.co')) {
          return ResponseBody.fromString(
            jsonEncode({'city': 'Oslo', 'country_name': 'Norway', 'latitude': 59.9, 'longitude': 10.7}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        }
        return ResponseBody.fromString(
          jsonEncode({
            'current_weather': {'temperature': 8.0, 'weathercode': 71, 'is_day': 1}
          }),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      });

      final datasource = WeatherRemoteDatasource(dio: dio);
      final repository = WeatherRepositoryImpl(remoteDatasource: datasource);

      final weather = await repository.getCurrentWeather();
      expect(weather.weatherLocation, 'Oslo, Norway');
      expect(weather.weatherCondition, 'Snowy');

      final geo = await repository.getGeoLocation();
      expect(geo['city'], 'Oslo');
    });
  });

  group('GetCurrentWeatherUseCase Tests', () {
    test('executes repository.getCurrentWeather', () async {
      final fakeRepo = FakeWeatherRepository();
      fakeRepo.currentWeather = const WeatherEntity(
        weatherLocation: 'Stockholm, Sweden',
        weatherTemp: '12°C',
        weatherCondition: 'Partly Cloudy',
      );

      final usecase = GetCurrentWeatherUseCase(fakeRepo);
      final weather = await usecase();

      expect(weather.weatherLocation, 'Stockholm, Sweden');
      expect(weather.weatherTemp, '12°C');
      expect(weather.weatherCondition, 'Partly Cloudy');
    });
  });
}
