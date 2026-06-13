// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of 'dashboard_controller.dart';
// ==========================================
// Weather & Geolocation Logic
// ==========================================


extension DashboardControllerWeather on DashboardController {
  // Fetch real weather and geolocation details
  Future<void> fetchLiveWeather() async {
    state = state.copyWith(
      isWeatherLoading: true,
      weatherDate: _getFormattedDate(),
    );

    try {
      // Step 1: Geolocation using ipapi.co
      final geoResponse = await dio.get('https://ipapi.co/json/');
      if (geoResponse.statusCode == 200 && geoResponse.data != null) {
        final data = geoResponse.data;
        final city = data['city'] ?? 'Cairo';
        final country = data['country_name'] ?? 'Egypt';
        final double lat = (data['latitude'] as num?)?.toDouble() ?? 30.0507;
        final double lon = (data['longitude'] as num?)?.toDouble() ?? 31.2489;

        state = state.copyWith(weatherLocation: '$city, $country');

        // Step 2: Fetch weather details using Open-Meteo
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
      // Fallback gracefully on network error
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

  // Format date to: weekday, month day
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  // Map WMO codes to weather conditions
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

  // Generate dynamic contextual suggestion
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
