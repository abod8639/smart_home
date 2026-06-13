import 'dart:io';
import 'package:hive/hive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/core/services/hive_service.dart';
import 'package:smart_home/features/device/data/datasources/device_local_datasource.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/data/datasources/room_local_datasource.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

void main() {
  group('Local Datasource Serialization Tests', () {
    test('DeviceLocalDatasource serializes and deserializes all device types correctly', () {
      final vacuum = VacuumDeviceEntity(
        id: 'vac_1',
        name: 'Cleaner',
        isOn: true,
        roomId: '1',
        positionX: 0.1,
        positionY: 0.2,
        markerWidth: 0.3,
        markerHeight: 0.4,
        showAsDot: true,
        matterNodeId: 10,
        matterEndpointId: 1,
        pin: 2,
        batteryLevel: 90,
        areaCleaned: 120,
        cleaningTime: 45,
        filterStatus: 85,
        nextCleaning: '12:00 PM',
      );

      final ac = AcDeviceEntity(
        id: 'ac_1',
        name: 'Cooler',
        isOn: false,
        roomId: '2',
        positionX: 0.5,
        positionY: 0.6,
        markerWidth: 0.7,
        markerHeight: 0.8,
        showAsDot: false,
        matterNodeId: 20,
        matterEndpointId: 2,
        pin: 3,
        temperature: 24,
        mode: 'Cool mode',
        coolingTime: 30,
        sleepTimerRemaining: 3600,
        acIrCodes: const AcIrCodes(irPower: '{"protocol": "NEC", "value": "0x12", "bits": 32}'),
      );

      final lamp = LampDeviceEntity(
        id: 'lamp_1',
        name: 'Light',
        isOn: true,
        roomId: '3',
        positionX: 0.2,
        positionY: 0.3,
        brightness: 200,
      );

      final rgb = RgbLampDeviceEntity(
        id: 'rgb_1',
        name: 'Strip',
        isOn: true,
        roomId: '4',
        positionX: 0.4,
        positionY: 0.5,
        brightness: 180,
        rgbR: 255,
        rgbG: 100,
        rgbB: 50,
      );

      final door = DoorDeviceEntity(
        id: 'door_1',
        name: 'Entrance',
        isOn: false,
        roomId: '5',
        isLocked: true,
        linkedDevicesCount: 3,
      );

      final devices = [vacuum, ac, lamp, rgb, door];

      for (final device in devices) {
        final map = DeviceLocalDatasource.toMap(device);
        expect(map['id'], device.id);
        expect(map['name'], device.name);
        expect(map['type'], device.type.name);

        final deserialized = DeviceLocalDatasource.fromMap(map);
        expect(deserialized.id, device.id);
        expect(deserialized.name, device.name);
        expect(deserialized.type, device.type);
        expect(deserialized.isOn, device.isOn);
        expect(deserialized.roomId, device.roomId);

        if (device is VacuumDeviceEntity) {
          final d = deserialized as VacuumDeviceEntity;
          expect(d.batteryLevel, device.batteryLevel);
          expect(d.areaCleaned, device.areaCleaned);
          expect(d.cleaningTime, device.cleaningTime);
          expect(d.filterStatus, device.filterStatus);
          expect(d.nextCleaning, device.nextCleaning);
        } else if (device is AcDeviceEntity) {
          final d = deserialized as AcDeviceEntity;
          expect(d.temperature, device.temperature);
          expect(d.mode, device.mode);
          expect(d.coolingTime, device.coolingTime);
          expect(d.sleepTimerRemaining, device.sleepTimerRemaining);
          expect(d.acIrCodes.irPower, device.acIrCodes.irPower);
        } else if (device is LampDeviceEntity) {
          final d = deserialized as LampDeviceEntity;
          expect(d.brightness, device.brightness);
        } else if (device is RgbLampDeviceEntity) {
          final d = deserialized as RgbLampDeviceEntity;
          expect(d.brightness, device.brightness);
          expect(d.rgbR, device.rgbR);
          expect(d.rgbG, device.rgbG);
          expect(d.rgbB, device.rgbB);
        } else if (device is DoorDeviceEntity) {
          final d = deserialized as DoorDeviceEntity;
          expect(d.isLocked, device.isLocked);
          expect(d.linkedDevicesCount, device.linkedDevicesCount);
        }
      }
    });

    test('RoomLocalDatasource serializes and deserializes room entities correctly', () {
      final room = RoomEntity(
        id: 'room_1',
        name: 'Playroom',
        deviceCount: 5,
        isActive: true,
        iconPath: 'assets/play.png',
        imagePath: 'assets/play_bg.png',
      );

      final map = RoomLocalDatasource.toMap(room);
      expect(map['id'], 'room_1');
      expect(map['name'], 'Playroom');
      expect(map['deviceCount'], 5);
      expect(map['isActive'], isTrue);
      expect(map['iconPath'], 'assets/play.png');
      expect(map['imagePath'], 'assets/play_bg.png');

      final deserialized = RoomLocalDatasource.fromMap(map);
      expect(deserialized.id, room.id);
      expect(deserialized.name, room.name);
      expect(deserialized.deviceCount, room.deviceCount);
      expect(deserialized.isActive, room.isActive);
      expect(deserialized.iconPath, room.iconPath);
      expect(deserialized.imagePath, room.imagePath);
    });
  });

  group('Local Datasource Persistence Tests', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      await HiveService.init(testPath: tempDir.path);
    });

    tearDown(() async {
      await Hive.close();
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('DeviceLocalDatasource loads, saves, and clears devices using Hive', () async {
      final datasource = DeviceLocalDatasource();
      expect(datasource.hasData, isFalse);
      expect(datasource.loadDevices(), isEmpty);

      final lamp = LampDeviceEntity(
        id: 'lamp_1',
        name: 'Test Lamp',
        isOn: true,
        roomId: 'room_1',
        brightness: 150,
      );

      await datasource.saveDevices([lamp]);
      expect(datasource.hasData, isTrue);

      final loaded = datasource.loadDevices();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'lamp_1');
      expect(loaded.first.name, 'Test Lamp');
      expect((loaded.first as LampDeviceEntity).brightness, 150);

      await datasource.clearDevices();
      expect(datasource.hasData, isFalse);
      expect(datasource.loadDevices(), isEmpty);
    });

    test('RoomLocalDatasource loads, saves, and clears rooms using Hive', () async {
      final datasource = RoomLocalDatasource();
      expect(datasource.hasData, isFalse);
      expect(await datasource.getRooms(), isEmpty);

      final room = RoomEntity(
        id: 'room_1',
        name: 'Test Room',
        deviceCount: 3,
        isActive: true,
        iconPath: 'icon.png',
      );

      await datasource.saveRooms([room]);
      expect(datasource.hasData, isTrue);

      final loaded = datasource.loadRooms();
      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'room_1');
      expect(loaded.first.name, 'Test Room');
      expect(loaded.first.isActive, isTrue);

      await datasource.clearRooms();
      expect(datasource.hasData, isFalse);
      expect(datasource.loadRooms(), isEmpty);
    });
  });
}
