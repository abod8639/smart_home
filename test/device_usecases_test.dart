import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/repositories/device_repository.dart';
import 'package:smart_home/features/device/domain/usecases/clear_devices_usecase.dart';
import 'package:smart_home/features/device/domain/usecases/get_devices_usecase.dart';
import 'package:smart_home/features/device/domain/usecases/save_devices_usecase.dart';

class MockDeviceRepository implements DeviceRepository {
  List<DeviceEntity> storage = [];

  @override
  Future<List<DeviceEntity>> getDevices() async {
    return List.from(storage);
  }

  @override
  Future<void> saveDevices(List<DeviceEntity> devices) async {
    storage = List.from(devices);
  }

  @override
  Future<void> clearDevices() async {
    storage.clear();
  }
}

void main() {
  group('Device Use Cases Tests', () {
    late MockDeviceRepository repository;
    late GetDevicesUseCase getDevicesUseCase;
    late SaveDevicesUseCase saveDevicesUseCase;
    late ClearDevicesUseCase clearDevicesUseCase;

    setUp(() {
      repository = MockDeviceRepository();
      getDevicesUseCase = GetDevicesUseCase(repository);
      saveDevicesUseCase = SaveDevicesUseCase(repository);
      clearDevicesUseCase = ClearDevicesUseCase(repository);
    });

    test('GetDevicesUseCase returns devices from repository', () async {
      const lamp = LampDeviceEntity(id: 'd1', name: 'Desk Lamp', brightness: 120);
      repository.storage = [lamp];

      final result = await getDevicesUseCase();

      expect(result.length, 1);
      expect(result.first.id, 'd1');
      expect((result.first as LampDeviceEntity).brightness, 120);
    });

    test('SaveDevicesUseCase persists devices to repository', () async {
      const vacuum = VacuumDeviceEntity(id: 'v1', name: 'Robot Vac', batteryLevel: 85);

      await saveDevicesUseCase([vacuum]);

      expect(repository.storage.length, 1);
      expect(repository.storage.first.id, 'v1');
      expect((repository.storage.first as VacuumDeviceEntity).batteryLevel, 85);
    });

    test('ClearDevicesUseCase removes all stored devices', () async {
      const lamp = LampDeviceEntity(id: 'd1', name: 'Desk Lamp');
      repository.storage = [lamp];

      await clearDevicesUseCase();

      expect(repository.storage, isEmpty);
    });
  });
}
