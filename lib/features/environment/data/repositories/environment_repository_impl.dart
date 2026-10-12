import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/environment_entity.dart';
import '../../domain/repositories/environment_repository.dart';
import '../datasources/environment_local_datasource.dart';
import '../models/environment_model.dart';

part 'environment_repository_impl.g.dart';

/// Concrete implementation of [EnvironmentRepository].
class EnvironmentRepositoryImpl implements EnvironmentRepository {
  final EnvironmentLocalDatasource datasource;

  EnvironmentRepositoryImpl({required this.datasource});

  @override
  EnvironmentEntity getEnvironment() {
    return datasource.current.toEntity();
  }

  @override
  Stream<EnvironmentEntity> watchEnvironment() {
    return datasource.stream.map((model) => model.toEntity());
  }

  @override
  void setTemperature(String temperature) {
    datasource.update((m) => EnvironmentModel.fromEntity(m.copyWith(temperature: temperature)));
  }

  @override
  void setHumidity(String humidity) {
    datasource.update((m) => EnvironmentModel.fromEntity(m.copyWith(humidity: humidity)));
  }

  @override
  void setAirflow(String airflow) {
    datasource.update((m) => EnvironmentModel.fromEntity(m.copyWith(airflow: airflow)));
  }

  @override
  void setPowerUsage(String powerUsage) {
    datasource.update((m) => EnvironmentModel.fromEntity(m.copyWith(powerUsage: powerUsage)));
  }

  @override
  void setWifiRssi(String wifiRssi) {
    datasource.update((m) => EnvironmentModel.fromEntity(m.copyWith(wifiRssi: wifiRssi)));
  }

  @override
  void setHeapFree(String heapFree) {
    datasource.update((m) => EnvironmentModel.fromEntity(m.copyWith(heapFree: heapFree)));
  }
}

/// Riverpod provider for [EnvironmentRepository].
@Riverpod(keepAlive: true)
EnvironmentRepository environmentRepository(Ref ref) {
  return EnvironmentRepositoryImpl(
    datasource: ref.watch(environmentLocalDatasourceProvider),
  );
}
