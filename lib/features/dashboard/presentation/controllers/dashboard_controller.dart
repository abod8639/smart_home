import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/features/device/data/datasources/device_local_datasource.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/data/datasources/room_local_datasource.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';

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

  // Live Weather Observables
  var weatherLocation = 'Loading...'.obs;
  var weatherTemp = '--°C'.obs;
  var weatherCondition = 'Fetching...'.obs;
  var weatherDate = ''.obs;
  var weatherSuggestion = 'Optimizing settings...'.obs;
  var isWeatherLoading = true.obs;
  var isDay = 1.obs; // 1 = Day, 0 = Night
  var weatherCode = 0.obs;

  final Dio _dio = Dio();
  Timer? _acTimer;
  Timer? _espTimer;
  final DeviceLocalDatasource _datasource = DeviceLocalDatasource();
  final RoomLocalDatasource _roomDatasource = RoomLocalDatasource();

  RoomEntity? get activeRoom => rooms.firstWhereOrNull((r) => r.isActive);

  void changeTab(int index) {
    currentNavigationIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      fetchLiveWeather();
      _startAcTimer();
      _startEsp32Polling();
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
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _roomDatasource.saveRooms(rooms.toList());
    }
  }

  /// Save current devices snapshot to Hive.
  void _persistDevices() {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _datasource.saveDevices(devices.toList());
    }
  }

  /// Seeds the initial mock devices on the very first launch.
  void _loadMockData() {
    devices.value = [
      const DeviceEntity(
        id: 'door1',
        name: 'Smart Door',
        type: DeviceType.door,
        isLocked: true,
        positionX: 0.8,
        positionY: 0.55,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'vac1',
        name: 'Robot vacuum cleaner',
        type: DeviceType.vacuum,
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
      const DeviceEntity(
        id: 'ac1',
        name: 'Dining Area AC',
        type: DeviceType.airConditioner,
        isOn: true,
        temperature: 21,
        mode: 'Auto mode',
        coolingTime: 35,
        positionX: 0.25,
        positionY: 0.35,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'ac2',
        name: 'TV Area AC',
        type: DeviceType.airConditioner,
        isOn: false,
        temperature: 24,
        mode: 'Eco mode',
        coolingTime: 10,
        positionX: 0.72,
        positionY: 0.32,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'lamp1',
        name: 'Smart Lamp',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 62,
        positionX: 0.52,
        positionY: 0.18,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'rgb1',
        name: 'RGB Strip',
        type: DeviceType.rgb,
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
      const DeviceEntity(
        id: 'ac_bed',
        name: 'Bedroom AC',
        type: DeviceType.airConditioner,
        isOn: true,
        temperature: 22,
        mode: 'Quiet mode',
        coolingTime: 12,
        positionX: 0.3,
        positionY: 0.3,
        roomId: '1',
      ),
      const DeviceEntity(
        id: 'lamp_bed',
        name: 'Bedside Lamp',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 40,
        positionX: 0.7,
        positionY: 0.4,
        roomId: '1',
      ),
      // Kitchen (ID '2')
      const DeviceEntity(
        id: 'rgb_kitchen',
        name: 'Kitchen LED Strip',
        type: DeviceType.rgb,
        isOn: true,
        rgbR: 255,
        rgbG: 180,
        rgbB: 0,
        brightness: 75,
        positionX: 0.45,
        positionY: 0.25,
        roomId: '2',
      ),
      const DeviceEntity(
        id: 'vac_kitchen',
        name: 'Kitchen Vacuum',
        type: DeviceType.vacuum,
        isOn: false,
        batteryLevel: 90,
        positionX: 0.2,
        positionY: 0.8,
        roomId: '2',
      ),
      // Bathroom (ID '4')
      const DeviceEntity(
        id: 'lamp_bath',
        name: 'Mirror Light',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 80,
        positionX: 0.5,
        positionY: 0.25,
        roomId: '4',
      ),
    ];
  }


  void toggleDevice(String id) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final newIsOn = !device.isOn;

      if (device.type == DeviceType.airConditioner) {
        // Toggle all AC devices to match
        for (int i = 0; i < devices.length; i++) {
          if (devices[i].type == DeviceType.airConditioner) {
            devices[i] = devices[i].copyWith(isOn: newIsOn);
          }
        }
      } else {
        devices[index] = device.copyWith(isOn: newIsOn);
      }
      _persistDevices();

      // Trigger ESP32 if the device matches our GPIO mappings
      if (Get.isRegistered<Esp32Service>()) {
        if (device.type == DeviceType.lamp) {
          Get.find<Esp32Service>().setDigitalOutput(2, newIsOn);
        } else if (device.type == DeviceType.airConditioner) {
          Get.find<Esp32Service>().sendRawCommand(
            'control/ac',
            method: 'POST',
            data: {'isOn': newIsOn},
          );
        }
      }
    }
  }
  
  void toggleDoor(String id) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final newIsLocked = !(device.isLocked ?? false);
      devices[index] = device.copyWith(isLocked: newIsLocked);
      _persistDevices();

      // Unlocked = Relay HIGH, Locked = Relay LOW
      if (id == 'door1' && Get.isRegistered<Esp32Service>()) {
        Get.find<Esp32Service>().setDigitalOutput(18, !newIsLocked);
      }
    }
  }

  void selectRoom(String id) {
    rooms.value = rooms.map((r) => r.copyWith(isActive: r.id == id)).toList();
    _persistRooms();
    if (Get.isRegistered<RoomPlacementController>()) {
      Get.find<RoomPlacementController>().selectDevice(null);
    }
  }

  void addRoom(RoomEntity room) {
    rooms.add(room);
    _persistRooms();
  }

  void updateRoom(RoomEntity room) {
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      rooms[index] = room;
      _persistRooms();
    }
  }

  void deleteRoom(String id) {
    rooms.removeWhere((r) => r.id == id);
    // If the active room is deleted, select the first remaining room
    final hasActive = rooms.any((r) => r.isActive);
    if (!hasActive && rooms.isNotEmpty) {
      rooms[0] = rooms[0].copyWith(isActive: true);
    }
    _persistRooms();
  }

  void updateAcTemperature(String id, int temp) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newTemp = temp.clamp(16, 30);
      
      // Update all devices of type airConditioner to match new temperature
      for (int i = 0; i < devices.length; i++) {
        if (devices[i].type == DeviceType.airConditioner) {
          devices[i] = devices[i].copyWith(temperature: newTemp);
        }
      }
      _persistDevices();

      // Control ESP32 AC Target Temperature via raw endpoint /control/ac
      if (Get.isRegistered<Esp32Service>()) {
        Get.find<Esp32Service>().sendRawCommand(
          'control/ac',
          method: 'POST',
          data: {'target_temp': newTemp},
        );
      }
    }
  }

  void updateDeviceBrightness(String id, int brightness) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final newIsOn = brightness > 0;
      devices[index] = device.copyWith(
        brightness: brightness,
        isOn: newIsOn,
      );
      _persistDevices();

      // Control ESP32 PWM lamp (pin 22)
      if (id == 'lamp1' && Get.isRegistered<Esp32Service>()) {
        Get.find<Esp32Service>().setAnalogOutput(22, brightness);
      }
    }
  }

  void updateDeviceColor(String id, int r, int g, int b) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(rgbR: r, rgbG: g, rgbB: b);
      _persistDevices();

      // Control ESP32 RGB Strip channels (R: 23, G: 25, B: 26)
      if (id == 'rgb1' && Get.isRegistered<Esp32Service>()) {
        final esp = Get.find<Esp32Service>();
        esp.setAnalogOutput(23, r);
        esp.setAnalogOutput(25, g);
        esp.setAnalogOutput(26, b);
      }
    }
  }

  void updateDeviceMarkerSize(String id, double width, double height, {bool persist = true}) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(
        markerWidth: width.clamp(0.05, 0.8),
        markerHeight: height.clamp(0.05, 0.8),
      );
      if (persist) {
        _persistDevices();
      }
    }
  }


  void addDevice(DeviceEntity device) {
    var deviceWithRoom = device.roomId == null && activeRoom != null
        ? device.copyWith(roomId: activeRoom!.id)
        : device;
    // Default position to center if null
    final deviceWithPos = deviceWithRoom.positionX == null 
        ? deviceWithRoom.copyWith(positionX: 0.5, positionY: 0.5)
        : deviceWithRoom;
    devices.add(deviceWithPos);
    _persistDevices();
  }

  void updateDevice(DeviceEntity device) {
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      devices[index] = device;
      _persistDevices();
    }
  }

  void deleteDevice(String id) {
    devices.removeWhere((d) => d.id == id);
    _persistDevices();
  }

  void updateDevicePosition(String id, double x, double y, {bool persist = true}) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(positionX: x, positionY: y);
      if (persist) {
        _persistDevices();
      }
    }
  }

  void persistDevices() {
    _persistDevices();
  }

  void reorderDevices(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final device = devices.removeAt(oldIndex);
    devices.insert(newIndex, device);
    _persistDevices();
  }

  // Fetch real weather and geolocation details
  Future<void> fetchLiveWeather() async {
    isWeatherLoading.value = true;
    weatherDate.value = _getFormattedDate();

    try {
      // Step 1: Geolocation using ipapi.co
      final geoResponse = await _dio.get('https://ipapi.co/json/');
      if (geoResponse.statusCode == 200 && geoResponse.data != null) {
        final data = geoResponse.data;
        final city = data['city'] ?? 'Cairo';
        final country = data['country_name'] ?? 'Egypt';
        final double lat = (data['latitude'] as num?)?.toDouble() ?? 30.0507;
        final double lon = (data['longitude'] as num?)?.toDouble() ?? 31.2489;

        weatherLocation.value = '$city, $country';

        // Step 2: Fetch weather details using Open-Meteo
        final weatherResponse = await _dio.get(
          'https://api.open-meteo.com/v1/forecast',
          queryParameters: {
            'latitude': lat,
            'longitude': lon,
            'current_weather': true,
          },
        );

        if (weatherResponse.statusCode == 200 && weatherResponse.data != null) {
          final weatherData = weatherResponse.data['current_weather'];
          if (weatherData != null) {
            final double temp = (weatherData['temperature'] as num?)?.toDouble() ?? 27.0;
            final int code = (weatherData['weathercode'] as num?)?.toInt() ?? 0;
            final int dayFlag = (weatherData['is_day'] as num?)?.toInt() ?? 1;

            weatherTemp.value = '${temp.round()}°C';
            weatherCode.value = code;
            isDay.value = dayFlag;
            weatherCondition.value = _mapWeatherCode(code, dayFlag);
            weatherSuggestion.value = _generateSuggestion(temp, code);
          }
        }
      }
    } catch (e) {
      // Fallback gracefully on network error
      weatherLocation.value = 'Jakarta, Indonesia';
      weatherTemp.value = '27°C';
      weatherCondition.value = 'Clear Evening';
      isDay.value = 0;
      weatherCode.value = 0;
      weatherSuggestion.value = "Activate 'Relax Mode', dim lights, soft music, and lower thermostat.";
    } finally {
      isWeatherLoading.value = false;
    }
  }

  // Format date to: weekday, month day
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  // Map WMO codes to weather conditions
  String _mapWeatherCode(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    switch (code) {
      case 0:
        return isNight ? 'Clear Evening' : 'Sunny Day';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Light Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return isNight ? 'Clear Evening' : 'Clear Day';
    }
  }

  // Generate dynamic contextual suggestion
  String _generateSuggestion(double temp, int code) {
    if (code >= 50 && code <= 99) {
      return "Rainy weather. Perfect time to stay warm, dim the lights and play cozy music.";
    }
    if (temp > 30) {
      return "It's hot outside. Lowering the AC to 22°C and activating air circulation is recommended.";
    }
    if (temp < 18) {
      return "Cold outside. Activating heating mode on the AC and setting comfortable lighting.";
    }
    return "Weather is pleasant. Open windows for fresh air or keep lights dim for a relaxed evening.";
  }

  void _startAcTimer() {
    _acTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      for (int i = 0; i < devices.length; i++) {
        final d = devices[i];
        if (d.type == DeviceType.airConditioner && d.isOn) {
          devices[i] = d.copyWith(coolingTime: (d.coolingTime ?? 0) + 1);
        }
      }
    });
  }

  void _startEsp32Polling() {
    _espTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!Get.isRegistered<Esp32Service>()) return;
      try {
        final response = await Get.find<Esp32Service>().getSensorData();
        if (response.isSuccess && response.data != null) {
          final data = response.data!;
          if (data['temperature'] != null) {
            temperature.value = '${data['temperature']}°';
          }
          if (data['humidity'] != null) {
            humidity.value = '${data['humidity']}%';
          }

          // Sync target AC temperature
          if (data['target_temperature'] != null) {
            final int targetTemp = data['target_temperature'];
            for (int i = 0; i < devices.length; i++) {
              if (devices[i].type == DeviceType.airConditioner && devices[i].temperature != targetTemp) {
                devices[i] = devices[i].copyWith(temperature: targetTemp);
              }
            }
          }

          if (data['pins'] != null) {
            final pinsMap = data['pins'] as Map<String, dynamic>;

            // Sync GPIO 2 (relay_1 / lamp1)
            if (pinsMap.containsKey('relay_1')) {
              final int val = pinsMap['relay_1'];
              final lampIndex = devices.indexWhere((d) => d.id == 'lamp1');
              if (lampIndex != -1 && devices[lampIndex].isOn != (val == 1)) {
                devices[lampIndex] = devices[lampIndex].copyWith(isOn: val == 1);
              }
            }

            // Sync GPIO 18 (relay_2 / door1)
            if (pinsMap.containsKey('relay_2')) {
              final int val = pinsMap['relay_2'];
              final doorIndex = devices.indexWhere((d) => d.id == 'door1');
              if (doorIndex != -1 && (devices[doorIndex].isLocked ?? true) != (val == 0)) {
                devices[doorIndex] = devices[doorIndex].copyWith(isLocked: val == 0);
              }
            }

            // Sync GPIO 19 (relay_3 / all ACs)
            if (pinsMap.containsKey('relay_3')) {
              final int val = pinsMap['relay_3'];
              final isAcOn = (val == 1);
              for (int i = 0; i < devices.length; i++) {
                if (devices[i].type == DeviceType.airConditioner && devices[i].isOn != isAcOn) {
                  devices[i] = devices[i].copyWith(isOn: isAcOn);
                }
              }
            }
          }
        }
      } catch (e) {
        // Silently catch background polling exceptions
      }
    });
  }
}

