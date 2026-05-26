import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

class DashboardState {
  final List<RoomEntity> rooms;
  final List<DeviceEntity> devices;
  final int currentNavigationIndex;
  
  final String humidity;
  final String airflow;
  final String temperature;
  final String powerUsage;

  final String weatherLocation;
  final String weatherTemp;
  final String weatherCondition;
  final String weatherDate;
  final String weatherSuggestion;
  final bool isWeatherLoading;
  final int isDay;
  final int weatherCode;

  const DashboardState({
    this.rooms = const [],
    this.devices = const [],
    this.currentNavigationIndex = 0,
    this.humidity = '50%',
    this.airflow = '80%',
    this.temperature = '27°',
    this.powerUsage = '360W',
    this.weatherLocation = 'Loading...',
    this.weatherTemp = '--°C',
    this.weatherCondition = 'Fetching...',
    this.weatherDate = '',
    this.weatherSuggestion = 'Optimizing settings...',
    this.isWeatherLoading = true,
    this.isDay = 1,
    this.weatherCode = 0,
  });

  DashboardState copyWith({
    List<RoomEntity>? rooms,
    List<DeviceEntity>? devices,
    int? currentNavigationIndex,
    String? humidity,
    String? airflow,
    String? temperature,
    String? powerUsage,
    String? weatherLocation,
    String? weatherTemp,
    String? weatherCondition,
    String? weatherDate,
    String? weatherSuggestion,
    bool? isWeatherLoading,
    int? isDay,
    int? weatherCode,
  }) {
    return DashboardState(
      rooms: rooms ?? this.rooms,
      devices: devices ?? this.devices,
      currentNavigationIndex: currentNavigationIndex ?? this.currentNavigationIndex,
      humidity: humidity ?? this.humidity,
      airflow: airflow ?? this.airflow,
      temperature: temperature ?? this.temperature,
      powerUsage: powerUsage ?? this.powerUsage,
      weatherLocation: weatherLocation ?? this.weatherLocation,
      weatherTemp: weatherTemp ?? this.weatherTemp,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      weatherDate: weatherDate ?? this.weatherDate,
      weatherSuggestion: weatherSuggestion ?? this.weatherSuggestion,
      isWeatherLoading: isWeatherLoading ?? this.isWeatherLoading,
      isDay: isDay ?? this.isDay,
      weatherCode: weatherCode ?? this.weatherCode,
    );
  }
}

class DashboardNotifier extends Notifier<DashboardState> {
  final Dio _dio = Dio();
  Timer? _acTimer;

  @override
  DashboardState build() {
    ref.onDispose(() {
      _acTimer?.cancel();
    });

    Future.microtask(() {
      fetchLiveWeather();
      _startAcTimer();
    });

    return _getInitialMockState();
  }

  DashboardState _getInitialMockState() {
    final rooms = [
      const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
      const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
      const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
      const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
    ];

    final devices = [
      const DeviceEntity(
        id: 'door1',
        name: 'Smart Door',
        type: DeviceType.door,
        isLocked: true,
        positionX: 0.8,
        positionY: 0.55,
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
      ),
      const DeviceEntity(
        id: 'lamp1',
        name: 'Smart Lamp',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 62,
        positionX: 0.52,
        positionY: 0.18,
      ),
    ];
    
    return DashboardState(rooms: rooms, devices: devices);
  }

  void changeTab(int index) {
    state = state.copyWith(currentNavigationIndex: index);
  }

