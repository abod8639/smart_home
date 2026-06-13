import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

void main() {
  group('DeviceEntity Tests', () {
    group('LampDeviceEntity', () {
      test('showAsDot defaults to false', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp');
        expect(device.showAsDot, isFalse);
      });

      test('copyWith modifies showAsDot', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp');
        final updated = device.copyWith(showAsDot: true);
        expect(updated.showAsDot, isTrue);
        expect(updated.id, 'l1');
        expect(updated.name, 'Lamp');
      });

      test('copyWith modifies brightness', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp', brightness: 100);
        final updated = device.copyWith(brightness: 200);
        expect(updated.brightness, 200);
        expect(updated.id, 'l1');
      });

      test('copyWith modifies isOn', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp', isOn: false);
        final updated = device.copyWith(isOn: true);
        expect(updated.isOn, isTrue);
      });

      test('Equatable: two identical lamps are equal', () {
        const a = LampDeviceEntity(id: 'l1', name: 'Lamp', brightness: 80);
        const b = LampDeviceEntity(id: 'l1', name: 'Lamp', brightness: 80);
        expect(a, equals(b));
      });

      test('Equatable: two different lamps are not equal', () {
        const a = LampDeviceEntity(id: 'l1', name: 'Lamp A', brightness: 80);
        const b = LampDeviceEntity(id: 'l2', name: 'Lamp B', brightness: 80);
        expect(a, isNot(equals(b)));
      });

      test('type is DeviceType.lamp', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp');
        expect(device.type, DeviceType.lamp);
      });

      test('matterNodeId defaults to null', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp');
        expect(device.matterNodeId, isNull);
        expect(device.matterEndpointId, isNull);
      });

      test('copyWith clears matterNodeId with null sentinel', () {
        const device = LampDeviceEntity(id: 'l1', name: 'Lamp', matterNodeId: 10);
        final updated = device.copyWith(matterNodeId: null);
        expect(updated.matterNodeId, isNull);
      });
    });

    group('RgbLampDeviceEntity', () {
      test('type is DeviceType.rgb', () {
        const device = RgbLampDeviceEntity(id: 'r1', name: 'RGB');
        expect(device.type, DeviceType.rgb);
      });

      test('copyWith updates RGB channels independently', () {
        const device = RgbLampDeviceEntity(
            id: 'r1', name: 'RGB', rgbR: 100, rgbG: 150, rgbB: 200);
        final updated = device.copyWith(rgbR: 255);
        expect(updated.rgbR, 255);
        expect(updated.rgbG, 150);
        expect(updated.rgbB, 200);
      });

      test('Equatable works for RGB', () {
        const a = RgbLampDeviceEntity(
            id: 'r1', name: 'RGB', rgbR: 100, rgbG: 150, rgbB: 200);
        const b = RgbLampDeviceEntity(
            id: 'r1', name: 'RGB', rgbR: 100, rgbG: 150, rgbB: 200);
        expect(a, equals(b));
      });
    });

    group('DoorDeviceEntity', () {
      test('type is DeviceType.door', () {
        const device = DoorDeviceEntity(id: 'd1', name: 'Door');
        expect(device.type, DeviceType.door);
      });

      test('isLocked defaults to null', () {
        const device = DoorDeviceEntity(id: 'd1', name: 'Door');
        expect(device.isLocked, isNull);
      });

      test('copyWith updates isLocked', () {
        const device = DoorDeviceEntity(id: 'd1', name: 'Door', isLocked: true);
        final updated = device.copyWith(isLocked: false);
        expect(updated.isLocked, isFalse);
      });

      test('copyWith updates linkedDevicesCount', () {
        const device = DoorDeviceEntity(id: 'd1', name: 'Door', linkedDevicesCount: 2);
        final updated = device.copyWith(linkedDevicesCount: 5);
        expect(updated.linkedDevicesCount, 5);
      });
    });

    group('VacuumDeviceEntity', () {
      test('type is DeviceType.vacuum', () {
        const device = VacuumDeviceEntity(id: 'v1', name: 'Vacuum');
        expect(device.type, DeviceType.vacuum);
      });

      test('copyWith preserves unmodified vacuum fields', () {
        const device = VacuumDeviceEntity(
          id: 'v1',
          name: 'Vacuum',
          batteryLevel: 75,
          areaCleaned: 80,
          cleaningTime: 30,
          filterStatus: 90,
          nextCleaning: '10:00 AM',
        );
        final updated = device.copyWith(batteryLevel: 50);
        expect(updated.batteryLevel, 50);
        expect(updated.areaCleaned, 80);
        expect(updated.cleaningTime, 30);
        expect(updated.filterStatus, 90);
        expect(updated.nextCleaning, '10:00 AM');
      });
    });

    group('AcDeviceEntity', () {
      test('type is DeviceType.airConditioner', () {
        const device = AcDeviceEntity(
            id: 'ac1', name: 'AC', acIrCodes: AcIrCodes());
        expect(device.type, DeviceType.airConditioner);
      });

      test('copyWith updates temperature and mode independently', () {
        const device = AcDeviceEntity(
          id: 'ac1',
          name: 'AC',
          temperature: 22,
          mode: 'Cool mode',
          acIrCodes: AcIrCodes(),
        );
        final updated = device.copyWith(temperature: 25);
        expect(updated.temperature, 25);
        expect(updated.mode, 'Cool mode');
      });

      test('copyWith updates acIrCodes', () {
        const device = AcDeviceEntity(
          id: 'ac1',
          name: 'AC',
          acIrCodes: AcIrCodes(irPower: 'power_code'),
        );
        final updated = device.copyWith(
            acIrCodes: const AcIrCodes(irPower: 'new_power_code'));
        expect(updated.acIrCodes.irPower, 'new_power_code');
      });

      test('Equatable works for AC', () {
        const a = AcDeviceEntity(
            id: 'ac1', name: 'AC', temperature: 22, acIrCodes: AcIrCodes());
        const b = AcDeviceEntity(
            id: 'ac1', name: 'AC', temperature: 22, acIrCodes: AcIrCodes());
        expect(a, equals(b));
      });
    });
  });

  group('AcIrCodes Tests', () {
    test('AcIrCodes defaults all fields to null', () {
      const codes = AcIrCodes();
      expect(codes.irPower, isNull);
      expect(codes.irTempUp, isNull);
      expect(codes.irTempDown, isNull);
      expect(codes.irAuto, isNull);
      expect(codes.irCool, isNull);
      expect(codes.irHeat, isNull);
      expect(codes.irEco, isNull);
      expect(codes.irDry, isNull);
      expect(codes.irFanQuiet, isNull);
      expect(codes.irFanLow, isNull);
      expect(codes.irFanMed, isNull);
      expect(codes.irFanHigh, isNull);
      expect(codes.irFanAuto, isNull);
      expect(codes.irSwingV, isNull);
      expect(codes.irSwingH, isNull);
    });

    test('AcIrCodes copyWith updates single field without affecting others', () {
      const original = AcIrCodes(irPower: 'power', irCool: 'cool');
      final updated = original.copyWith(irPower: 'new_power');
      expect(updated.irPower, 'new_power');
      expect(updated.irCool, 'cool');
      expect(updated.irHeat, isNull);
    });

    test('AcIrCodes copyWith clears a field with null sentinel', () {
      const original = AcIrCodes(irPower: 'power_code');
      final cleared = original.copyWith(irPower: null);
      expect(cleared.irPower, isNull);
    });

    test('AcIrCodes Equatable: identical codes are equal', () {
      const a = AcIrCodes(irPower: 'p', irCool: 'c');
      const b = AcIrCodes(irPower: 'p', irCool: 'c');
      expect(a, equals(b));
    });

    test('AcIrCodes Equatable: different codes are not equal', () {
      const a = AcIrCodes(irPower: 'p1');
      const b = AcIrCodes(irPower: 'p2');
      expect(a, isNot(equals(b)));
    });
  });
}
