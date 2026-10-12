import 'package:equatable/equatable.dart';

/// Pure domain entity representing ambient smart home environmental metrics.
class EnvironmentEntity extends Equatable {
  /// Relative humidity percentage (e.g. "50%").
  final String humidity;

  /// Airflow rate percentage or speed (e.g. "80%").
  final String airflow;

  /// Ambient room temperature (e.g. "27°").
  final String temperature;

  /// Current power consumption estimate (e.g. "360W").
  final String powerUsage;

  /// WiFi signal strength in dBm (e.g. "-65 dBm").
  final String wifiRssi;

  /// ESP32 free heap memory (e.g. "180.5 KB").
  final String heapFree;

  /// Creates a constant [EnvironmentEntity] instance with sensible defaults.
  const EnvironmentEntity({
    this.humidity = '50%',
    this.airflow = '80%',
    this.temperature = '27°',
    this.powerUsage = '360W',
    this.wifiRssi = '- dBm',
    this.heapFree = '0 KB',
  });

  /// Creates a copy with the given fields replaced with new values.
  EnvironmentEntity copyWith({
    String? humidity,
    String? airflow,
    String? temperature,
    String? powerUsage,
    String? wifiRssi,
    String? heapFree,
  }) {
    return EnvironmentEntity(
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