  void toggleDevice(String id) {
    final devices = List<DeviceEntity>.from(state.devices);
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      devices[index] = device.copyWith(isOn: !device.isOn);
      state = state.copyWith(devices: devices);
    }
  }
  
  void toggleDoor(String id) {
    final devices = List<DeviceEntity>.from(state.devices);
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      devices[index] = device.copyWith(isLocked: !(device.isLocked ?? false));
      state = state.copyWith(devices: devices);
    }
  }

  void selectRoom(String id) {
    final rooms = state.rooms.map((r) => r.copyWith(isActive: r.id == id)).toList();
    state = state.copyWith(rooms: rooms);
  }

  void updateDeviceBrightness(String id, int brightness) {
    final devices = List<DeviceEntity>.from(state.devices);
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      devices[index] = device.copyWith(
        brightness: brightness,
        isOn: brightness > 0,
      );
      state = state.copyWith(devices: devices);
    }
  }

  void addDevice(DeviceEntity device) {
    final devices = List<DeviceEntity>.from(state.devices);
    final deviceWithPos = device.positionX == null 
        ? device.copyWith(positionX: 0.5, positionY: 0.5)
        : device;
    devices.add(deviceWithPos);
    state = state.copyWith(devices: devices);
  }

  void updateDevice(DeviceEntity device) {
    final devices = List<DeviceEntity>.from(state.devices);
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      devices[index] = device;
      state = state.copyWith(devices: devices);
    }
  }

  void updateDevicePosition(String id, double x, double y) {
    final devices = List<DeviceEntity>.from(state.devices);
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(positionX: x, positionY: y);
      state = state.copyWith(devices: devices);
    }
  }

  void reorderDevices(int oldIndex, int newIndex) {
    final devices = List<DeviceEntity>.from(state.devices);
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final device = devices.removeAt(oldIndex);
    devices.insert(newIndex, device);
    state = state.copyWith(devices: devices);
  }

  Future<void> fetchLiveWeather() async {
    state = state.copyWith(
      isWeatherLoading: true,
      weatherDate: _getFormattedDate(),
    );

    try {
      final geoResponse = await _dio.get('https://ipapi.co/json/');
      if (geoResponse.statusCode == 200 && geoResponse.data != null) {
        final data = geoResponse.data;
        final city = data['city'] ?? 'Cairo';
        final country = data['country_name'] ?? 'Egypt';
        final double lat = (data['latitude'] as num?)?.toDouble() ?? 30.0507;
        final double lon = (data['longitude'] as num?)?.toDouble() ?? 31.2489;

        final weatherLocation = '$city, $country';

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

            state = state.copyWith(
              weatherLocation: weatherLocation,
              weatherTemp: '${temp.round()}°C',
              weatherCode: code,
              isDay: dayFlag,
              weatherCondition: _mapWeatherCode(code, dayFlag),
              weatherSuggestion: _generateSuggestion(temp, code),
              isWeatherLoading: false,
            );
            return;
          }
        }
      }
    } catch (e) {
      // Fallback
      state = state.copyWith(
        weatherLocation: 'Jakarta, Indonesia',
        weatherTemp: '27°C',
        weatherCondition: 'Clear Evening',
        isDay: 0,
        weatherCode: 0,
        weatherSuggestion: "Activate 'Relax Mode', dim lights, soft music, and lower thermostat.",
        isWeatherLoading: false,
      );
    }
  }

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

  String _mapWeatherCode(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    switch (code) {
      case 0: return isNight ? 'Clear Evening' : 'Sunny Day';
      case 1: case 2: case 3: return 'Partly Cloudy';
      case 45: case 48: return 'Foggy';
      case 51: case 53: case 55: return 'Light Drizzle';
      case 61: case 63: case 65: return 'Rainy';
      case 71: case 73: case 75: return 'Snowy';
      case 80: case 81: case 82: return 'Rain Showers';
      case 95: case 96: case 99: return 'Thunderstorm';
      default: return isNight ? 'Clear Evening' : 'Clear Day';
    }
  }

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
      bool changed = false;
      final devices = List<DeviceEntity>.from(state.devices);
      for (int i = 0; i < devices.length; i++) {
        final d = devices[i];
        if (d.type == DeviceType.airConditioner && d.isOn) {
          devices[i] = d.copyWith(coolingTime: (d.coolingTime ?? 0) + 1);
          changed = true;
        }
      }
      if (changed) {
        state = state.copyWith(devices: devices);
      }
    });
  }
}

final dashboardProvider = NotifierProvider<DashboardNotifier, DashboardState>(() {
  return DashboardNotifier();
});
