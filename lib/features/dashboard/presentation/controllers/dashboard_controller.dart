import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/matter_service.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/device/data/models/ir_code_model.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/domain/usecases/get_rooms_usecase.dart';
import 'package:smart_home/features/room/domain/usecases/save_rooms_usecase.dart';
import 'package:smart_home/features/device/domain/usecases/get_devices_usecase.dart';
import 'package:smart_home/features/device/domain/usecases/save_devices_usecase.dart';
import 'package:smart_home/features/device/data/models/device_model.dart';
import 'package:smart_home/features/room/data/models/room_model.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/ir_learning_dialog.dart';
import 'package:smart_home/core/services/firebase_service.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/features/environment/presentation/providers/environment_provider.dart';

part 'dashboard_controller_rooms.dart';
part 'dashboard_controller_devices.dart';
part 'dashboard_controller_ir.dart';
part 'dashboard_controller.g.dart';

class DashboardState extends Equatable {
  final List<RoomEntity> rooms;
  final List<DeviceEntity> devices;

  // IR
  final Set<String> sendingIrKeys;

  const DashboardState({
    this.rooms = const [],
    this.devices = const [],
    this.sendingIrKeys = const {},
  });

  DashboardState copyWith({
    List<RoomEntity>? rooms,
    List<DeviceEntity>? devices,
    Set<String>? sendingIrKeys,
  }) {
    return DashboardState(
      rooms: rooms ?? this.rooms,
      devices: devices ?? this.devices,
      sendingIrKeys: sendingIrKeys ?? this.sendingIrKeys,
    );
  }

  @override
  List<Object?> get props => [
        rooms, devices, sendingIrKeys
      ];
}

@Riverpod(keepAlive: true)
class DashboardController extends _$DashboardController {
  bool _irBusy = false;
  final Dio dio = Dio();
  Timer? _acTimer;
  Timer? _espTimer;

  RoomEntity? get activeRoom {
    try {
      return state.rooms.firstWhere((r) => r.isActive);
    } catch (_) {
      return null;
    }
  }

  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  DashboardState build() {
    ref.onDispose(() {
      _acTimer?.cancel();
      _espTimer?.cancel();
    });

    if (_isTest) {
      final rooms = [
        const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
        const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
        const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
        const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
      ];
      final devices = _getMockDevices();
      return DashboardState(
        rooms: rooms,
        devices: devices,
      );
    }

    Future.microtask(() {
      _loadData();
      _startAcTimer();
      _startEsp32Polling();
      _initFirebaseListeners();
    });

    return const DashboardState();
  }

  // Methods for state mutation (if needed, otherwise rely on parts)


  void _initFirebaseListeners() {
    if (_isTest) return;

    final roomsSub = ref.read(firebaseServiceProvider.notifier).roomsStream.listen((roomsJson) {
      if (!ref.mounted) return;
      final firebaseRooms = roomsJson.map((json) => RoomModel.fromJson(json)).toList();
      if (firebaseRooms.isNotEmpty && firebaseRooms != state.rooms) {
        state = state.copyWith(rooms: firebaseRooms);
        ref.read(saveRoomsUseCaseProvider).call(firebaseRooms);
      }
    });
    ref.onDispose(roomsSub.cancel);

    final devicesSub = ref.read(firebaseServiceProvider.notifier).devicesStream.listen((devicesJson) {
      if (!ref.mounted) return;
      final firebaseDevices = devicesJson.map((json) => DeviceModel.fromJson(json).toEntity()).toList();
      
      // Preserve local IR codes that might not be in the devices stream
      for (int i = 0; i < firebaseDevices.length; i++) {
        final fDev = firebaseDevices[i];
        if (fDev is AcDeviceEntity) {
          final existing = state.devices.firstWhere(
            (d) => d.id == fDev.id,
            orElse: () => fDev,
          );
          if (existing is AcDeviceEntity) {
            firebaseDevices[i] = fDev.copyWith(acIrCodes: existing.acIrCodes);
          }
        }
      }

      if (firebaseDevices.isNotEmpty && firebaseDevices != state.devices) {
        state = state.copyWith(devices: firebaseDevices);
        ref.read(saveDevicesUseCaseProvider).call(firebaseDevices);
      }
    });
    ref.onDispose(devicesSub.cancel);
  }

