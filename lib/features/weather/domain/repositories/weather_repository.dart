import '../entities/weather_entity.dart';

/// Repository interface contract for retrieving weather and geolocation data.
abstract class WeatherRepository {
  /// Fetches current weather data for the specified coordinates,
  /// or resolves coordinates via geolocation if none are provided.
  Future<WeatherEntity> getCurrentWeather({double? latitude, double? longitude});

  /// Resolves the current geographical location (city, country, coordinates).
  Future<Map<String, dynamic>> getGeoLocation();
}
