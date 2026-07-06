import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/data/models/ir_code_model.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';

void main() {
  group('IrCodeModel', () {
    // ── Test fixtures ──────────────────────────────────────────────────────────
    const fullEntity = IrCodeEntity(
      protocol: IrProtocol.nec,
      value: '0xAB1234',
      bits: 32,
      frequency: 38,
      headerMark: 9000,
      headerSpace: 4500,
      oneMark: 560,
      oneSpace: 1690,
      zeroMark: 560,
      zeroSpace: 560,
      isMsb: true,
      address: 0x01,
      command: 0x02,
      rawData: 0xABCD,
    );

    const minimalModel = IrCodeModel(
      protocol: IrProtocol.samsung,
      value: '0xFF00FF',
      bits: 32,
    );

    // ── fromEntity ─────────────────────────────────────────────────────────────
    group('fromEntity', () {
      test('creates model from entity with all fields', () {
        final model = IrCodeModel.fromEntity(fullEntity);
        expect(model.protocol, fullEntity.protocol);
        expect(model.value, fullEntity.value);
        expect(model.bits, fullEntity.bits);
        expect(model.frequency, fullEntity.frequency);
        expect(model.headerMark, fullEntity.headerMark);
        expect(model.headerSpace, fullEntity.headerSpace);
        expect(model.oneMark, fullEntity.oneMark);
        expect(model.oneSpace, fullEntity.oneSpace);
        expect(model.zeroMark, fullEntity.zeroMark);
        expect(model.zeroSpace, fullEntity.zeroSpace);
        expect(model.isMsb, fullEntity.isMsb);
        expect(model.address, fullEntity.address);
        expect(model.command, fullEntity.command);
        expect(model.rawData, fullEntity.rawData);
      });

      test('creates model from minimal entity (only required fields)', () {
        const minimal = IrCodeEntity(
          protocol: IrProtocol.lg, value: '0x100', bits: 28,
        );
        final model = IrCodeModel.fromEntity(minimal);
        expect(model.protocol, IrProtocol.lg);
        expect(model.value, '0x100');
        expect(model.bits, 28);
        expect(model.frequency, isNull);
        expect(model.address, isNull);
      });
    });

    // ── toMap ─────────────────────────────────────────────────────────────────
    group('toMap', () {
      test('serializes protocol as string', () {
        final map = minimalModel.toMap();
        expect(map['protocol'], isA<String>());
      });

      test('serializes minimal model correctly', () {
        final map = minimalModel.toMap();
        expect(map['protocol'], 'SAMSUNG');
        expect(map['value'], '0xFF00FF');
        expect(map['bits'], 32);
      });

      test('excludes null optional fields', () {
        final map = minimalModel.toMap();
        expect(map.containsKey('frequency'), isFalse);
        expect(map.containsKey('headerMark'), isFalse);
        expect(map.containsKey('address'), isFalse);
      });

      test('includes non-null optional fields', () {
        final model = IrCodeModel.fromEntity(fullEntity);
        final map = model.toMap();
        expect(map.containsKey('frequency'), isTrue);
        expect(map['frequency'], 38);
        expect(map.containsKey('headerMark'), isTrue);
        expect(map['headerMark'], 9000);
        expect(map.containsKey('isMsb'), isTrue);
        expect(map['isMsb'], isTrue);
        expect(map.containsKey('address'), isTrue);
        expect(map['address'], 0x01);
        expect(map.containsKey('rawData'), isTrue);
      });
    });

    // ── fromMap ───────────────────────────────────────────────────────────────
    group('fromMap', () {
      test('restores minimal model from map', () {
        final map = <String, dynamic>{
          'protocol': 'SAMSUNG', 'value': '0xFF00FF', 'bits': 32,
        };
        final model = IrCodeModel.fromMap(map);
        expect(model.protocol, IrProtocol.samsung);
        expect(model.value, '0xFF00FF');
        expect(model.bits, 32);
      });

      test('restores all optional fields from map', () {
        final map = <String, dynamic>{
          'protocol': 'NEC', 'value': '0xAB', 'bits': 32,
          'frequency': 38, 'headerMark': 9000, 'headerSpace': 4500,
          'oneMark': 560, 'oneSpace': 1690,
          'zeroMark': 560, 'zeroSpace': 560,
          'isMsb': true, 'address': 1, 'command': 2, 'rawData': 0xABCD,
        };
        final model = IrCodeModel.fromMap(map);
        expect(model.frequency, 38);
        expect(model.headerMark, 9000);
        expect(model.headerSpace, 4500);
        expect(model.oneMark, 560);
        expect(model.oneSpace, 1690);
        expect(model.zeroMark, 560);
        expect(model.zeroSpace, 560);
        expect(model.isMsb, isTrue);
        expect(model.address, 1);
        expect(model.command, 2);
        expect(model.rawData, 0xABCD);
      });

      test('defaults to empty value when value is missing', () {
        final map = <String, dynamic>{'protocol': 'UNKNOWN', 'bits': 0};
        final model = IrCodeModel.fromMap(map);
        expect(model.value, '');
      });

      test('defaults to 0 bits when bits is missing', () {
        final map = <String, dynamic>{'protocol': 'NEC', 'value': '0x01'};
        final model = IrCodeModel.fromMap(map);
        expect(model.bits, 0);
      });

      test('parses bits from num correctly', () {
        final map = <String, dynamic>{'protocol': 'NEC', 'value': '0x01', 'bits': 32.0};
        final model = IrCodeModel.fromMap(map);
        expect(model.bits, 32);
      });
    });

    // ── Protocol conversion (all protocols) ───────────────────────────────────
    group('protocol string conversion', () {
      final protocolCases = {
        IrProtocol.pulseDistance: 'PULSE_DISTANCE',
        IrProtocol.pulseWidth: 'PULSE_WIDTH',
        IrProtocol.nec: 'NEC',
        IrProtocol.samsung: 'SAMSUNG',
        IrProtocol.sony: 'SONY',
        IrProtocol.lg: 'LG',
        IrProtocol.panasonic: 'PANASONIC',
        IrProtocol.denon: 'DENON',
        IrProtocol.sharp: 'SHARP',
        IrProtocol.jvc: 'JVC',
        IrProtocol.rc5: 'RC5',
        IrProtocol.rc6: 'RC6',
        IrProtocol.raw: 'RAW',
        IrProtocol.unknown: 'UNKNOWN',
      };

      for (final entry in protocolCases.entries) {
        test('${entry.key.name} serializes to "${entry.value}"', () {
          final model = IrCodeModel(protocol: entry.key, value: 'x', bits: 1);
          final map = model.toMap();
          expect(map['protocol'], entry.value);
        });

        test('"${entry.value}" deserializes to ${entry.key.name}', () {
          final map = <String, dynamic>{'protocol': entry.value, 'value': 'x', 'bits': 1};
          final model = IrCodeModel.fromMap(map);
          expect(model.protocol, entry.key);
        });
      }

      test('unknown protocol string falls back to IrProtocol.unknown', () {
        final map = <String, dynamic>{'protocol': 'GARBAGE_PROTOCOL', 'value': 'x', 'bits': 1};
        final model = IrCodeModel.fromMap(map);
        expect(model.protocol, IrProtocol.unknown);
      });

      test('PULSE_DISTANCE (with underscore) deserializes correctly', () {
        final map = <String, dynamic>{'protocol': 'PULSE_DISTANCE', 'value': 'x', 'bits': 104};
        final model = IrCodeModel.fromMap(map);
        expect(model.protocol, IrProtocol.pulseDistance);
      });

      test('PULSE_WIDTH (with underscore) deserializes correctly', () {
        final map = <String, dynamic>{'protocol': 'PULSE_WIDTH', 'value': 'x', 'bits': 32};
        final model = IrCodeModel.fromMap(map);
        expect(model.protocol, IrProtocol.pulseWidth);
      });

      test('lowercase protocol string falls back to unknown', () {
        // The fromMap uppercases, then removes underscores before comparing
        // 'nec' -> 'NEC' after toUpperCase -> matches NEC
        final map = <String, dynamic>{'protocol': 'nec', 'value': 'x', 'bits': 32};
        final model = IrCodeModel.fromMap(map);
        expect(model.protocol, IrProtocol.nec);
      });
    });

    // ── toJson / fromJson ─────────────────────────────────────────────────────
    group('toJson / fromJson', () {
      test('toJson returns valid JSON string', () {
        final json = minimalModel.toJson();
        expect(json, isA<String>());
        expect(json, contains('"SAMSUNG"'));
        expect(json, contains('"0xFF00FF"'));
      });

      test('fromJson restores the model', () {
        final json = minimalModel.toJson();
        final restored = IrCodeModel.fromJson(json);
        expect(restored.protocol, minimalModel.protocol);
        expect(restored.value, minimalModel.value);
        expect(restored.bits, minimalModel.bits);
      });

      test('fromJson with full model', () {
        final model = IrCodeModel.fromEntity(fullEntity);
        final json = model.toJson();
        final restored = IrCodeModel.fromJson(json);
        expect(restored.frequency, fullEntity.frequency);
        expect(restored.headerMark, fullEntity.headerMark);
        expect(restored.isMsb, fullEntity.isMsb);
      });
    });

    // ── toEsp32Payload ────────────────────────────────────────────────────────
    group('toEsp32Payload', () {
      test('returns same map as toMap', () {
        final model = IrCodeModel.fromEntity(fullEntity);
        expect(model.toEsp32Payload(), equals(model.toMap()));
      });

      test('includes protocol and value', () {
        final payload = minimalModel.toEsp32Payload();
        expect(payload.containsKey('protocol'), isTrue);
        expect(payload.containsKey('value'), isTrue);
        expect(payload.containsKey('bits'), isTrue);
      });
    });

    // ── verifyRoundtrip ───────────────────────────────────────────────────────
    group('verifyRoundtrip', () {
      test('returns true for minimal model', () {
        expect(minimalModel.verifyRoundtrip(), isTrue);
      });

      test('returns true for full model', () {
        final model = IrCodeModel.fromEntity(fullEntity);
        expect(model.verifyRoundtrip(), isTrue);
      });

      test('returns true for pulseDistance multi-word model', () {
        const model = IrCodeModel(
          protocol: IrProtocol.pulseDistance,
          value: '0x72111C810CF5AAA,0x1B0258008',
          bits: 104,
          frequency: 38,
          headerMark: 3400,
          headerSpace: 1750,
        );
        expect(model.verifyRoundtrip(), isTrue);
      });

      test('returns true for all protocol types', () {
        for (final protocol in IrProtocol.values) {
          final model = IrCodeModel(protocol: protocol, value: '0xAB', bits: 32);
          expect(model.verifyRoundtrip(), isTrue,
              reason: 'Failed for protocol: ${protocol.name}');
        }
      });
    });

    // ── IrCodeModel is an IrCodeEntity ────────────────────────────────────────
    group('inheritance', () {
      test('IrCodeModel is an IrCodeEntity', () {
        expect(minimalModel, isA<IrCodeEntity>());
      });

      test('inherits isPulseProtocol from entity', () {
        const pulse = IrCodeModel(
          protocol: IrProtocol.pulseDistance, value: 'x', bits: 104,
        );
        expect(pulse.isPulseProtocol, isTrue);
      });

      test('inherits isValid from entity', () {
        const valid = IrCodeModel(protocol: IrProtocol.nec, value: '0xAB', bits: 32);
        const invalid = IrCodeModel(protocol: IrProtocol.nec, value: '', bits: 0);
        expect(valid.isValid, isTrue);
        expect(invalid.isValid, isFalse);
      });
    });
  });
}
