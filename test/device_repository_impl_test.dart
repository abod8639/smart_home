import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/data/datasources/device_local_datasource.dart';
import 'package:smart_home/features/device/data/models/device_model.dart';
import 'package:smart_home/features/device/data/repositories/device_repository_impl.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class FakeDeviceLocalDatasource extends DeviceLocalDatasource {
  List<DeviceModel> memory = [];

  @override
  List<DeviceModel> loadDevices() => List.from(memory);

  @override
  Future<void> saveDevices(List<DeviceModel> devices) async {
    memory = List.from(devices);
  }

  @override
  Future<void> clearDevices() async {
    memory.clear();
  }

  @override
  bool get hasData => memory.isNotEmpty;
}

void main() {
  group('DeviceRepositoryImpl Tests', () {
    late FakeDeviceLocalDatasource datasource;
    late DeviceRepositoryImpl repository;

    setUp(() {
      datasource = FakeDeviceLocalDatasource();
      repository = DeviceRepositoryImpl(localDatasource: datasource);
    });

    test('getDevices converts models from datasource into entities', () async {
      datasource.memory = [
        const DeviceModel(
          id: 'l1',
          name: 'Living Lamp',
          type: 'lamp',
          isOn: true,
          showAsDot: false,
          brightness: 180,
        ),
      ];

      final entities = await repository.getDevices();

      expect(entities.length, 1);
      expect(entities.first, isA<LampDeviceEntity>());
      final lamp = entities.first as LampDeviceEntity;
      expect(lamp.id, 'l1');
      expect(lamp.name, 'Living Lamp');
      expect(lamp.brightness, 180);
      expect(lamp.isOn, isTrue);
    });

    test('saveDevices maps entities to models and saves to datasource', () async {
      const entity = LampDeviceEntity(
        id: 'l2',
        name: 'Bed Lamp',
        isOn: false,
        brightness: 75,
      );

      await repository.saveDevices([entity]);

      expect(datasource.memory.length, 1);
      final model = datasource.memory.first;
      expect(model.id, 'l2');
      expect(model.name, 'Bed Lamp');
      expect(model.brightness, 75);
    });

    test('clearDevices delegates to datasource clearDevices', () async {
      datasource.memory = [
        const DeviceModel(
          id: 'l1',
          name: 'Lamp',
          type: 'lamp',
          isOn: false,
          showAsDot: false,
        ),
      ];

      await repository.clearDevices();

      expect(datasource.memory, isEmpty);
    });
  });
}
