import 'package:get/get.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

class DashboardController extends GetxController {
  // Observables
  var rooms = <RoomEntity>[].obs;
  var devices = <DeviceEntity>[].obs;
  
  // Environment Stats for the selected room
  var humidity = '50%'.obs;
  var airflow = '80%'.obs;
  var temperature = '27°'.obs;
  var powerUsage = '360W'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockData();
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
        name: 'Air Conditioner 1',
        type: DeviceType.airConditioner,
        isOn: true,
        temperature: 21,
        mode: 'Auto mode',
        coolingTime: 35,
      ),
      const DeviceEntity(
        id: 'ac2',
        name: 'Air Conditioner 2',
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
}
