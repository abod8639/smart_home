import '../entities/device_entity.dart';

abstract class DeviceRepository {
  Future<List<DeviceEntity>> getDevices();
  Future<void> saveDevices(List<DeviceEntity> devices);
  Future<void> clearDevices();
}
