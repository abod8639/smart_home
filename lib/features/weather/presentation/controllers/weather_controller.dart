import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/utils/formatting_utils.dart';
import '../../domain/entities/weather_entity.dart';
import '../../data/datasources/weather_remote_datasource.dart';

part 'weather_controller.g.dart';

/// Presentation state for Weather, extending [WeatherEntity] for backward compatibility.
class WeatherState extends WeatherEntity {
  const WeatherState({
    super.weatherLocation = 'Loading...',
    super.weatherTemp = '--°C',
    super.weatherCondition = 'Fetching...',
    super.weatherDate = '',
    super.weatherSuggestion = 'Optimizing settings...',
    super.isWeatherLoading = true,
    super.isDay = 1,
    super.weatherCode = 0,
  });

  @override
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
      final datasource = WeatherRemoteDatasource(dio: dio);
      final weather = await datasource.fetchLiveWeather();

      state = state.copyWith(
        weatherLocation: weather.weatherLocation,
        weatherTemp: weather.weatherTemp,
        weatherCode: weather.weatherCode,
        isDay: weather.isDay,
        weatherCondition: weather.weatherCondition,
        weatherSuggestion: weather.weatherSuggestion,
        weatherDate: weather.weatherDate,
        isWeatherLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        weatherLocation: 'Jakarta, Indonesia',
        weatherTemp: '27°C',
        weatherCondition: 'Clear Evening',
        isDay: 0,
        weatherCode: 0,
        weatherSuggestion: "Activate 'Relax Mode', dim lights, soft music, and lower thermostat.",
        isWeatherLoading: false,
      );
    }
  }
}
