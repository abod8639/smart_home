import '../entities/device_entity.dart';

/// Repository interface for storing and retrieving device configurations.
abstract class DeviceRepository {
  /// Loads all saved devices from the data layer.
  Future<List<DeviceEntity>> getDevices();

  /// Persists the complete list of [devices] to the data layer.
  Future<void> saveDevices(List<DeviceEntity> devices);

  /// Clears all stored device configurations from the data layer.
  Future<void> clearDevices();
}