  void _syncIrCodesFromFirebase() async {
    bool changed = false;
    final newDevices = List<DeviceEntity>.from(state.devices);
    for (int i = 0; i < newDevices.length; i++) {
      if (newDevices[i] is AcDeviceEntity) {
        final codes = await ref.read(firebaseServiceProvider.notifier).fetchIrCodes(newDevices[i].id);
        if (codes.isNotEmpty) {
          DeviceEntity updated = newDevices[i];
          codes.forEach((key, value) {
            final newUpdated = _applyIrField(updated, key, value);
            if (newUpdated != null) {
              updated = newUpdated;
            }
          });
          if (updated != newDevices[i]) {
            newDevices[i] = updated;
            changed = true;
          }
        }
      }
    }
    if (changed) {
      state = state.copyWith(devices: newDevices);
      _persistDevices();
    }
  }

  Future<void> _loadData() async {
    final getRoomsUseCase = ref.read(getRoomsUseCaseProvider);
    final getDevicesUseCase = ref.read(getDevicesUseCaseProvider);

    // 1. Load from local database first so UI is immediately responsive
    final loadedRooms = await getRoomsUseCase.call();
    if (!ref.mounted) return;
    final loadedDevices = await getDevicesUseCase.call();
    if (!ref.mounted) return;

    state = state.copyWith(rooms: loadedRooms, devices: loadedDevices);

    // 2. Fetch from Firebase to update/override local data
    if (!_isTest) {
      final firebaseNotifier = ref.read(firebaseServiceProvider.notifier);
      final firebaseRoomsJson = await firebaseNotifier.fetchRooms();
      if (!ref.mounted) return;
      final firebaseDevicesJson = await firebaseNotifier.fetchDevices();
      if (!ref.mounted) return;

      List<RoomEntity>? firebaseRooms;
      if (firebaseRoomsJson != null && firebaseRoomsJson.isNotEmpty) {
        firebaseRooms = firebaseRoomsJson.map((json) => RoomModel.fromJson(json)).toList();
      }

      List<DeviceEntity>? firebaseDevices;
      if (firebaseDevicesJson != null && firebaseDevicesJson.isNotEmpty) {
        firebaseDevices = firebaseDevicesJson.map((json) => DeviceModel.fromJson(json).toEntity()).toList();
      }

      if (firebaseRooms != null || firebaseDevices != null) {
        if (firebaseDevices != null) {
          for (int i = 0; i < firebaseDevices.length; i++) {
            final fDev = firebaseDevices[i];
            if (fDev is AcDeviceEntity) {
              final existing = loadedDevices.firstWhere(
                (d) => d.id == fDev.id,
                orElse: () => fDev,
              );
              if (existing is AcDeviceEntity) {
                firebaseDevices[i] = fDev.copyWith(acIrCodes: existing.acIrCodes);
              }
            }
          }
        }

        state = state.copyWith(
          rooms: firebaseRooms ?? state.rooms,
          devices: firebaseDevices ?? state.devices,
        );
        if (firebaseRooms != null) {
          await ref.read(saveRoomsUseCaseProvider).call(firebaseRooms);
          if (!ref.mounted) return;
        }
        if (firebaseDevices != null) {
          await ref.read(saveDevicesUseCaseProvider).call(firebaseDevices);
          if (!ref.mounted) return;
        }
        
        // After loading base devices, fetch missing IR codes from Firebase
        _syncIrCodesFromFirebase();
      } else {
        // Both local database and Firebase are empty, so seed with default mock data
        if (state.rooms.isEmpty && state.devices.isEmpty) {
          final seedRooms = [
            const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
            const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
            const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
            const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
          ];
          final seedDevices = _getMockDevices();
          state = state.copyWith(rooms: seedRooms, devices: seedDevices);

          await ref.read(saveRoomsUseCaseProvider).call(seedRooms);
          if (!ref.mounted) return;
          await ref.read(saveDevicesUseCaseProvider).call(seedDevices);
          if (!ref.mounted) return;

          _syncRoomsToFirebase();
          _syncDevicesToFirebase();
        }
      }
    } else {
      // For testing, if empty, seed with mock data
      if (loadedRooms.isEmpty && loadedDevices.isEmpty) {
        final seedRooms = [
          const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
          const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
          const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
          const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
        ];
        final seedDevices = _getMockDevices();
        state = state.copyWith(rooms: seedRooms, devices: seedDevices);
      }
    }
  }

  Future<void> _persistRooms() async {
    if (!_isTest) {
      await ref.read(saveRoomsUseCaseProvider).call(state.rooms);
      _syncRoomsToFirebase();
    }
  }

