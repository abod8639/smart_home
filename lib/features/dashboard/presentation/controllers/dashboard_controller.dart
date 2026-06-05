import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/matter_service.dart';
import 'package:smart_home/features/device/data/datasources/device_local_datasource.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/data/datasources/room_local_datasource.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/ir_learning_dialog.dart';
import 'package:smart_home/core/services/firebase_service.dart';

part 'dashboard_controller_weather.dart';
part 'dashboard_controller_rooms.dart';
part 'dashboard_controller_devices.dart';
part 'dashboard_controller_ir.dart';

class DashboardController extends GetxController {
  // Observables
  var rooms = <RoomEntity>[].obs;
  var devices = <DeviceEntity>[].obs;
  var currentNavigationIndex = 0.obs;
  
  // Environment Stats for the selected room
  var humidity = '50%'.obs;
  var airflow = '80%'.obs;
  var temperature = '27°'.obs;
  var powerUsage = '360W'.obs;
  var wifiRssi = '- dBm'.obs;
  var heapFree = '0 KB'.obs;

  // Live Weather Observables
  var weatherLocation = 'Loading...'.obs;
  var weatherTemp = '--°C'.obs;
  var weatherCondition = 'Fetching...'.obs;
  var weatherDate = ''.obs;
  var weatherSuggestion = 'Optimizing settings...'.obs;
  var isWeatherLoading = true.obs;
  var isDay = 1.obs; // 1 = Day, 0 = Night
  var weatherCode = 0.obs;

  /// Tracks in-flight IR sends per "deviceId::fieldKey" for UI loading states.
  var sendingIrKeys = <String>{}.obs;

  /// Mutex flag — only one IR HTTP request at a time to prevent ESP32 overlap.
  bool _irBusy = false;

  final Dio _dio = Dio();
  Timer? _acTimer;
  Timer? _espTimer;
  final DeviceLocalDatasource _datasource = DeviceLocalDatasource();
  final RoomLocalDatasource _roomDatasource = RoomLocalDatasource();

  RoomEntity? get activeRoom => rooms.firstWhereOrNull((r) => r.isActive);

  void changeTab(int index) {
    currentNavigationIndex.value = index;
  }

  bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  @override
  void onInit() {
    super.onInit();
    _loadData();
    if (!_isTest) {
      fetchLiveWeather();
      _startAcTimer();
      _startEsp32Polling();
      _initFirebaseListeners();
      _syncIrCodesFromFirebase();
    } else {
      isWeatherLoading.value = false;
      weatherLocation.value = 'Mock City';
      weatherTemp.value = '25°C';
      weatherCondition.value = 'Sunny';
    }
  }

  @override
  void onClose() {
    _acTimer?.cancel();
    _espTimer?.cancel();
    super.onClose();
  }

  void _initFirebaseListeners() {
    if (Get.isRegistered<FirebaseService>()) {
      final fb = Get.find<FirebaseService>();
      
      // Update temperature from Firebase if local WebSocket is down
      fb.temperatureStream.listen((event) {
        if (Get.isRegistered<Esp32Service>() && !Get.find<Esp32Service>().isConnected.value) {
          final val = event.snapshot.value;
          if (val != null) {
            temperature.value = '$val°';
          }
        }
      });

      // Update humidity from Firebase if local WebSocket is down
      fb.humidityStream.listen((event) {
        if (Get.isRegistered<Esp32Service>() && !Get.find<Esp32Service>().isConnected.value) {
          final val = event.snapshot.value;
          if (val != null) {
            humidity.value = '$val%';
          }
        }
      });
    }
  }

  void _syncIrCodesFromFirebase() async {
    if (Get.isRegistered<FirebaseService>()) {
      bool changed = false;
      for (int i = 0; i < devices.length; i++) {
        if (devices[i] is AcDeviceEntity) {
          final codes = await Get.find<FirebaseService>().fetchIrCodes(devices[i].id);
          if (codes.isNotEmpty) {
            DeviceEntity updated = devices[i];
            codes.forEach((key, value) {
              final newUpdated = _applyIrField(updated, key, value);
              if (newUpdated != null) {
                updated = newUpdated;
              }
            });
            if (updated != devices[i]) {
              devices[i] = updated;
              changed = true;
            }
          }
        }
      }
      if (changed) {
        _persistDevices();
      }
    }
  }

  void _loadData() {
    // Prefer Hive-persisted rooms; fall back to mock only on first launch
    if (_roomDatasource.hasData) {
      rooms.value = _roomDatasource.loadRooms();
    } else {
      rooms.value = [
        const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
        const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
        const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
        const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
      ];
      _persistRooms();
    }

    // Prefer Hive-persisted devices; fall back to mock only on first launch
    if (_datasource.hasData) {
      devices.value = _datasource.loadDevices();
    } else {
      _loadMockData();
      _persistDevices(); // seed Hive with the initial mock data
    }
  }

  void _persistRooms() {
    if (!_isTest) {
      _roomDatasource.saveRooms(rooms.toList());
    }
  }

  /// Save current devices snapshot to Hive.
  void _persistDevices() {
    if (!_isTest) {
      _datasource.saveDevices(devices.toList());
    }
  }

  /// Seeds the initial mock devices on the very first launch.
  void _loadMockData() {
    devices.value = [
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
        brightness: 62,
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
        brightness: 80,
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
        brightness: 40,
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
        brightness: 75,
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
        brightness: 80,
        positionX: 0.5,
        positionY: 0.25,
        roomId: '4',
      ),
    ];
  }
}
