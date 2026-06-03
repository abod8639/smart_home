import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

void main() {
  group('DeviceEntity and Serialization Tests', () {
    test('DeviceEntity has showAsDot defaulting to false', () {
      final device = LampDeviceEntity(
        id: 'test_id',
        name: 'Test Lamp',
      );

      expect(device.showAsDot, isFalse);
    });

    test('DeviceEntity copyWith correctly modifies showAsDot', () {
      final device = LampDeviceEntity(
        id: 'test_id',
        name: 'Test Lamp',
      );

      final updated = device.copyWith(showAsDot: true);

      expect(updated.showAsDot, isTrue);
      expect(updated.id, 'test_id');
      expect(updated.name, 'Test Lamp');
    });
  });
}
