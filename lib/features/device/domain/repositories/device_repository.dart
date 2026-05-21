import '../entities/device_entity.dart';

abstract class DeviceRepository {
  Future<List<DeviceEntity>> getAllDevices();
  Future<DeviceEntity> getDeviceById(String id);
  Future<void> createDevice(DeviceEntity entity);
  
  // WebSocket additions
  Stream<List<DeviceEntity>> get deviceStream;
  Future<void> connectToWebSocket(String url);
  void disconnectWebSocket();
  void toggleDevice(String id, bool newState);
}
