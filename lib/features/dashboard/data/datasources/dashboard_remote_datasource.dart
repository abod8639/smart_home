import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/firebase_service.dart';
import 'package:smart_home/core/services/matter_service.dart';
import 'package:smart_home/features/device/data/models/device_model.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/data/models/room_model.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

part 'dashboard_remote_datasource.g.dart';

/// Contract for the dashboard remote data source.
abstract class DashboardRemoteDataSource {
  Future<List<RoomEntity>?> fetchRooms();
  Future<List<DeviceEntity>?> fetchDevices();
  Stream<List<RoomEntity>> get roomsStream;
  Stream<List<DeviceEntity>> get devicesStream;
  Future<Map<String, dynamic>> fetchIrCodes(String deviceId);
  Future<void> sendEsp32Command(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? data,
  });
  Future<void> toggleMatterDevice(int nodeId, int endpointId, bool isOn);
}

/// Implementation of [DashboardRemoteDataSource] integrating Firebase, ESP32, and Matter.
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseService _firebaseService;
  final Esp32Service _esp32Service;
  final MatterService _matterService;

  DashboardRemoteDataSourceImpl(
    this._firebaseService,
    this._esp32Service,
    this._matterService,
  );

  @override
  Future<List<RoomEntity>?> fetchRooms() async {
    final rawRooms = await _firebaseService.fetchRooms();
    if (rawRooms == null) return null;
    return rawRooms
        .map((json) {
          try {
            return RoomModel.fromJson(json);
          } catch (e) {
            if (kDebugMode) print('Error parsing remote room: $e');
            return null;
          }
        })
        .whereType<RoomEntity>()
        .toList();
  }

  @override
  Future<List<DeviceEntity>?> fetchDevices() async {
    final rawDevices = await _firebaseService.fetchDevices();
    if (rawDevices == null) return null;
    return rawDevices
        .map((json) {
          try {
            return DeviceModel.fromJson(json).toEntity();
          } catch (e) {
            if (kDebugMode) print('Error parsing remote device: $e');
            return null;
          }
        })
        .whereType<DeviceEntity>()
        .toList();
  }

  @override
  Stream<List<RoomEntity>> get roomsStream =>
      _firebaseService.roomsStream.map((list) => list
          .map((json) {
            try {
              return RoomModel.fromJson(json);
            } catch (e) {
              return null;
            }
          })
          .whereType<RoomEntity>()
          .toList());

  @override
  Stream<List<DeviceEntity>> get devicesStream =>
      _firebaseService.devicesStream.map((list) => list
          .map((json) {
            try {
              return DeviceModel.fromJson(json).toEntity();
            } catch (e) {
              return null;
            }
          })
          .whereType<DeviceEntity>()
          .toList());

  @override
  Future<Map<String, dynamic>> fetchIrCodes(String deviceId) async {
    return await _firebaseService.fetchIrCodes(deviceId);
  }

  @override
  Future<void> sendEsp32Command(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? data,
  }) async {
    _esp32Service.sendRawCommand(path, method: method, data: data);
  }

  @override
  Future<void> toggleMatterDevice(int nodeId, int endpointId, bool isOn) async {
    _matterService.toggleDevice(nodeId, endpointId, isOn);
  }
}

/// Provider for accessing [DashboardRemoteDataSource].
@riverpod
DashboardRemoteDataSource dashboardRemoteDataSource(Ref ref) {
  return DashboardRemoteDataSourceImpl(
    ref.watch(firebaseServiceProvider.notifier),
    ref.watch(esp32ServiceProvider.notifier),
    ref.watch(matterServiceProvider.notifier),
  );
}
