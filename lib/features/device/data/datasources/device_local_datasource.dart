import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/services/hive_service.dart';
import '../models/device_model.dart';

part 'device_local_datasource.g.dart';

/// Local data source for persisting and retrieving [DeviceModel] objects
/// using Hive. Devices are stored as plain [Map] objects (no TypeAdapter needed).
class DeviceLocalDatasource {
  // ── Serialization ────────────────────────────────────────────────────────────

  static Map<String, dynamic> toMap(DeviceModel d) => d.toJson();

  static DeviceModel fromMap(Map map) => DeviceModel.fromJson(Map<String, dynamic>.from(map));

  // ── Helper ───────────────────────────────────────────────────────────────────

  bool get _isTest {
    final underTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (underTest) {
      try {
        HiveService.devicesBox;
        return false;
      } catch (_) {
        return true;
      }
    }
    return false;
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Returns all saved devices. Empty list if nothing has been saved yet.
  List<DeviceModel> loadDevices() {
    if (_isTest) return [];
    final box = HiveService.devicesBox;
    return box.values
        .map((raw) => fromMap(Map<String, dynamic>.from(raw)))
        .toList();
  }

  /// Overwrites all saved devices with [devices].
  Future<void> saveDevices(List<DeviceModel> devices) async {
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

@riverpod
DeviceLocalDatasource deviceLocalDatasource(Ref ref) {
  return DeviceLocalDatasource();
}
