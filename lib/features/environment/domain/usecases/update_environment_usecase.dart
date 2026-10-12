import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/environment_repository.dart';
import '../../data/repositories/environment_repository_impl.dart';

part 'update_environment_usecase.g.dart';

/// Use case to dispatch updated sensor and hardware metrics to the environment repository.
class UpdateEnvironmentUseCase {
  final EnvironmentRepository repository;

  UpdateEnvironmentUseCase(this.repository);

  void setTemperature(String temperature) => repository.setTemperature(temperature);
  void setHumidity(String humidity) => repository.setHumidity(humidity);
  void setAirflow(String airflow) => repository.setAirflow(airflow);
  void setPowerUsage(String powerUsage) => repository.setPowerUsage(powerUsage);
  void setWifiRssi(String wifiRssi) => repository.setWifiRssi(wifiRssi);
  void setHeapFree(String heapFree) => repository.setHeapFree(heapFree);
}

/// Riverpod provider for [UpdateEnvironmentUseCase].
@riverpod
UpdateEnvironmentUseCase updateEnvironmentUseCase(Ref ref) {
  return UpdateEnvironmentUseCase(ref.watch(environmentRepositoryProvider));
}
