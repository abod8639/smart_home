import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/matter_service.dart';
import 'package:smart_home/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:smart_home/features/dashboard/domain/usecases/send_hardware_command_usecase.dart';
import 'package:smart_home/features/dashboard/domain/usecases/sync_dashboard_devices_usecase.dart';
import 'package:smart_home/features/dashboard/domain/usecases/sync_dashboard_rooms_usecase.dart';
import 'package:smart_home/features/dashboard/domain/usecases/sync_ir_codes_usecase.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/device/data/models/ir_code_model.dart';
import 'package:smart_home/features/environment/presentation/controllers/environment_controller.dart';
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
import 'package:smart_home/core/services/auth_service.dart';
import 'package:smart_home/core/utils/formatting_utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_controller_rooms.dart';
part 'dashboard_controller_devices.dart';
part 'dashboard_controller_ir.dart';
part 'dashboard_controller.g.dart';

/// Presentation state for the dashboard, extending [DashboardOverviewEntity].
class DashboardState extends DashboardOverviewEntity {
  const DashboardState({
    super.rooms = const [],
    super.devices = const [],
    super.sendingIrKeys = const {},
    super.pendingDeviceIds = const {},
  });

  @override
  DashboardState copyWith({
    List<RoomEntity>? rooms,
    List<DeviceEntity>? devices,
    Set<String>? sendingIrKeys,
    Set<String>? pendingDeviceIds,
  }) {
    return DashboardState(
      rooms: rooms ?? this.rooms,
      devices: devices ?? this.devices,
      sendingIrKeys: sendingIrKeys ?? this.sendingIrKeys,
      pendingDeviceIds: pendingDeviceIds ?? this.pendingDeviceIds,
    );
  }
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
    ref.watch(authStateProvider);
    ref.onDispose(() {
      _acTimer?.cancel();
      _espTimer?.cancel();
    });

    if (_isTest) {
      final rooms = FormattingUtils.mockRooms;
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

    final roomsSub = ref.read(syncDashboardRoomsUseCaseProvider).watchRooms().listen((firebaseRooms) {
      if (!ref.mounted) return;
      final newState = state.copyWith(rooms: firebaseRooms);
      if (state != newState) {
        state = newState;
        ref.read(saveRoomsUseCaseProvider).call(firebaseRooms);
      }
    });
    ref.onDispose(roomsSub.cancel);

    final devicesSub = ref.read(syncDashboardDevicesUseCaseProvider).watchDevices().listen((firebaseDevices) {
      if (!ref.mounted) return;
      
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

      final newState = state.copyWith(devices: firebaseDevices);
      if (state != newState) {
        state = newState;
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
        final codes = await ref.read(syncIrCodesUseCaseProvider).call(newDevices[i].id);
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

    List<RoomEntity> roomsToUse = loadedRooms;
    bool roomsNeedSeeding = false;
    if (loadedRooms.isEmpty) {
      roomsNeedSeeding = true;
      roomsToUse = FormattingUtils.mockRooms;
    }

    List<DeviceEntity> devicesToUse = loadedDevices;
    bool devicesNeedSeeding = false;
    if (loadedDevices.isEmpty) {
      devicesNeedSeeding = true;
      devicesToUse = _getMockDevices();
    }

    state = state.copyWith(rooms: roomsToUse, devices: devicesToUse);

    if (roomsNeedSeeding) {
      await ref.read(saveRoomsUseCaseProvider).call(roomsToUse);
      if (!ref.mounted) return;
    }
    if (devicesNeedSeeding) {
      await ref.read(saveDevicesUseCaseProvider).call(devicesToUse);
      if (!ref.mounted) return;
    }

    // 2. Fetch from remote repository to update/override local data
    if (!_isTest) {
      final syncRoomsUseCase = ref.read(syncDashboardRoomsUseCaseProvider);
      final syncDevicesUseCase = ref.read(syncDashboardDevicesUseCaseProvider);

      final firebaseRooms = await syncRoomsUseCase.fetchRooms();
      if (!ref.mounted) return;
      final firebaseDevices = await syncDevicesUseCase.fetchDevices();
      if (!ref.mounted) return;

      if ((firebaseRooms != null && firebaseRooms.isNotEmpty) ||
          (firebaseDevices != null && firebaseDevices.isNotEmpty)) {
        if (firebaseDevices != null && firebaseDevices.isNotEmpty) {
          for (int i = 0; i < firebaseDevices.length; i++) {
            final fDev = firebaseDevices[i];
            if (fDev is AcDeviceEntity) {
              final existing = devicesToUse.firstWhere(
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
          rooms: (firebaseRooms != null && firebaseRooms.isNotEmpty) ? firebaseRooms : state.rooms,
          devices: (firebaseDevices != null && firebaseDevices.isNotEmpty) ? firebaseDevices : state.devices,
        );
        if (firebaseRooms != null && firebaseRooms.isNotEmpty) {
          await ref.read(saveRoomsUseCaseProvider).call(firebaseRooms);
          if (!ref.mounted) return;
        }
        if (firebaseDevices != null && firebaseDevices.isNotEmpty) {
          await ref.read(saveDevicesUseCaseProvider).call(firebaseDevices);
          if (!ref.mounted) return;
        }
        
        // After loading base devices, fetch missing IR codes from Firebase
        _syncIrCodesFromFirebase();
      } else {
        // Firebase is empty, sync seeded local data to Firebase
        _syncRoomsToFirebase();
        _syncDevicesToFirebase();
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
