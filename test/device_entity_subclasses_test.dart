import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

void main() {
  // ── LampDeviceEntity ─────────────────────────────────────────────────────────
  group('LampDeviceEntity', () {
    const base = LampDeviceEntity(id: 'l1', name: 'Living Lamp', brightness: 200);

    test('type is always DeviceType.lamp', () {
      expect(base.type, DeviceType.lamp);
    });

    test('default isOn is false', () {
      expect(base.isOn, false);
    });

    test('stores brightness correctly', () {
      expect(base.brightness, 200);
    });

    group('copyWith', () {
      test('returns same values when no args', () {
        final copy = base.copyWith();
        expect(copy.id, base.id);
        expect(copy.name, base.name);
        expect(copy.brightness, base.brightness);
        expect(copy.isOn, base.isOn);
      });

      test('updates id', () {
        final copy = base.copyWith(id: 'l2');
        expect(copy.id, 'l2');
        expect(copy.name, base.name);
      });

      test('updates name', () {
        final copy = base.copyWith(name: 'New Lamp');
        expect(copy.name, 'New Lamp');
      });

      test('updates isOn', () {
        final copy = base.copyWith(isOn: true);
        expect(copy.isOn, isTrue);
      });

      test('updates brightness', () {
        final copy = base.copyWith(brightness: 128);
        expect(copy.brightness, 128);
      });

      test('updates roomId', () {
        final copy = base.copyWith(roomId: 'room1');
        expect(copy.roomId, 'room1');
      });

      test('updates positionX and positionY', () {
        final copy = base.copyWith(positionX: 0.5, positionY: 0.7);
        expect(copy.positionX, 0.5);
        expect(copy.positionY, 0.7);
      });

      test('clears pin to null', () {
        final withPin = base.copyWith(pin: 22);
        final cleared = withPin.copyWith(pin: null);
        expect(cleared.pin, isNull);
      });

      test('props includes brightness', () {
        expect(base.props, contains(200));
      });
    });
  });

  // ── RgbLampDeviceEntity ──────────────────────────────────────────────────────
  group('RgbLampDeviceEntity', () {
    const base = RgbLampDeviceEntity(
      id: 'rgb1',
      name: 'RGB Strip',
      brightness: 255,
      rgbR: 100,
      rgbG: 150,
      rgbB: 200,
    );

    test('type is always DeviceType.rgb', () {
      expect(base.type, DeviceType.rgb);
    });

    test('stores RGB values correctly', () {
      expect(base.rgbR, 100);
      expect(base.rgbG, 150);
      expect(base.rgbB, 200);
    });

    test('stores brightness correctly', () {
      expect(base.brightness, 255);
    });

    group('copyWith', () {
      test('returns same values when no args', () {
        final copy = base.copyWith();
        expect(copy.id, base.id);
        expect(copy.brightness, base.brightness);
        expect(copy.rgbR, base.rgbR);
        expect(copy.rgbG, base.rgbG);
        expect(copy.rgbB, base.rgbB);
      });

      test('updates brightness', () {
        final copy = base.copyWith(brightness: 100);
        expect(copy.brightness, 100);
        expect(copy.rgbR, base.rgbR);
      });

      test('updates rgbR', () {
        final copy = base.copyWith(rgbR: 50);
        expect(copy.rgbR, 50);
        expect(copy.rgbG, base.rgbG);
        expect(copy.rgbB, base.rgbB);
      });

      test('updates rgbG', () {
        final copy = base.copyWith(rgbG: 75);
        expect(copy.rgbG, 75);
        expect(copy.rgbR, base.rgbR);
      });

      test('updates rgbB', () {
        final copy = base.copyWith(rgbB: 25);
        expect(copy.rgbB, 25);
      });

      test('updates isOn', () {
        final copy = base.copyWith(isOn: true);
        expect(copy.isOn, isTrue);
      });

      test('props includes all rgb values', () {
        expect(base.props, contains(100)); // rgbR
        expect(base.props, contains(150)); // rgbG
        expect(base.props, contains(200)); // rgbB
      });
    });
  });

  // ── VacuumDeviceEntity ───────────────────────────────────────────────────────
  group('VacuumDeviceEntity', () {
    const base = VacuumDeviceEntity(
      id: 'v1',
      name: 'Robot Vacuum',
      batteryLevel: 85,
      areaCleaned: 30,
      cleaningTime: 45,
      filterStatus: 70,
      nextCleaning: '10:00 AM',
    );

    test('type is always DeviceType.vacuum', () {
      expect(base.type, DeviceType.vacuum);
    });

    test('stores vacuum fields correctly', () {
      expect(base.batteryLevel, 85);
      expect(base.areaCleaned, 30);
      expect(base.cleaningTime, 45);
      expect(base.filterStatus, 70);
      expect(base.nextCleaning, '10:00 AM');
    });

    group('copyWith', () {
      test('returns same values when no args', () {
        final copy = base.copyWith();
        expect(copy.batteryLevel, 85);
        expect(copy.areaCleaned, 30);
        expect(copy.cleaningTime, 45);
        expect(copy.filterStatus, 70);
        expect(copy.nextCleaning, '10:00 AM');
      });

      test('updates batteryLevel', () {
        final copy = base.copyWith(batteryLevel: 50);
        expect(copy.batteryLevel, 50);
        expect(copy.areaCleaned, base.areaCleaned);
      });

      test('updates areaCleaned', () {
        final copy = base.copyWith(areaCleaned: 60);
        expect(copy.areaCleaned, 60);
      });

      test('updates cleaningTime', () {
        final copy = base.copyWith(cleaningTime: 90);
        expect(copy.cleaningTime, 90);
      });

      test('updates filterStatus', () {
        final copy = base.copyWith(filterStatus: 30);
        expect(copy.filterStatus, 30);
      });

      test('updates nextCleaning', () {
        final copy = base.copyWith(nextCleaning: '2:00 PM');
        expect(copy.nextCleaning, '2:00 PM');
      });

      test('updates isOn', () {
        final copy = base.copyWith(isOn: true);
        expect(copy.isOn, isTrue);
      });

      test('clears matterNodeId to null', () {
        final withMatter = base.copyWith(matterNodeId: 5);
        final cleared = withMatter.copyWith(matterNodeId: null);
        expect(cleared.matterNodeId, isNull);
      });

      test('props includes all vacuum-specific fields', () {
        expect(base.props, contains(85));
        expect(base.props, contains(30));
        expect(base.props, contains(45));
        expect(base.props, contains(70));
        expect(base.props, contains('10:00 AM'));
      });
    });
  });

  // ── DoorDeviceEntity ─────────────────────────────────────────────────────────
  group('DoorDeviceEntity', () {
    const base = DoorDeviceEntity(
      id: 'd1',
      name: 'Front Door',
      isLocked: true,
      linkedDevicesCount: 3,
    );

    test('type is always DeviceType.door', () {
      expect(base.type, DeviceType.door);
    });

    test('stores door fields correctly', () {
      expect(base.isLocked, isTrue);
      expect(base.linkedDevicesCount, 3);
    });

    group('copyWith', () {
      test('returns same values when no args', () {
        final copy = base.copyWith();
        expect(copy.isLocked, true);
        expect(copy.linkedDevicesCount, 3);
      });

      test('updates isLocked to false', () {
        final copy = base.copyWith(isLocked: false);
        expect(copy.isLocked, isFalse);
        expect(copy.linkedDevicesCount, base.linkedDevicesCount);
      });

      test('updates isLocked to true', () {
        const unlocked = DoorDeviceEntity(id: 'd2', name: 'Back Door', isLocked: false);
        final copy = unlocked.copyWith(isLocked: true);
        expect(copy.isLocked, isTrue);
      });

      test('updates linkedDevicesCount', () {
        final copy = base.copyWith(linkedDevicesCount: 5);
        expect(copy.linkedDevicesCount, 5);
      });

      test('updates name', () {
        final copy = base.copyWith(name: 'Back Door');
        expect(copy.name, 'Back Door');
      });

      test('updates isOn', () {
        final copy = base.copyWith(isOn: true);
        expect(copy.isOn, isTrue);
      });

      test('props includes door-specific fields', () {
        expect(base.props, contains(true));   // isLocked
        expect(base.props, contains(3));      // linkedDevicesCount
      });
    });
  });

  // ── AcDeviceEntity ───────────────────────────────────────────────────────────
  group('AcDeviceEntity', () {
    const baseCodes = AcIrCodes(irPower: 'pwr', irCool: 'cool');
    const base = AcDeviceEntity(
      id: 'ac1',
      name: 'Living Room AC',
      temperature: 22,
      mode: 'Cool mode',
      coolingTime: 120,
      acIrCodes: baseCodes,
      sleepTimerRemaining: 3600,
    );

    test('type is always DeviceType.airConditioner', () {
      expect(base.type, DeviceType.airConditioner);
    });

    test('stores AC fields correctly', () {
      expect(base.temperature, 22);
      expect(base.mode, 'Cool mode');
      expect(base.coolingTime, 120);
      expect(base.acIrCodes, baseCodes);
      expect(base.sleepTimerRemaining, 3600);
    });

    group('copyWith', () {
      test('returns same values when no args', () {
        final copy = base.copyWith();
        expect(copy.temperature, 22);
        expect(copy.mode, 'Cool mode');
        expect(copy.coolingTime, 120);
        expect(copy.sleepTimerRemaining, 3600);
      });

      test('updates temperature', () {
        final copy = base.copyWith(temperature: 26);
        expect(copy.temperature, 26);
        expect(copy.mode, base.mode);
      });

      test('updates mode', () {
        final copy = base.copyWith(mode: 'Auto mode');
        expect(copy.mode, 'Auto mode');
      });

      test('updates coolingTime', () {
        final copy = base.copyWith(coolingTime: 240);
        expect(copy.coolingTime, 240);
      });

      test('updates sleepTimerRemaining', () {
        final copy = base.copyWith(sleepTimerRemaining: 1800);
        expect(copy.sleepTimerRemaining, 1800);
      });

      test('updates acIrCodes', () {
        const newCodes = AcIrCodes(irPower: 'new_pwr', irHeat: 'heat');
        final copy = base.copyWith(acIrCodes: newCodes);
        expect(copy.acIrCodes, newCodes);
      });

      test('updates isOn', () {
        final copy = base.copyWith(isOn: true);
        expect(copy.isOn, isTrue);
      });

      test('updates roomId', () {
        final copy = base.copyWith(roomId: 'room2');
        expect(copy.roomId, 'room2');
      });

      test('clears pin to null', () {
        final withPin = base.copyWith(pin: 4);
        final cleared = withPin.copyWith(pin: null);
        expect(cleared.pin, isNull);
      });

      test('clears isPwm to null', () {
        final withPwm = base.copyWith(isPwm: true);
        final cleared = withPwm.copyWith(isPwm: null);
        expect(cleared.isPwm, isNull);
      });

      test('props includes AC-specific fields', () {
        expect(base.props, contains(22));
        expect(base.props, contains('Cool mode'));
        expect(base.props, contains(120));
        expect(base.props, contains(3600));
        expect(base.props, contains(baseCodes));
      });
    });
  });

  // ── DeviceType enum ──────────────────────────────────────────────────────────
  group('DeviceType enum', () {
    test('has all 5 expected types', () {
      expect(DeviceType.values.length, 5);
    });

    test('contains vacuum', () {
      expect(DeviceType.values, contains(DeviceType.vacuum));
    });

    test('contains airConditioner', () {
      expect(DeviceType.values, contains(DeviceType.airConditioner));
    });

    test('contains lamp', () {
      expect(DeviceType.values, contains(DeviceType.lamp));
    });

    test('contains door', () {
      expect(DeviceType.values, contains(DeviceType.door));
    });

    test('contains rgb', () {
      expect(DeviceType.values, contains(DeviceType.rgb));
    });
  });

  // ── DeviceEntityPinHelper extension ──────────────────────────────────────────
  group('DeviceEntityPinHelper', () {
    group('isPwmConfigured', () {
      test('returns true when isPwm is explicitly true', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', isPwm: true);
        expect(lamp.isPwmConfigured, isTrue);
      });

      test('returns false when isPwm is explicitly false', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', isPwm: false);
        expect(lamp.isPwmConfigured, isFalse);
      });

      test('returns false when isPwm is null and pin is null', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L');
        expect(lamp.isPwmConfigured, isFalse);
      });

      test('returns true for PWM pin 22', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 22);
        expect(lamp.isPwmConfigured, isTrue);
      });

      test('returns true for PWM pin 23', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 23);
        expect(lamp.isPwmConfigured, isTrue);
      });

      test('returns true for PWM pin 25', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 25);
        expect(lamp.isPwmConfigured, isTrue);
      });

      test('returns true for PWM pin 26', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 26);
        expect(lamp.isPwmConfigured, isTrue);
      });

      test('returns false for relay pin 2', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 2);
        expect(lamp.isPwmConfigured, isFalse);
      });

      test('returns false for relay pin 18', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 18);
        expect(lamp.isPwmConfigured, isFalse);
      });

      test('returns false for relay pin 21', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 21);
        expect(lamp.isPwmConfigured, isFalse);
      });
    });

    group('pinLabel', () {
      test('returns null when pin is null', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L');
        expect(lamp.pinLabel, isNull);
      });

      test('returns pwm_lamp for pin 22', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 22);
        expect(lamp.pinLabel, 'pwm_lamp');
      });

      test('returns pwm_rgb_r for pin 23', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 23);
        expect(lamp.pinLabel, 'pwm_rgb_r');
      });

      test('returns pwm_rgb_g for pin 25', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 25);
        expect(lamp.pinLabel, 'pwm_rgb_g');
      });

      test('returns pwm_rgb_b for pin 26', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 26);
        expect(lamp.pinLabel, 'pwm_rgb_b');
      });

      test('returns relay_1 for pin 2', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 2);
        expect(lamp.pinLabel, 'relay_1');
      });

      test('returns relay_2 for pin 18', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 18);
        expect(lamp.pinLabel, 'relay_2');
      });

      test('returns relay_3 for pin 19', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 19);
        expect(lamp.pinLabel, 'relay_3');
      });

      test('returns relay_4 for pin 21', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 21);
        expect(lamp.pinLabel, 'relay_4');
      });

      test('returns relay_5 for pin 5 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 5, isPwm: false);
        expect(lamp.pinLabel, 'relay_5');
      });

      test('returns pwm_5 for pin 5 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 5, isPwm: true);
        expect(lamp.pinLabel, 'pwm_5');
      });

      test('returns relay_6 for pin 12 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 12, isPwm: false);
        expect(lamp.pinLabel, 'relay_6');
      });

      test('returns pwm_6 for pin 12 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 12, isPwm: true);
        expect(lamp.pinLabel, 'pwm_6');
      });

      test('returns relay_7 for pin 13 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 13, isPwm: false);
        expect(lamp.pinLabel, 'relay_7');
      });

      test('returns pwm_7 for pin 13 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 13, isPwm: true);
        expect(lamp.pinLabel, 'pwm_7');
      });

      test('returns relay_8 for pin 14 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 14, isPwm: false);
        expect(lamp.pinLabel, 'relay_8');
      });

      test('returns pwm_8 for pin 14 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 14, isPwm: true);
        expect(lamp.pinLabel, 'pwm_8');
      });

      test('returns relay_9 for pin 15 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 15, isPwm: false);
        expect(lamp.pinLabel, 'relay_9');
      });

      test('returns pwm_9 for pin 15 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 15, isPwm: true);
        expect(lamp.pinLabel, 'pwm_9');
      });

      test('returns relay_10 for pin 16 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 16, isPwm: false);
        expect(lamp.pinLabel, 'relay_10');
      });

      test('returns pwm_10 for pin 16 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 16, isPwm: true);
        expect(lamp.pinLabel, 'pwm_10');
      });

      test('returns relay_11 for pin 17 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 17, isPwm: false);
        expect(lamp.pinLabel, 'relay_11');
      });

      test('returns pwm_11 for pin 17 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 17, isPwm: true);
        expect(lamp.pinLabel, 'pwm_11');
      });

      test('returns relay_12 for pin 27 (non-pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 27, isPwm: false);
        expect(lamp.pinLabel, 'relay_12');
      });

      test('returns pwm_12 for pin 27 (pwm)', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 27, isPwm: true);
        expect(lamp.pinLabel, 'pwm_12');
      });

      test('returns null for unknown pin', () {
        const lamp = LampDeviceEntity(id: 'l', name: 'L', pin: 99);
        expect(lamp.pinLabel, isNull);
      });
    });
  });
}
