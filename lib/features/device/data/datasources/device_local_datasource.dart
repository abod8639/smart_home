import 'dart:io';
import 'package:smart_home/core/services/hive_service.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

/// Local data source for persisting and retrieving [DeviceEntity] objects
/// using Hive. Devices are stored as plain [Map] objects (no TypeAdapter needed).
class DeviceLocalDatasource {
  // ── Serialization ────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toMap(DeviceEntity d) => {
        'id': d.id,
        'name': d.name,
        'type': d.type.name,
        'isOn': d.isOn,
        'roomId': d.roomId,
        'batteryLevel': d.batteryLevel,
        'areaCleaned': d.areaCleaned,
        'cleaningTime': d.cleaningTime,
        'filterStatus': d.filterStatus,
        'nextCleaning': d.nextCleaning,
        'temperature': d.temperature,
        'mode': d.mode,
        'coolingTime': d.coolingTime,
        'brightness': d.brightness,
        'isLocked': d.isLocked,
        'linkedDevicesCount': d.linkedDevicesCount,
        'positionX': d.positionX,
        'positionY': d.positionY,
        'markerWidth': d.markerWidth,
        'markerHeight': d.markerHeight,
        'rgbR': d.rgbR,
        'rgbG': d.rgbG,
        'rgbB': d.rgbB,
      };

  static DeviceEntity _fromMap(Map map) {
    final typeStr = map['type'] as String? ?? 'lamp';
    final type = DeviceType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => DeviceType.lamp,
    );

    return DeviceEntity(
      id: map['id'] as String,
      name: map['name'] as String,
      type: type,
      isOn: map['isOn'] as bool? ?? false,
      roomId: map['roomId'] as String?,
      batteryLevel: map['batteryLevel'] as int?,
      areaCleaned: map['areaCleaned'] as int?,
      cleaningTime: map['cleaningTime'] as int?,
      filterStatus: map['filterStatus'] as int?,
      nextCleaning: map['nextCleaning'] as String?,
      temperature: map['temperature'] as int?,
      mode: map['mode'] as String?,
      coolingTime: map['coolingTime'] as int?,
      brightness: map['brightness'] as int?,
      isLocked: map['isLocked'] as bool?,
      linkedDevicesCount: map['linkedDevicesCount'] as int?,
      positionX: (map['positionX'] as num?)?.toDouble(),
      positionY: (map['positionY'] as num?)?.toDouble(),
      markerWidth: (map['markerWidth'] as num?)?.toDouble(),
      markerHeight: (map['markerHeight'] as num?)?.toDouble(),
      rgbR: map['rgbR'] as int?,
      rgbG: map['rgbG'] as int?,
      rgbB: map['rgbB'] as int?,
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Returns all saved devices. Empty list if nothing has been saved yet.
  List<DeviceEntity> loadDevices() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return [];
    final box = HiveService.devicesBox;
    return box.values
        .map((raw) => _fromMap(Map<String, dynamic>.from(raw)))
        .toList();
  }

  /// Overwrites all saved devices with [devices].
  Future<void> saveDevices(List<DeviceEntity> devices) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    final box = HiveService.devicesBox;
    await box.clear();
    final entries = {
      for (var d in devices) d.id: _toMap(d),
    };
    await box.putAll(entries);
  }

  /// Clears the entire devices box.
  Future<void> clearDevices() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await HiveService.devicesBox.clear();
  }

  /// Returns true if there are any saved devices.
  bool get hasData {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return HiveService.devicesBox.isNotEmpty;
  }
}
