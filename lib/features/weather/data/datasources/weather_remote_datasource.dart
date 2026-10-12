import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/utils/formatting_utils.dart';
import '../models/weather_model.dart';

part 'weather_remote_datasource.g.dart';

/// Remote datasource responsible for fetching geolocation from ipapi.co
/// and live weather telemetry from open-meteo.com.
class WeatherRemoteDatasource {
  final Dio dio;

  WeatherRemoteDatasource({Dio? dio}) : dio = dio ?? Dio();

  /// Fetches geolocation details (city, country, latitude, longitude).
  Future<Map<String, dynamic>> fetchGeoLocation() async {
    final response = await dio.get('https://ipapi.co/json/');
    if (response.statusCode == 200 && response.data != null) {
      return Map<String, dynamic>.from(response.data);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      error: 'Failed to fetch geolocation: invalid status ${response.statusCode}',
    );
  }

  /// Fetches live weather for specified coordinates, or falls back to Jakarta defaults on failure.
  Future<WeatherModel> fetchLiveWeather({double? latitude, double? longitude}) async {
    try {
      String location = 'Cairo, Egypt';
      double lat = latitude ?? 30.0507;
      double lon = longitude ?? 31.2489;

      if (latitude == null || longitude == null) {
        try {
          final geo = await fetchGeoLocation();
          final city = geo['city'] ?? 'Cairo';
          final country = geo['country_name'] ?? 'Egypt';
          location = '$city, $country';
          lat = (geo['latitude'] as num?)?.toDouble() ?? 30.0507;
          lon = (geo['longitude'] as num?)?.toDouble() ?? 31.2489;
        } catch (_) {
          // If geo lookup fails, fallback coordinates remain Cairo
        }
      }

      final weatherResponse = await dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current_weather': true,
        },
      );

      if (weatherResponse.statusCode == 200 && weatherResponse.data != null) {
        final weatherData = weatherResponse.data['current_weather'];
        if (weatherData != null) {
          final double temp = (weatherData['temperature'] as num?)?.toDouble() ?? 27.0;
          final int code = (weatherData['weathercode'] as num?)?.toInt() ?? 0;
          final int dayFlag = (weatherData['is_day'] as num?)?.toInt() ?? 1;

          return WeatherModel(
            weatherLocation: location,
            weatherTemp: '${temp.round()}°C',
            weatherCode: code,
            isDay: dayFlag,
            weatherCondition: mapWeatherCode(code, dayFlag),
            weatherSuggestion: generateSuggestion(temp, code),
            weatherDate: FormattingUtils.formatDate(DateTime.now()),
            isWeatherLoading: false,
          );
        }
      }
      throw DioException(
        requestOptions: weatherResponse.requestOptions,
        error: 'Invalid weather response',
      );
    } catch (e) {
      return WeatherModel(
        weatherLocation: 'Jakarta, Indonesia',
        weatherTemp: '27°C',
        weatherCondition: 'Clear Evening',
        weatherDate: FormattingUtils.formatDate(DateTime.now()),
        isDay: 0,
        weatherCode: 0,
        weatherSuggestion: "Activate 'Relax Mode', dim lights, soft music, and lower thermostat.",
        isWeatherLoading: false,
      );
    }
  }

  /// Maps WMO code and day flag to user-facing condition string.
  static String mapWeatherCode(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    switch (code) {
      case 0:
        return isNight ? 'Clear Evening' : 'Sunny Day';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Light Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return isNight ? 'Clear Evening' : 'Clear Day';
    }
  }

  /// Generates context-aware smart home suggestions based on temperature and weather conditions.
  static String generateSuggestion(double temp, int code) {
    if (code >= 50 && code <= 99) {
      return "Rainy weather. Perfect time to stay warm, dim the lights and play cozy music.";
    }
    if (temp > 30) {
      return "It's hot outside. Lowering the AC to 22°C and activating air circulation is recommended.";
    }
    if (temp < 18) {
      return "Cold outside. Activating heating mode on the AC and setting comfortable lighting.";
    }
    return "Weather is pleasant. Open windows for fresh air or keep lights dim for a relaxed evening.";
  }
}

/// Provider for accessing [WeatherRemoteDatasource].
@riverpod
WeatherRemoteDatasource weatherRemoteDatasource(Ref ref) {
  return WeatherRemoteDatasource();
}
