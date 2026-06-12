import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:smart_home/core/services/hive_service.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

/// Local data source for persisting and retrieving [DeviceEntity] objects
/// using Hive. Devices are stored as plain [Map] objects (no TypeAdapter needed).
class DeviceLocalDatasource {
  // ── Serialization ────────────────────────────────────────────────────────────

  static Map<String, dynamic> toMap(DeviceEntity d) {
    final map = <String, dynamic>{
      'id': d.id,
      'name': d.name,
      'type': d.type.name,
      'isOn': d.isOn,
      'roomId': d.roomId,
      'positionX': d.positionX,
      'positionY': d.positionY,
      'markerWidth': d.markerWidth,
      'markerHeight': d.markerHeight,
      'showAsDot': d.showAsDot,
      'matterNodeId': d.matterNodeId,
      'matterEndpointId': d.matterEndpointId,
      'pin': d.pin,
    };

    if (d is AcDeviceEntity) {
      map['temperature'] = d.temperature;
      map['mode'] = d.mode;
      map['coolingTime'] = d.coolingTime;
      map['irPower'] = d.irPower;
      map['irTempUp'] = d.irTempUp;
      map['irTempDown'] = d.irTempDown;
      map['irAuto'] = d.irAuto;
      map['irCool'] = d.irCool;
      map['irHeat'] = d.irHeat;
      map['irEco'] = d.irEco;
      map['irDry'] = d.irDry;
      map['irFanQuiet'] = d.irFanQuiet;
      map['irFanLow'] = d.irFanLow;
      map['irFanMed'] = d.irFanMed;
      map['irFanHigh'] = d.irFanHigh;
      map['irFanAuto'] = d.irFanAuto;
      map['irSwingV'] = d.irSwingV;
      map['irSwingH'] = d.irSwingH;
      map['irPlasmacluster'] = d.irPlasmacluster;
      map['irSuperJet'] = d.irSuperJet;
      map['irCoanda'] = d.irCoanda;
      map['irMyArea'] = d.irMyArea;
      map['irDisplay'] = d.irDisplay;
      map['irClean'] = d.irClean;
    } else if (d is LampDeviceEntity) {
      map['brightness'] = d.brightness;
    } else if (d is RgbLampDeviceEntity) {
      map['brightness'] = d.brightness;
      map['rgbR'] = d.rgbR;
      map['rgbG'] = d.rgbG;
      map['rgbB'] = d.rgbB;
    } else if (d is DoorDeviceEntity) {
      map['isLocked'] = d.isLocked;
      map['linkedDevicesCount'] = d.linkedDevicesCount;
    } else if (d is VacuumDeviceEntity) {
      map['batteryLevel'] = d.batteryLevel;
      map['areaCleaned'] = d.areaCleaned;
      map['cleaningTime'] = d.cleaningTime;
      map['filterStatus'] = d.filterStatus;
      map['nextCleaning'] = d.nextCleaning;
    }

    return map;
  }

  static DeviceEntity fromMap(Map map) {
    final typeStr = map['type'] as String? ?? 'lamp';
    final type = DeviceType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => DeviceType.lamp,
    );

    final id = map['id'] as String;
    final name = map['name'] as String;
    final isOn = map['isOn'] as bool? ?? false;
    final roomId = map['roomId'] as String?;
    final positionX = (map['positionX'] as num?)?.toDouble();
    final positionY = (map['positionY'] as num?)?.toDouble();
    final markerWidth = (map['markerWidth'] as num?)?.toDouble();
    final markerHeight = (map['markerHeight'] as num?)?.toDouble();
    final showAsDot = map['showAsDot'] as bool? ?? false;
    final matterNodeId = map['matterNodeId'] as int?;
    final matterEndpointId = map['matterEndpointId'] as int?;
    final pin = map['pin'] as int?;

