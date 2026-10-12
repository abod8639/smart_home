import '../../domain/entities/environment_entity.dart';

/// Data Transfer Object (DTO) for environment telemetry serialization and deserialization.
class EnvironmentModel extends EnvironmentEntity {
  const EnvironmentModel({
    super.humidity = '50%',
    super.airflow = '80%',
    super.temperature = '27°',
    super.powerUsage = '360W',
    super.wifiRssi = '- dBm',
    super.heapFree = '0 KB',
  });

  /// Factory constructor to deserialize from a JSON/Map structure.
  factory EnvironmentModel.fromJson(Map<String, dynamic> json) {
    return EnvironmentModel(
      humidity: json['humidity']?.toString() ?? '50%',
      airflow: json['airflow']?.toString() ?? '80%',
      temperature: json['temperature']?.toString() ?? '27°',
      powerUsage: json['powerUsage']?.toString() ?? '360W',
      wifiRssi: json['wifiRssi']?.toString() ?? '- dBm',
      heapFree: json['heapFree']?.toString() ?? '0 KB',
    );
  }

  /// Factory constructor to convert from domain [EnvironmentEntity].
  factory EnvironmentModel.fromEntity(EnvironmentEntity entity) {
    return EnvironmentModel(
      humidity: entity.humidity,
      airflow: entity.airflow,
      temperature: entity.temperature,
      powerUsage: entity.powerUsage,
      wifiRssi: entity.wifiRssi,
      heapFree: entity.heapFree,
    );
  }

  /// Serializes this model into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'humidity': humidity,
      'airflow': airflow,
      'temperature': temperature,
      'powerUsage': powerUsage,
      'wifiRssi': wifiRssi,
      'heapFree': heapFree,
    };
  }

  /// Converts this model to a pure domain [EnvironmentEntity].
  EnvironmentEntity toEntity() {
    return EnvironmentEntity(
      humidity: humidity,
      airflow: airflow,
      temperature: temperature,
      powerUsage: powerUsage,
      wifiRssi: wifiRssi,
      heapFree: heapFree,
    );
  }
}
