import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/weather_entity.dart';
import '../../domain/repositories/weather_repository.dart';
import '../datasources/weather_remote_datasource.dart';

part 'weather_repository_impl.g.dart';

/// Concrete implementation of [WeatherRepository] consuming [WeatherRemoteDatasource].
class WeatherRepositoryImpl implements WeatherRepository {
  final WeatherRemoteDatasource remoteDatasource;

  WeatherRepositoryImpl({required this.remoteDatasource});

  @override
  Future<WeatherEntity> getCurrentWeather({double? latitude, double? longitude}) async {
    return await remoteDatasource.fetchLiveWeather(
      latitude: latitude,
      longitude: longitude,
    );
  }

  @override
  Future<Map<String, dynamic>> getGeoLocation() async {
    return await remoteDatasource.fetchGeoLocation();
  }
}

/// Provider for accessing [WeatherRepository].
@riverpod
WeatherRepository weatherRepository(Ref ref) {
  return WeatherRepositoryImpl(
    remoteDatasource: ref.watch(weatherRemoteDatasourceProvider),
  );
}