    switch (type) {
      case DeviceType.vacuum:
        return VacuumDeviceEntity(
          id: id,
          name: name,
          isOn: isOn,
          roomId: roomId,
          positionX: positionX,
          positionY: positionY,
          markerWidth: markerWidth,
          markerHeight: markerHeight,
          showAsDot: showAsDot,
          matterNodeId: matterNodeId,
          matterEndpointId: matterEndpointId,
          pin: pin,
          batteryLevel: map['batteryLevel'] as int?,
          areaCleaned: map['areaCleaned'] as int?,
          cleaningTime: map['cleaningTime'] as int?,
          filterStatus: map['filterStatus'] as int?,
          nextCleaning: map['nextCleaning'] as String?,
        );
      case DeviceType.airConditioner:
        return AcDeviceEntity(
          id: id,
          name: name,
          isOn: isOn,
          roomId: roomId,
          positionX: positionX,
          positionY: positionY,
          markerWidth: markerWidth,
          markerHeight: markerHeight,
          showAsDot: showAsDot,
          matterNodeId: matterNodeId,
          matterEndpointId: matterEndpointId,
          pin: pin,
          temperature: map['temperature'] as int?,
          mode: map['mode'] as String?,
          coolingTime: map['coolingTime'] as int?,
          acIrCodes: AcIrCodes(
            irPower: map['irPower'] as String?,
            irTempUp: map['irTempUp'] as String?,
            irTempDown: map['irTempDown'] as String?,
            irAuto: map['irAuto'] as String?,
            irCool: map['irCool'] as String?,
            irHeat: map['irHeat'] as String?,
            irEco: map['irEco'] as String?,
            irDry: map['irDry'] as String?,
            irFanQuiet: map['irFanQuiet'] as String?,
            irFanLow: map['irFanLow'] as String?,
            irFanMed: map['irFanMed'] as String?,
            irFanHigh: map['irFanHigh'] as String?,
            irFanAuto: map['irFanAuto'] as String?,
            irSwingV: map['irSwingV'] as String?,
            irSwingH: map['irSwingH'] as String?,
            irPlasmacluster: map['irPlasmacluster'] as String?,
            irSuperJet: map['irSuperJet'] as String?,
            irCoanda: map['irCoanda'] as String?,
            irMyArea: map['irMyArea'] as String?,
            irDisplay: map['irDisplay'] as String?,
            irClean: map['irClean'] as String?,
          ),
        );
      case DeviceType.lamp:
        return LampDeviceEntity(
          id: id,
          name: name,
          isOn: isOn,
          roomId: roomId,
          positionX: positionX,
          positionY: positionY,
          markerWidth: markerWidth,
          markerHeight: markerHeight,
          showAsDot: showAsDot,
          matterNodeId: matterNodeId,
          matterEndpointId: matterEndpointId,
          pin: pin,
          brightness: map['brightness'] as int?,
        );
      case DeviceType.rgb:
        return RgbLampDeviceEntity(
          id: id,
          name: name,
          isOn: isOn,
          roomId: roomId,
          positionX: positionX,
          positionY: positionY,
          markerWidth: markerWidth,
          markerHeight: markerHeight,
          showAsDot: showAsDot,
          matterNodeId: matterNodeId,
          matterEndpointId: matterEndpointId,
          pin: pin,
          brightness: map['brightness'] as int?,
          rgbR: map['rgbR'] as int?,
          rgbG: map['rgbG'] as int?,
          rgbB: map['rgbB'] as int?,
        );
      case DeviceType.door:
        return DoorDeviceEntity(
          id: id,
          name: name,
          isOn: isOn,
          roomId: roomId,
          positionX: positionX,
          positionY: positionY,
          markerWidth: markerWidth,
          markerHeight: markerHeight,
          showAsDot: showAsDot,
          matterNodeId: matterNodeId,
          matterEndpointId: matterEndpointId,
          pin: pin,
          isLocked: map['isLocked'] as bool?,
          linkedDevicesCount: map['linkedDevicesCount'] as int?,
        );
    }
  }

  // ── Helper ───────────────────────────────────────────────────────────────────

  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Returns all saved devices. Empty list if nothing has been saved yet.
  List<DeviceEntity> loadDevices() {
    if (_isTest) return [];
    final box = HiveService.devicesBox;
    return box.values
        .map((raw) => fromMap(Map<String, dynamic>.from(raw)))
        .toList();
  }

  /// Overwrites all saved devices with [devices].
  Future<void> saveDevices(List<DeviceEntity> devices) async {
    if (_isTest) return;
    final box = HiveService.devicesBox;
    await box.clear();
    final entries = {
      for (var d in devices) d.id: toMap(d),
    };
    await box.putAll(entries);
  }

  Future<void> clearDevices() async {
    if (_isTest) return;
    await HiveService.devicesBox.clear();
  }

  /// Returns true if there are any saved devices.
  bool get hasData {
    if (_isTest) return false;
    return HiveService.devicesBox.isNotEmpty;
  }
}
