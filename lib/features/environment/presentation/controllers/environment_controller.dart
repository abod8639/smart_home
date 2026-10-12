import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/environment_entity.dart';
import '../../domain/usecases/get_environment_usecase.dart';
import '../../domain/usecases/update_environment_usecase.dart';

part 'environment_controller.g.dart';

/// Presentation state for smart home ambient environment metrics.
class EnvironmentState extends EnvironmentEntity {
  const EnvironmentState({
    super.humidity = '50%',
    super.airflow = '80%',
    super.temperature = '27°',
    super.powerUsage = '360W',
    super.wifiRssi = '- dBm',
    super.heapFree = '0 KB',
  });

  /// Factory to convert base entity to presentation state.
  factory EnvironmentState.fromEntity(EnvironmentEntity entity) {
    return EnvironmentState(
      humidity: entity.humidity,
      airflow: entity.airflow,
      temperature: entity.temperature,
      powerUsage: entity.powerUsage,
      wifiRssi: entity.wifiRssi,
      heapFree: entity.heapFree,
    );
  }

  @override
  EnvironmentState copyWith({
    String? humidity,
    String? airflow,
    String? temperature,
    String? powerUsage,
    String? wifiRssi,
    String? heapFree,
  }) {
    return EnvironmentState(
      humidity: humidity ?? this.humidity,
      airflow: airflow ?? this.airflow,
      temperature: temperature ?? this.temperature,
      powerUsage: powerUsage ?? this.powerUsage,
      wifiRssi: wifiRssi ?? this.wifiRssi,
      heapFree: heapFree ?? this.heapFree,
    );
  }
}

/// Riverpod controller managing ambient environment state.
@Riverpod(keepAlive: true)
class EnvironmentController extends _$EnvironmentController {
  @override
  EnvironmentState build() {
    final getEnv = ref.watch(getEnvironmentUseCaseProvider);
    final initial = getEnv();
    return EnvironmentState.fromEntity(initial);
  }

  void setTemperature(String val) {
    state = state.copyWith(temperature: val);
    ref.read(updateEnvironmentUseCaseProvider).setTemperature(val);
  }

  void setHumidity(String val) {
    state = state.copyWith(humidity: val);
    ref.read(updateEnvironmentUseCaseProvider).setHumidity(val);
  }

  void setAirflow(String val) {
    state = state.copyWith(airflow: val);
    ref.read(updateEnvironmentUseCaseProvider).setAirflow(val);
  }

  void setPowerUsage(String val) {
    state = state.copyWith(powerUsage: val);
    ref.read(updateEnvironmentUseCaseProvider).setPowerUsage(val);
  }

  void setWifiRssi(String val) {
    state = state.copyWith(wifiRssi: val);
    ref.read(updateEnvironmentUseCaseProvider).setWifiRssi(val);
  }

  void setHeapFree(String val) {
    state = state.copyWith(heapFree: val);
    ref.read(updateEnvironmentUseCaseProvider).setHeapFree(val);
  }
}
