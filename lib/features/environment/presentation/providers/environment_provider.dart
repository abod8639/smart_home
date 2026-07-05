import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'environment_provider.g.dart';

class EnvironmentState extends Equatable {
  final String humidity;
  final String airflow;
  final String temperature;
  final String powerUsage;
  final String wifiRssi;
  final String heapFree;

  const EnvironmentState({
    this.humidity = '50%',
    this.airflow = '80%',
    this.temperature = '27°',
    this.powerUsage = '360W',
    this.wifiRssi = '- dBm',
    this.heapFree = '0 KB',
  });

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

  @override
  List<Object?> get props => [
        humidity,
        airflow,
        temperature,
        powerUsage,
        wifiRssi,
        heapFree,
      ];
}

@Riverpod(keepAlive: true)
class EnvironmentController extends _$EnvironmentController {
  @override
  EnvironmentState build() {
    return const EnvironmentState();
  }

  void setTemperature(String val) => state = state.copyWith(temperature: val);
  void setHumidity(String val) => state = state.copyWith(humidity: val);
  void setWifiRssi(String val) => state = state.copyWith(wifiRssi: val);
  void setHeapFree(String val) => state = state.copyWith(heapFree: val);
}
