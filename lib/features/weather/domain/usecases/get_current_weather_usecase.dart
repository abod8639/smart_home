import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/weather_entity.dart';
import '../repositories/weather_repository.dart';
import '../../data/repositories/weather_repository_impl.dart';

part 'get_current_weather_usecase.g.dart';

/// Use case for fetching the current live weather report.
class GetCurrentWeatherUseCase {
  final WeatherRepository repository;

  GetCurrentWeatherUseCase(this.repository);

  Future<WeatherEntity> call({double? latitude, double? longitude}) async {
    return await repository.getCurrentWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Provider for accessing [GetCurrentWeatherUseCase].
@riverpod
GetCurrentWeatherUseCase getCurrentWeatherUseCase(Ref ref) {
  return GetCurrentWeatherUseCase(ref.watch(weatherRepositoryProvider));
}
