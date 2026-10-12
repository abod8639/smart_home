import '../../domain/entities/weather_entity.dart';

/// Data model representing weather telemetry with serialization and mapping.
class WeatherModel extends WeatherEntity {
  const WeatherModel({
    super.weatherLocation,
    super.weatherTemp,
    super.weatherCondition,
    super.weatherDate,
    super.weatherSuggestion,
    super.isWeatherLoading,
    super.isDay,
    super.weatherCode,
  });

  /// Creates a [WeatherModel] from a [WeatherEntity].
  factory WeatherModel.fromEntity(WeatherEntity entity) {
    return WeatherModel(
      weatherLocation: entity.weatherLocation,
      weatherTemp: entity.weatherTemp,
      weatherCondition: entity.weatherCondition,
      weatherDate: entity.weatherDate,
      weatherSuggestion: entity.weatherSuggestion,
      isWeatherLoading: entity.isWeatherLoading,
      isDay: entity.isDay,
      weatherCode: entity.weatherCode,
    );
  }

  /// Converts this model to a persistent key-value map.
  Map<String, dynamic> toMap() => {
        'weatherLocation': weatherLocation,
        'weatherTemp': weatherTemp,
        'weatherCondition': weatherCondition,
        'weatherDate': weatherDate,
        'weatherSuggestion': weatherSuggestion,
        'isWeatherLoading': isWeatherLoading,
        'isDay': isDay,
        'weatherCode': weatherCode,
      };

  /// Decodes a persisted key-value map into a [WeatherModel].
  factory WeatherModel.fromMap(Map<String, dynamic> map) {
    return WeatherModel(
      weatherLocation: map['weatherLocation'] as String? ?? 'Loading...',
      weatherTemp: map['weatherTemp'] as String? ?? '--°C',
      weatherCondition: map['weatherCondition'] as String? ?? 'Fetching...',
      weatherDate: map['weatherDate'] as String? ?? '',
      weatherSuggestion: map['weatherSuggestion'] as String? ?? 'Optimizing settings...',
      isWeatherLoading: map['isWeatherLoading'] as bool? ?? false,
      isDay: map['isDay'] as int? ?? 1,
      weatherCode: map['weatherCode'] as int? ?? 0,
    );
  }
}
