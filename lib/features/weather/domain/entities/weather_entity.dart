import 'package:equatable/equatable.dart';

/// Domain entity representing smart home environmental weather status,
/// geographical location, and smart atmosphere suggestions.
class WeatherEntity extends Equatable {
  /// City and country name (e.g. "Paris, France").
  final String weatherLocation;

  /// Formatted temperature string (e.g. "24°C").
  final String weatherTemp;

  /// Weather condition title (e.g. "Sunny Day", "Partly Cloudy").
  final String weatherCondition;

  /// Formatted date string.
  final String weatherDate;

  /// Smart home adjustment suggestion based on current weather.
  final String weatherSuggestion;

  /// Whether weather telemetry is currently synchronizing.
  final bool isWeatherLoading;

  /// Daytime indicator: 1 for day, 0 for night.
  final int isDay;

  /// WMO weather interpretation code.
  final int weatherCode;

  const WeatherEntity({
    this.weatherLocation = 'Loading...',
    this.weatherTemp = '--°C',
    this.weatherCondition = 'Fetching...',
    this.weatherDate = '',
    this.weatherSuggestion = 'Optimizing settings...',
    this.isWeatherLoading = true,
    this.isDay = 1,
    this.weatherCode = 0,
  });

  /// Creates a copy of this [WeatherEntity] with updated fields.
  WeatherEntity copyWith({
    String? weatherLocation,
    String? weatherTemp,
    String? weatherCondition,
    String? weatherDate,
    String? weatherSuggestion,
    bool? isWeatherLoading,
    int? isDay,
    int? weatherCode,
  }) {
    return WeatherEntity(
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
