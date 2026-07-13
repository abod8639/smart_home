import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/data/models/device_model.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

void main() {
  // ── Test Fixtures ──────────────────────────────────────────────────────────
  Map<String, dynamic> baseJson({
    String type = 'lamp',
    String id = 'dev-001',
    String name = 'Test Device',
    bool isOn = false,
    bool showAsDot = false,
  }) =>
      {
        'id': id,
        'name': name,
        'type': type,
        'isOn': isOn,
        'showAsDot': showAsDot,
      };

  group('DeviceModel', () {
    // ── fromJson (all device types) ───────────────────────────────────────────
    group('fromJson', () {
      group('base fields', () {
        test('parses common fields correctly', () {
          final json = baseJson();
          json['roomId'] = 'room-1';
          json['positionX'] = 0.3;
          json['positionY'] = 0.7;
          json['markerWidth'] = 60.0;
          json['markerHeight'] = 60.0;
          json['matterNodeId'] = 5;
          json['matterEndpointId'] = 1;
          json['pin'] = 2;
          json['isPwm'] = false;

          final model = DeviceModel.fromJson(json);
          expect(model.id, 'dev-001');
          expect(model.name, 'Test Device');
          expect(model.type, 'lamp');
          expect(model.isOn, isFalse);
          expect(model.roomId, 'room-1');
          expect(model.positionX, 0.3);
          expect(model.positionY, 0.7);
          expect(model.markerWidth, 60.0);
          expect(model.markerHeight, 60.0);
          expect(model.showAsDot, isFalse);
          expect(model.matterNodeId, 5);
          expect(model.matterEndpointId, 1);
          expect(model.pin, 2);
          expect(model.isPwm, isFalse);
        });

        test('isOn defaults to false when missing', () {
          final json = <String, dynamic>{
            'id': 'd1', 'name': 'D', 'type': 'lamp', 'showAsDot': false,
          };
          final model = DeviceModel.fromJson(json);
          expect(model.isOn, isFalse);
        });

        test('showAsDot defaults to false when missing', () {
          final json = <String, dynamic>{
            'id': 'd1', 'name': 'D', 'type': 'lamp', 'isOn': false,
          };
          final model = DeviceModel.fromJson(json);
          expect(model.showAsDot, isFalse);
        });

        test('optional numeric fields as null when missing', () {
          final json = baseJson();
          final model = DeviceModel.fromJson(json);
          expect(model.positionX, isNull);
          expect(model.positionY, isNull);
          expect(model.matterNodeId, isNull);
          expect(model.pin, isNull);
        });

        test('positionX and positionY parse from num to double', () {
          final json = baseJson();
          json['positionX'] = 1; // int
          json['positionY'] = 2; // int
          final model = DeviceModel.fromJson(json);
          expect(model.positionX, 1.0);
          expect(model.positionY, 2.0);
          expect(model.positionX, isA<double>());
        });
      });

      group('lamp-specific fields', () {
        test('parses brightness for lamp type', () {
          final json = baseJson(type: 'lamp');
          json['brightness'] = 128;
          final model = DeviceModel.fromJson(json);
          expect(model.brightness, 128);
        });

        test('brightness is null when not provided', () {
          final json = baseJson(type: 'lamp');
          final model = DeviceModel.fromJson(json);
          expect(model.brightness, isNull);
        });
      });

      group('rgb-specific fields', () {
        test('parses rgb fields', () {
          final json = baseJson(type: 'rgb');
          json['brightness'] = 200;
          json['rgbR'] = 255;
          json['rgbG'] = 128;
          json['rgbB'] = 64;
          final model = DeviceModel.fromJson(json);
          expect(model.brightness, 200);
          expect(model.rgbR, 255);
          expect(model.rgbG, 128);
          expect(model.rgbB, 64);
        });

        test('rgb fields are null when not provided', () {
          final json = baseJson(type: 'rgb');
          final model = DeviceModel.fromJson(json);
          expect(model.rgbR, isNull);
          expect(model.rgbG, isNull);
          expect(model.rgbB, isNull);
        });
      });

      group('door-specific fields', () {
        test('parses door fields', () {
          final json = baseJson(type: 'door');
          json['isLocked'] = true;
          json['linkedDevicesCount'] = 2;
          final model = DeviceModel.fromJson(json);
          expect(model.isLocked, isTrue);
          expect(model.linkedDevicesCount, 2);
        });

        test('isLocked is null when not provided', () {
          final json = baseJson(type: 'door');
          final model = DeviceModel.fromJson(json);
          expect(model.isLocked, isNull);
        });
      });

      group('vacuum-specific fields', () {
        test('parses vacuum fields', () {
          final json = baseJson(type: 'vacuum');
          json['batteryLevel'] = 80;
          json['areaCleaned'] = 25;
          json['cleaningTime'] = 60;
          json['filterStatus'] = 90;
          json['nextCleaning'] = '9:00 AM';
          final model = DeviceModel.fromJson(json);
          expect(model.batteryLevel, 80);
          expect(model.areaCleaned, 25);
          expect(model.cleaningTime, 60);
          expect(model.filterStatus, 90);
          expect(model.nextCleaning, '9:00 AM');
        });

        test('vacuum fields are null when not provided', () {
          final json = baseJson(type: 'vacuum');
          final model = DeviceModel.fromJson(json);
          expect(model.batteryLevel, isNull);
          expect(model.nextCleaning, isNull);
        });
      });

      group('ac-specific fields', () {
        test('parses AC fields', () {
          final json = baseJson(type: 'airConditioner');
          json['temperature'] = 22;
          json['mode'] = 'Cool mode';
          json['coolingTime'] = 100;
          json['sleepTimerRemaining'] = 3600;
          json['irPower'] = 'power_code';
          json['irTempUp'] = 'temp_up';
          json['irTempDown'] = 'temp_down';
          json['irAuto'] = 'auto';
          json['irCool'] = 'cool';
          json['irHeat'] = 'heat';
          json['irEco'] = 'eco';
          json['irDry'] = 'dry';
          json['irFanQuiet'] = 'fan_quiet';
          json['irFanLow'] = 'fan_low';
          json['irFanMed'] = 'fan_med';
          json['irFanHigh'] = 'fan_high';
          json['irFanAuto'] = 'fan_auto';
          json['irSwingV'] = 'swing_v';
          json['irSwingH'] = 'swing_h';
          json['irPlasmacluster'] = 'plasma';
          json['irSuperJet'] = 'superjet';
          json['irCoanda'] = 'coanda';
          json['irMyArea'] = 'myarea';
          json['irDisplay'] = 'display';
          json['irClean'] = 'clean';

          final model = DeviceModel.fromJson(json);
          expect(model.temperature, 22);
          expect(model.mode, 'Cool mode');
          expect(model.coolingTime, 100);
          expect(model.sleepTimerRemaining, 3600);
          expect(model.irPower, 'power_code');
          expect(model.irTempUp, 'temp_up');
          expect(model.irTempDown, 'temp_down');
          expect(model.irCool, 'cool');
          expect(model.irHeat, 'heat');
          expect(model.irEco, 'eco');
          expect(model.irDry, 'dry');
          expect(model.irFanQuiet, 'fan_quiet');
          expect(model.irFanLow, 'fan_low');
          expect(model.irFanMed, 'fan_med');
          expect(model.irFanHigh, 'fan_high');
          expect(model.irFanAuto, 'fan_auto');
          expect(model.irSwingV, 'swing_v');
          expect(model.irSwingH, 'swing_h');
          expect(model.irPlasmacluster, 'plasma');
          expect(model.irSuperJet, 'superjet');
          expect(model.irCoanda, 'coanda');
          expect(model.irMyArea, 'myarea');
          expect(model.irDisplay, 'display');
          expect(model.irClean, 'clean');
        });

        test('AC IR fields are null when not provided', () {
          final json = baseJson(type: 'airConditioner');
          final model = DeviceModel.fromJson(json);
          expect(model.irPower, isNull);
          expect(model.irCool, isNull);
          expect(model.temperature, isNull);
        });
      });
    });

    // ── toJson ─────────────────────────────────────────────────────────────────
    group('toJson', () {
      test('includes base fields always', () {
        const model = DeviceModel(
          id: 'd1', name: 'Lamp', type: 'lamp',
          isOn: true, showAsDot: false,
        );
        final json = model.toJson();
        expect(json['id'], 'd1');
        expect(json['name'], 'Lamp');
        expect(json['type'], 'lamp');
        expect(json['isOn'], isTrue);
        expect(json['showAsDot'], isFalse);
      });

      test('excludes null brightness from output', () {
        const model = DeviceModel(
          id: 'd1', name: 'L', type: 'lamp', isOn: false, showAsDot: false,
        );
        final json = model.toJson();
        expect(json.containsKey('brightness'), isFalse);
      });

      test('includes brightness when non-null', () {
        const model = DeviceModel(
          id: 'd1', name: 'L', type: 'lamp',
          isOn: false, showAsDot: false, brightness: 200,
        );
        final json = model.toJson();
        expect(json['brightness'], 200);
      });

      test('includes IR codes when excludeIrCodes = false (default)', () {
        const model = DeviceModel(
          id: 'd1', name: 'AC', type: 'airConditioner',
          isOn: false, showAsDot: false,
          irPower: 'power_code', irCool: 'cool_code',
        );
        final json = model.toJson();
        expect(json['irPower'], 'power_code');
        expect(json['irCool'], 'cool_code');
      });

      test('excludes IR codes when excludeIrCodes = true', () {
        const model = DeviceModel(
          id: 'd1', name: 'AC', type: 'airConditioner',
          isOn: false, showAsDot: false,
          irPower: 'power_code', irCool: 'cool_code',
        );
        final json = model.toJson(excludeIrCodes: true);
        expect(json.containsKey('irPower'), isFalse);
        expect(json.containsKey('irCool'), isFalse);
      });

      test('includes RGB fields when non-null', () {
        const model = DeviceModel(
          id: 'd1', name: 'RGB', type: 'rgb',
          isOn: false, showAsDot: false,
          rgbR: 100, rgbG: 150, rgbB: 200,
        );
        final json = model.toJson();
        expect(json['rgbR'], 100);
        expect(json['rgbG'], 150);
        expect(json['rgbB'], 200);
      });

      test('includes door fields when non-null', () {
        const model = DeviceModel(
          id: 'd1', name: 'Door', type: 'door',
          isOn: false, showAsDot: false,
          isLocked: true, linkedDevicesCount: 2,
        );
        final json = model.toJson();
        expect(json['isLocked'], isTrue);
        expect(json['linkedDevicesCount'], 2);
      });

      test('includes vacuum fields when non-null', () {
        const model = DeviceModel(
          id: 'd1', name: 'Vac', type: 'vacuum',
          isOn: false, showAsDot: false,
          batteryLevel: 85, areaCleaned: 30,
          cleaningTime: 45, filterStatus: 70,
          nextCleaning: '10:00 AM',
        );
        final json = model.toJson();
        expect(json['batteryLevel'], 85);
        expect(json['areaCleaned'], 30);
        expect(json['cleaningTime'], 45);
        expect(json['filterStatus'], 70);
        expect(json['nextCleaning'], '10:00 AM');
      });

      test('includes AC temp fields when non-null', () {
        const model = DeviceModel(
          id: 'd1', name: 'AC', type: 'airConditioner',
          isOn: false, showAsDot: false,
          temperature: 22, mode: 'Cool mode',
          coolingTime: 120, sleepTimerRemaining: 3600,
        );
        final json = model.toJson();
        expect(json['temperature'], 22);
        expect(json['mode'], 'Cool mode');
        expect(json['coolingTime'], 120);
        expect(json['sleepTimerRemaining'], 3600);
      });
    });

    // ── toEntity ───────────────────────────────────────────────────────────────
    group('toEntity', () {
      test('converts lamp model to LampDeviceEntity', () {
        const model = DeviceModel(
          id: 'l1', name: 'Lamp', type: 'lamp',
          isOn: true, showAsDot: false, brightness: 128,
        );
        final entity = model.toEntity();
        expect(entity, isA<LampDeviceEntity>());
        expect(entity.type, DeviceType.lamp);
        expect(entity.isOn, isTrue);
        expect((entity as LampDeviceEntity).brightness, 128);
      });

      test('converts rgb model to RgbLampDeviceEntity', () {
        const model = DeviceModel(
          id: 'r1', name: 'RGB', type: 'rgb',
          isOn: false, showAsDot: false,
          rgbR: 255, rgbG: 0, rgbB: 128,
        );
        final entity = model.toEntity();
        expect(entity, isA<RgbLampDeviceEntity>());
        expect(entity.type, DeviceType.rgb);
        final rgb = entity as RgbLampDeviceEntity;
        expect(rgb.rgbR, 255);
        expect(rgb.rgbG, 0);
        expect(rgb.rgbB, 128);
      });

      test('converts vacuum model to VacuumDeviceEntity', () {
        const model = DeviceModel(
          id: 'v1', name: 'Vacuum', type: 'vacuum',
          isOn: true, showAsDot: false,
          batteryLevel: 90, areaCleaned: 20,
          cleaningTime: 30, filterStatus: 80,
          nextCleaning: '12:00 PM',
        );
        final entity = model.toEntity();
        expect(entity, isA<VacuumDeviceEntity>());
        final vac = entity as VacuumDeviceEntity;
        expect(vac.batteryLevel, 90);
        expect(vac.areaCleaned, 20);
        expect(vac.cleaningTime, 30);
        expect(vac.filterStatus, 80);
        expect(vac.nextCleaning, '12:00 PM');
      });

      test('converts ac model to AcDeviceEntity with IR codes', () {
        const model = DeviceModel(
          id: 'ac1', name: 'AC', type: 'airConditioner',
          isOn: true, showAsDot: false,
          temperature: 24, mode: 'Auto mode',
          coolingTime: 60,
          irPower: 'power_code', irCool: 'cool_code', irHeat: 'heat_code',
        );
        final entity = model.toEntity();
        expect(entity, isA<AcDeviceEntity>());
        final ac = entity as AcDeviceEntity;
        expect(ac.temperature, 24);
        expect(ac.mode, 'Auto mode');
        expect(ac.coolingTime, 60);
        expect(ac.acIrCodes.irPower, 'power_code');
        expect(ac.acIrCodes.irCool, 'cool_code');
        expect(ac.acIrCodes.irHeat, 'heat_code');
      });

      test('converts door model to DoorDeviceEntity', () {
        const model = DeviceModel(
          id: 'd1', name: 'Door', type: 'door',
          isOn: false, showAsDot: false,
          isLocked: true, linkedDevicesCount: 3,
        );
        final entity = model.toEntity();
        expect(entity, isA<DoorDeviceEntity>());
        final door = entity as DoorDeviceEntity;
        expect(door.isLocked, isTrue);
        expect(door.linkedDevicesCount, 3);
      });

      test('falls back to lamp for unknown type', () {
        const model = DeviceModel(
          id: 'x1', name: 'Unknown', type: 'unknownType',
          isOn: false, showAsDot: false,
        );
        final entity = model.toEntity();
        expect(entity, isA<LampDeviceEntity>());
      });

      test('entity preserves position fields', () {
        const model = DeviceModel(
          id: 'l1', name: 'L', type: 'lamp',
          isOn: false, showAsDot: true,
          positionX: 0.4, positionY: 0.6,
          markerWidth: 50.0, markerHeight: 50.0,
        );
        final entity = model.toEntity();
        expect(entity.positionX, 0.4);
        expect(entity.positionY, 0.6);
        expect(entity.markerWidth, 50.0);
        expect(entity.markerHeight, 50.0);
        expect(entity.showAsDot, isTrue);
      });
    });

    // ── fromEntity ─────────────────────────────────────────────────────────────
    group('fromEntity', () {
      test('creates from LampDeviceEntity', () {
        const entity = LampDeviceEntity(
          id: 'l1', name: 'Lamp', isOn: true, brightness: 200,
        );
        final model = DeviceModel.fromEntity(entity);
        expect(model.id, 'l1');
        expect(model.name, 'Lamp');
        expect(model.type, 'lamp');
        expect(model.isOn, isTrue);
        expect(model.brightness, 200);
        expect(model.rgbR, isNull);
      });

      test('creates from RgbLampDeviceEntity', () {
        const entity = RgbLampDeviceEntity(
          id: 'r1', name: 'RGB',
          brightness: 150, rgbR: 255, rgbG: 100, rgbB: 50,
        );
        final model = DeviceModel.fromEntity(entity);
        expect(model.type, 'rgb');
        expect(model.brightness, 150);
        expect(model.rgbR, 255);
        expect(model.rgbG, 100);
        expect(model.rgbB, 50);
      });

      test('creates from VacuumDeviceEntity', () {
        const entity = VacuumDeviceEntity(
          id: 'v1', name: 'Vac',
          batteryLevel: 70, areaCleaned: 15,
          cleaningTime: 25, filterStatus: 60,
          nextCleaning: '8:00 AM',
        );
        final model = DeviceModel.fromEntity(entity);
        expect(model.type, 'vacuum');
        expect(model.batteryLevel, 70);
        expect(model.areaCleaned, 15);
        expect(model.cleaningTime, 25);
        expect(model.filterStatus, 60);
        expect(model.nextCleaning, '8:00 AM');
      });

      test('creates from DoorDeviceEntity', () {
        const entity = DoorDeviceEntity(
          id: 'd1', name: 'Door',
          isLocked: false, linkedDevicesCount: 1,
        );
        final model = DeviceModel.fromEntity(entity);
        expect(model.type, 'door');
        expect(model.isLocked, isFalse);
        expect(model.linkedDevicesCount, 1);
      });

      test('creates from AcDeviceEntity with IR codes', () {
        const codes = AcIrCodes(
          irPower: 'pwr', irAuto: 'auto', irCool: 'cool',
        );
        const entity = AcDeviceEntity(
          id: 'ac1', name: 'AC',
          temperature: 20, mode: 'Eco mode',
          coolingTime: 80, acIrCodes: codes,
        );
        final model = DeviceModel.fromEntity(entity);
        expect(model.type, 'airConditioner');
        expect(model.temperature, 20);
        expect(model.mode, 'Eco mode');
        expect(model.coolingTime, 80);
        expect(model.irPower, 'pwr');
        expect(model.irAuto, 'auto');
        expect(model.irCool, 'cool');
        expect(model.irHeat, isNull);
      });

      test('non-AC device has no AC-specific fields', () {
        const entity = LampDeviceEntity(id: 'l1', name: 'L');
        final model = DeviceModel.fromEntity(entity);
        expect(model.temperature, isNull);
        expect(model.irPower, isNull);
        expect(model.irCool, isNull);
      });

      test('non-RGB device has no RGB fields', () {
        const entity = LampDeviceEntity(id: 'l1', name: 'L');
        final model = DeviceModel.fromEntity(entity);
        expect(model.rgbR, isNull);
        expect(model.rgbG, isNull);
        expect(model.rgbB, isNull);
      });
    });

    // ── roundtrip ─────────────────────────────────────────────────────────────
    group('roundtrip', () {
      test('lamp: Entity → Model → JSON → Model → Entity', () {
        const original = LampDeviceEntity(
          id: 'l-rt', name: 'Roundtrip Lamp',
          isOn: true, brightness: 180, roomId: 'r1',
        );
        final model = DeviceModel.fromEntity(original);
        final json = model.toJson();
        final restored = DeviceModel.fromJson(json).toEntity();

        expect(restored, isA<LampDeviceEntity>());
        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.isOn, original.isOn);
        expect((restored as LampDeviceEntity).brightness, original.brightness);
      });

      test('vacuum: Entity → Model → JSON → Model → Entity', () {
        const original = VacuumDeviceEntity(
          id: 'v-rt', name: 'Roundtrip Vac',
          batteryLevel: 65, areaCleaned: 40,
        );
        final model = DeviceModel.fromEntity(original);
        final json = model.toJson();
        final restored = DeviceModel.fromJson(json).toEntity() as VacuumDeviceEntity;
        expect(restored.batteryLevel, 65);
        expect(restored.areaCleaned, 40);
      });

      test('door: Entity → Model → JSON → Model → Entity', () {
        const original = DoorDeviceEntity(
          id: 'd-rt', name: 'Roundtrip Door',
          isLocked: true, linkedDevicesCount: 4,
        );
        final model = DeviceModel.fromEntity(original);
        final json = model.toJson();
        final restored = DeviceModel.fromJson(json).toEntity() as DoorDeviceEntity;
        expect(restored.isLocked, isTrue);
        expect(restored.linkedDevicesCount, 4);
      });
    });
  });
}
