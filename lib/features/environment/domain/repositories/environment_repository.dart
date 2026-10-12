import '../entities/environment_entity.dart';

/// Repository interface for retrieving and streaming smart home environment metrics.
abstract class EnvironmentRepository {
  /// Gets the current ambient environment telemetry snapshot.
  EnvironmentEntity getEnvironment();

  /// Observes a stream of live ambient environment updates from hardware/sensors.
  Stream<EnvironmentEntity> watchEnvironment();

  /// Updates ambient temperature reading.
  void setTemperature(String temperature);

  /// Updates ambient relative humidity reading.
  void setHumidity(String humidity);

  /// Updates airflow percentage reading.
  void setAirflow(String airflow);

  /// Updates estimated power consumption reading.
  void setPowerUsage(String powerUsage);

  /// Updates hardware WiFi RSSI signal strength reading.
  void setWifiRssi(String wifiRssi);

  /// Updates hardware free heap memory reading.
  void setHeapFree(String heapFree);
}
