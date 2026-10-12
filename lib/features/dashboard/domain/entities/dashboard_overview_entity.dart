import 'package:equatable/equatable.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

/// Domain entity representing the aggregate dashboard state and active overview.
class DashboardOverviewEntity extends Equatable {
  /// All configured rooms in the smart home.
  final List<RoomEntity> rooms;

  /// All devices across all rooms.
  final List<DeviceEntity> devices;

  /// Active keys for infrared commands currently transmitting.
  final Set<String> sendingIrKeys;

  /// Device IDs currently awaiting hardware (ESP32/Matter) confirmation.
  final Set<String> pendingDeviceIds;

  const DashboardOverviewEntity({
    this.rooms = const [],
    this.devices = const [],
    this.sendingIrKeys = const {},
    this.pendingDeviceIds = const {},
  });

  /// The room currently selected as active on the dashboard.
  RoomEntity? get activeRoom {
    try {
      return rooms.firstWhere((r) => r.isActive);
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy of this entity with the specified fields replaced.
  DashboardOverviewEntity copyWith({
    List<RoomEntity>? rooms,
    List<DeviceEntity>? devices,
    Set<String>? sendingIrKeys,
    Set<String>? pendingDeviceIds,
  }) {
    return DashboardOverviewEntity(
      rooms: rooms ?? this.rooms,
      devices: devices ?? this.devices,
      sendingIrKeys: sendingIrKeys ?? this.sendingIrKeys,
      pendingDeviceIds: pendingDeviceIds ?? this.pendingDeviceIds,
    );
  }

  @override
  List<Object?> get props => [rooms, devices, sendingIrKeys, pendingDeviceIds];
}
