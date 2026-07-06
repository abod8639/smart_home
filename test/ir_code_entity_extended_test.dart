import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';

void main() {
  group('IrCodeEntity', () {
    // ── Basic construction ─────────────────────────────────────────────────────
    group('construction', () {
      test('creates entity with required fields', () {
        const entity = IrCodeEntity(
          protocol: IrProtocol.nec,
          value: '0xAB1234',
          bits: 32,
        );
        expect(entity.protocol, IrProtocol.nec);
        expect(entity.value, '0xAB1234');
        expect(entity.bits, 32);
      });

      test('optional fields default to null', () {
        const entity = IrCodeEntity(
          protocol: IrProtocol.samsung,
          value: '0xFF',
          bits: 32,
        );
        expect(entity.frequency, isNull);
        expect(entity.headerMark, isNull);
        expect(entity.headerSpace, isNull);
        expect(entity.oneMark, isNull);
        expect(entity.oneSpace, isNull);
        expect(entity.zeroMark, isNull);
        expect(entity.zeroSpace, isNull);
        expect(entity.isMsb, isNull);
        expect(entity.address, isNull);
        expect(entity.command, isNull);
        expect(entity.rawData, isNull);
      });

      test('creates entity with all fields', () {
        const entity = IrCodeEntity(
          protocol: IrProtocol.pulseDistance,
          value: '0x72111C810CF5AAA,0x1B0258008',
          bits: 104,
          frequency: 38,
          headerMark: 3400,
          headerSpace: 1750,
          oneMark: 450,
          oneSpace: 1300,
          zeroMark: 450,
          zeroSpace: 420,
          isMsb: false,
          address: 0x01,
          command: 0x02,
          rawData: 0xABCD,
        );
        expect(entity.frequency, 38);
        expect(entity.headerMark, 3400);
        expect(entity.headerSpace, 1750);
        expect(entity.oneMark, 450);
        expect(entity.oneSpace, 1300);
        expect(entity.zeroMark, 450);
        expect(entity.zeroSpace, 420);
        expect(entity.isMsb, false);
        expect(entity.address, 0x01);
        expect(entity.command, 0x02);
        expect(entity.rawData, 0xABCD);
      });
    });

    // ── isPulseProtocol ────────────────────────────────────────────────────────
    group('isPulseProtocol', () {
      test('returns true for pulseDistance', () {
        const entity = IrCodeEntity(protocol: IrProtocol.pulseDistance, value: 'x', bits: 1);
        expect(entity.isPulseProtocol, isTrue);
      });

      test('returns true for pulseWidth', () {
        const entity = IrCodeEntity(protocol: IrProtocol.pulseWidth, value: 'x', bits: 1);
        expect(entity.isPulseProtocol, isTrue);
      });

      test('returns false for nec', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: 'x', bits: 32);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for samsung', () {
        const entity = IrCodeEntity(protocol: IrProtocol.samsung, value: 'x', bits: 32);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for sony', () {
        const entity = IrCodeEntity(protocol: IrProtocol.sony, value: 'x', bits: 12);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for lg', () {
        const entity = IrCodeEntity(protocol: IrProtocol.lg, value: 'x', bits: 28);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for panasonic', () {
        const entity = IrCodeEntity(protocol: IrProtocol.panasonic, value: 'x', bits: 48);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for denon', () {
        const entity = IrCodeEntity(protocol: IrProtocol.denon, value: 'x', bits: 15);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for sharp', () {
        const entity = IrCodeEntity(protocol: IrProtocol.sharp, value: 'x', bits: 15);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for jvc', () {
        const entity = IrCodeEntity(protocol: IrProtocol.jvc, value: 'x', bits: 16);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for rc5', () {
        const entity = IrCodeEntity(protocol: IrProtocol.rc5, value: 'x', bits: 13);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for rc6', () {
        const entity = IrCodeEntity(protocol: IrProtocol.rc6, value: 'x', bits: 20);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for raw', () {
        const entity = IrCodeEntity(protocol: IrProtocol.raw, value: 'x', bits: 0);
        expect(entity.isPulseProtocol, isFalse);
      });

      test('returns false for unknown', () {
        const entity = IrCodeEntity(protocol: IrProtocol.unknown, value: 'x', bits: 0);
        expect(entity.isPulseProtocol, isFalse);
      });
    });

    // ── isValid ────────────────────────────────────────────────────────────────
    group('isValid', () {
      test('returns true for valid entity with non-empty value and positive bits', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: '0xAB1234', bits: 32);
        expect(entity.isValid, isTrue);
      });

      test('returns false for empty value', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: '', bits: 32);
        expect(entity.isValid, isFalse);
      });

      test('returns false for whitespace-only value', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: '   ', bits: 32);
        expect(entity.isValid, isFalse);
      });

      test('returns false for zero bits', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: '0xAB', bits: 0);
        expect(entity.isValid, isFalse);
      });

      test('returns false for negative bits', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: '0xAB', bits: -1);
        expect(entity.isValid, isFalse);
      });

      test('returns true for pulseDistance with multi-word value', () {
        const entity = IrCodeEntity(
          protocol: IrProtocol.pulseDistance,
          value: '0x72111C810CF5AAA,0x1B0258008',
          bits: 104,
        );
        expect(entity.isValid, isTrue);
      });

      test('returns false for empty value with zero bits', () {
        const entity = IrCodeEntity(protocol: IrProtocol.unknown, value: '', bits: 0);
        expect(entity.isValid, isFalse);
      });

      test('returns true for minimal valid entity (1 bit)', () {
        const entity = IrCodeEntity(protocol: IrProtocol.raw, value: 'x', bits: 1);
        expect(entity.isValid, isTrue);
      });
    });

    // ── toString ──────────────────────────────────────────────────────────────
    group('toString', () {
      test('includes protocol name', () {
        const entity = IrCodeEntity(protocol: IrProtocol.nec, value: '0xAB', bits: 32);
        expect(entity.toString(), contains('nec'));
      });

      test('includes bits count', () {
        const entity = IrCodeEntity(protocol: IrProtocol.samsung, value: '0xFF', bits: 48);
        expect(entity.toString(), contains('48'));
      });

      test('toString format is correct', () {
        const entity = IrCodeEntity(protocol: IrProtocol.lg, value: '0x01', bits: 28);
        expect(entity.toString(), 'IrCodeEntity(protocol: IrProtocol.lg, bits: 28)');
      });
    });

    // ── IrProtocol enum ───────────────────────────────────────────────────────
    group('IrProtocol enum', () {
      test('has all expected values', () {
        expect(IrProtocol.values.length, 14);
      });

      test('contains pulseDistance', () {
        expect(IrProtocol.values, contains(IrProtocol.pulseDistance));
      });

      test('contains pulseWidth', () {
        expect(IrProtocol.values, contains(IrProtocol.pulseWidth));
      });

      test('contains nec', () {
        expect(IrProtocol.values, contains(IrProtocol.nec));
      });

      test('contains samsung', () {
        expect(IrProtocol.values, contains(IrProtocol.samsung));
      });

      test('contains sony', () {
        expect(IrProtocol.values, contains(IrProtocol.sony));
      });

      test('contains lg', () {
        expect(IrProtocol.values, contains(IrProtocol.lg));
      });

      test('contains panasonic', () {
        expect(IrProtocol.values, contains(IrProtocol.panasonic));
      });

      test('contains unknown', () {
        expect(IrProtocol.values, contains(IrProtocol.unknown));
      });
    });
  });
}
