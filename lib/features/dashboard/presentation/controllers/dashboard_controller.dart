import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

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

  void changeTab(int index) {
    currentNavigationIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
    fetchLiveWeather();
  }

  void _loadMockData() {
    rooms.value = [
      const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
      const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
      const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
      const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
    ];

    devices.value = [
      const DeviceEntity(
        id: 'door1',
        name: 'Smart Door',
        type: DeviceType.door,
        isLocked: true,
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
      ),
      const DeviceEntity(
        id: 'ac1',
        name: 'Dining Area AC',
        type: DeviceType.airConditioner,
        isOn: true,
        temperature: 21,
        mode: 'Auto mode',
        coolingTime: 35,
      ),
      const DeviceEntity(
        id: 'ac2',
        name: 'TV Area AC',
        type: DeviceType.airConditioner,
        isOn: false,
        temperature: 24,
        mode: 'Eco mode',
        coolingTime: 10,
      ),
      const DeviceEntity(
        id: 'lamp1',
        name: 'Smart Lamp',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 62,
      ),
    ];
  }

  void toggleDevice(String id) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      devices[index] = device.copyWith(isOn: !device.isOn);
    }
  }
  
  void toggleDoor(String id) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      devices[index] = device.copyWith(isLocked: !(device.isLocked ?? false));
    }
  }

  void selectRoom(String id) {
    rooms.value = rooms.map((r) => r.copyWith(isActive: r.id == id)).toList();
  }

  void updateDeviceBrightness(String id, int brightness) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      devices[index] = device.copyWith(
        brightness: brightness,
        isOn: brightness > 0,
      );
    }
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
}
