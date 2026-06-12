import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';

void main() {
  group('IrCodeEntity Unit Tests', () {
    test('isValid returns true for valid codes and false for invalid ones', () {
      const valid = IrCodeEntity(
        protocol: IrProtocol.nec,
        value: '0x12345678',
        bits: 32,
      );
      expect(valid.isValid, isTrue);
      expect(valid.isPulseProtocol, isFalse);

      const invalidEmptyValue = IrCodeEntity(
        protocol: IrProtocol.nec,
        value: '',
        bits: 32,
      );
      expect(invalidEmptyValue.isValid, isFalse);

      const invalidBits = IrCodeEntity(
        protocol: IrProtocol.nec,
        value: '0x12345678',
        bits: 0,
      );
      expect(invalidBits.isValid, isFalse);
    });

    test('isPulseProtocol returns true for pulse distance and pulse width protocols', () {
      const pulseDistance = IrCodeEntity(
        protocol: IrProtocol.pulseDistance,
        value: '0x1234',
        bits: 50,
      );
      expect(pulseDistance.isPulseProtocol, isTrue);

      const pulseWidth = IrCodeEntity(
        protocol: IrProtocol.pulseWidth,
        value: '0x1234',
        bits: 50,
      );
      expect(pulseWidth.isPulseProtocol, isTrue);
    });

    test('Serialization and Deserialization works correctly', () {
      final code = IrCodeEntity(
        protocol: IrProtocol.samsung,
        value: '0xABCDEF12',
        bits: 32,
        frequency: 38,
        headerMark: 4500,
        headerSpace: 4500,
        oneMark: 560,
        oneSpace: 1690,
        zeroMark: 560,
        zeroSpace: 560,
        isMsb: true,
        address: 7,
        command: 15,
        rawData: 123456,
      );

      final map = code.toMap();
      expect(map['protocol'], 'SAMSUNG');
      expect(map['value'], '0xABCDEF12');
      expect(map['bits'], 32);
      expect(map['frequency'], 38);
      expect(map['headerMark'], 4500);
      expect(map['headerSpace'], 4500);
      expect(map['oneMark'], 560);
      expect(map['oneSpace'], 1690);
      expect(map['zeroMark'], 560);
      expect(map['zeroSpace'], 560);
      expect(map['isMsb'], isTrue);
      expect(map['address'], 7);
      expect(map['command'], 15);
      expect(map['rawData'], 123456);

      final decoded = IrCodeEntity.fromMap(map);
      expect(decoded.protocol, IrProtocol.samsung);
      expect(decoded.value, '0xABCDEF12');
      expect(decoded.bits, 32);
      expect(decoded.frequency, 38);
      expect(decoded.headerMark, 4500);
      expect(decoded.isMsb, isTrue);
      expect(decoded.address, 7);

      final jsonStr = code.toJson();
      final decodedFromJson = IrCodeEntity.fromJson(jsonStr);
      expect(decodedFromJson.protocol, IrProtocol.samsung);
      expect(decodedFromJson.value, '0xABCDEF12');
    });

    test('verifyRoundtrip returns true when properties are identical', () {
      final code = IrCodeEntity(
        protocol: IrProtocol.lg,
        value: '0x880011',
        bits: 28,
        address: 12,
        command: 22,
      );
      expect(code.verifyRoundtrip(), isTrue);
    });

    test('toString returns formatted debug string', () {
      const code = IrCodeEntity(
        protocol: IrProtocol.sony,
        value: '0x12',
        bits: 12,
      );
      expect(code.toString(), 'IrCodeEntity(protocol: IrProtocol.sony, bits: 12)');
    });

    test('Protocol parsing from string behaves correctly across variations', () {
      final protocols = [
        'PULSE_DISTANCE',
        'PULSE_WIDTH',
        'NEC',
        'SAMSUNG',
        'SONY',
        'LG',
        'PANASONIC',
        'DENON',
        'SHARP',
        'JVC',
        'RC5',
        'RC6',
        'RAW',
        'UNKNOWN_OR_OTHER'
      ];

      final expected = [
        IrProtocol.pulseDistance,
        IrProtocol.pulseWidth,
        IrProtocol.nec,
        IrProtocol.samsung,
        IrProtocol.sony,
        IrProtocol.lg,
        IrProtocol.panasonic,
        IrProtocol.denon,
        IrProtocol.sharp,
        IrProtocol.jvc,
        IrProtocol.rc5,
        IrProtocol.rc6,
        IrProtocol.raw,
        IrProtocol.unknown
      ];

      for (var i = 0; i < protocols.length; i++) {
        final map = {'protocol': protocols[i], 'value': '0x1', 'bits': 8};
        final entity = IrCodeEntity.fromMap(map);
        expect(entity.protocol, expected[i]);
      }
    });
  });
}
