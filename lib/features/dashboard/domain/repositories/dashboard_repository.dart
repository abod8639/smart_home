import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

/// Repository contract for dashboard data synchronization and hardware command dispatching.
abstract class DashboardRepository {
  /// Fetches remote rooms from cloud storage (Firebase).
  Future<List<RoomEntity>?> fetchRemoteRooms();

  /// Fetches remote devices from cloud storage (Firebase).
  Future<List<DeviceEntity>?> fetchRemoteDevices();

  /// Stream emitting real-time updates for rooms.
  Stream<List<RoomEntity>> watchRemoteRooms();

  /// Stream emitting real-time updates for devices.
  Stream<List<DeviceEntity>> watchRemoteDevices();

  /// Fetches stored IR codes for a specific device from remote storage.
  Future<Map<String, dynamic>> fetchRemoteIrCodes(String deviceId);

  /// Dispatches a command payload to the ESP32 hardware bridge.
  Future<void> sendEsp32Command(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? data,
  });

  /// Dispatches an on/off toggle command to a Matter node and endpoint.
  Future<void> toggleMatterDevice(int nodeId, int endpointId, bool isOn);
}