  Future<void> _persistDevices() async {
    if (!_isTest) {
      await ref.read(saveDevicesUseCaseProvider).call(state.devices);
      _syncDevicesToFirebase();
    }
  }

  void _syncRoomsToFirebase() {
    if (!_isTest) {
      final roomsJson = state.rooms.map((r) => RoomModel.fromEntity(r).toJson()).toList();
      ref.read(firebaseServiceProvider.notifier).syncRooms(roomsJson);
    }
  }

  void _syncDevicesToFirebase() {
    if (!_isTest) {
      final devicesJson = state.devices.map((d) => DeviceModel.fromEntity(d).toJson(excludeIrCodes: true)).toList();
      ref.read(firebaseServiceProvider.notifier).syncDevices(devicesJson);
    }
  }

  List<DeviceEntity> _getMockDevices() {
    return [
      DoorDeviceEntity(
        id: 'door1',
        name: 'Smart Door',
        isLocked: true,
        positionX: 0.8,
        positionY: 0.55,
        roomId: '3',
      ),
      VacuumDeviceEntity(
        id: 'vac1',
        name: 'Robot vacuum cleaner',
        isOn: true,
        batteryLevel: 75,
        areaCleaned: 82,
        cleaningTime: 32,
        filterStatus: 72,
        nextCleaning: '10:30 AM',
        positionX: 0.35,
        positionY: 0.75,
        roomId: '3',
      ),
      AcDeviceEntity(
        id: 'ac1',
        name: 'Dining Area AC',
        isOn: true,
        temperature: 21,
        mode: 'Auto mode',
        coolingTime: 35,
        positionX: 0.25,
        positionY: 0.35,
        roomId: '3',
        acIrCodes: AcIrCodes(),
      ),
      AcDeviceEntity(
        id: 'ac2',
        name: 'TV Area AC',
        isOn: false,
        temperature: 24,
        mode: 'Eco mode',
        coolingTime: 10,
        positionX: 0.72,
        positionY: 0.32,
        roomId: '3',
        acIrCodes: AcIrCodes(),
      ),
      LampDeviceEntity(
        id: 'lamp1',
        name: 'Smart Lamp',
        isOn: true,
        brightness: 158,
        positionX: 0.52,
        positionY: 0.18,
        roomId: '3',
      ),
      RgbLampDeviceEntity(
        id: 'rgb1',
        name: 'RGB Strip',
        isOn: true,
        rgbR: 98,
        rgbG: 52,
        rgbB: 234,
        brightness: 204,
        positionX: 0.65,
        positionY: 0.65,
        roomId: '3',
      ),
      // Bedroom (ID '1')
      AcDeviceEntity(
        id: 'ac_bed',
        name: 'Bedroom AC',
        isOn: true,
        temperature: 22,
        mode: 'Quiet mode',
        coolingTime: 12,
        positionX: 0.3,
        positionY: 0.3,
        roomId: '1',
        acIrCodes: AcIrCodes(),
      ),
      LampDeviceEntity(
        id: 'lamp_bed',
        name: 'Bedside Lamp',
        isOn: true,
        brightness: 102,
        positionX: 0.7,
        positionY: 0.4,
        roomId: '1',
      ),
      // Kitchen (ID '2')
      RgbLampDeviceEntity(
        id: 'rgb_kitchen',
        name: 'Kitchen LED Strip',
        isOn: true,
        rgbR: 255,
        rgbG: 180,
        rgbB: 0,
        brightness: 191,
        positionX: 0.45,
        positionY: 0.25,
        roomId: '2',
      ),
      VacuumDeviceEntity(
        id: 'vac_kitchen',
        name: 'Kitchen Vacuum',
        isOn: false,
        batteryLevel: 90,
        positionX: 0.2,
        positionY: 0.8,
        roomId: '2',
      ),
      // Bathroom (ID '4')
      LampDeviceEntity(
        id: 'lamp_bath',
        name: 'Mirror Light',
        isOn: true,
        brightness: 204,
        positionX: 0.5,
        positionY: 0.25,
        roomId: '4',
      ),
    ];
  }

  @visibleForTesting
  void setDevicesForTest(List<DeviceEntity> testDevices) {
    state = state.copyWith(devices: testDevices);
  }

  @visibleForTesting
  void setRoomsForTest(List<RoomEntity> testRooms) {
    state = state.copyWith(rooms: testRooms);
  }
}
