import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/utils/formatting_utils.dart';

part 'weather_provider.g.dart';

class WeatherState extends Equatable {
  final String weatherLocation;
  final String weatherTemp;
  final String weatherCondition;
  final String weatherDate;
  final String weatherSuggestion;
  final bool isWeatherLoading;
  final int isDay;
  final int weatherCode;

  const WeatherState({
    this.weatherLocation = 'Loading...',
    this.weatherTemp = '--°C',
    this.weatherCondition = 'Fetching...',
    this.weatherDate = '',
    this.weatherSuggestion = 'Optimizing settings...',
    this.isWeatherLoading = true,
    this.isDay = 1,
    this.weatherCode = 0,
  });

  WeatherState copyWith({
    String? weatherLocation,
    String? weatherTemp,
    String? weatherCondition,
    String? weatherDate,
    String? weatherSuggestion,
    bool? isWeatherLoading,
    int? isDay,
    int? weatherCode,
  }) {
    return WeatherState(
      weatherLocation: weatherLocation ?? this.weatherLocation,
      weatherTemp: weatherTemp ?? this.weatherTemp,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      weatherDate: weatherDate ?? this.weatherDate,
      weatherSuggestion: weatherSuggestion ?? this.weatherSuggestion,
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading,
      isDay: isDay ?? this.isDay,
      weatherCode: weatherCode ?? this.weatherCode,
    );
  }

  @override
  List<Object?> get props => [
        weatherLocation,
        weatherTemp,
        weatherCondition,
        weatherDate,
        weatherSuggestion,
        isWeatherLoading,
        isDay,
        weatherCode,
      ];
}

@Riverpod(keepAlive: true)
class WeatherController extends _$WeatherController {
  final Dio dio = Dio();

  @override
  WeatherState build() {
    Future.microtask(() => fetchLiveWeather());
    return const WeatherState();
  }

  Future<void> fetchLiveWeather() async {
    state = state.copyWith(
      isWeatherLoading: true,
      weatherDate: FormattingUtils.formatDate(DateTime.now()),
    );

    try {
      final geoResponse = await dio.get('https://ipapi.co/json/');
      if (geoResponse.statusCode == 200 && geoResponse.data != null) {
        final data = geoResponse.data;
        final city = data['city'] ?? 'Cairo';
        final country = data['country_name'] ?? 'Egypt';
        final double lat = (data['latitude'] as num?)?.toDouble() ?? 30.0507;
        final double lon = (data['longitude'] as num?)?.toDouble() ?? 31.2489;

        state = state.copyWith(weatherLocation: '$city, $country');

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

            state = state.copyWith(
              weatherTemp: '${temp.round()}°C',
              weatherCode: code,
              isDay: dayFlag,
              weatherCondition: _mapWeatherCode(code, dayFlag),
              weatherSuggestion: _generateSuggestion(temp, code),
            );
          }
        }
      }
    } catch (e) {
      state = state.copyWith(
        weatherLocation: 'Jakarta, Indonesia',
        weatherTemp: '27°C',
        weatherCondition: 'Clear Evening',
        isDay: 0,
        weatherCode: 0,
        weatherSuggestion: "Activate 'Relax Mode', dim lights, soft music, and lower thermostat.",
      );
    } finally {
      state = state.copyWith(isWeatherLoading: false);
    }
  }

  String _mapWeatherCode(int code, int dayFlag) {
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

  String _generateSuggestion(double temp, int code) {
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
