import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/environment/domain/entities/environment_entity.dart';

void main() {
  group('EnvironmentEntity Tests', () {
    test('default values are set correctly', () {
      const entity = EnvironmentEntity();

      expect(entity.humidity, '50%');
      expect(entity.airflow, '80%');
      expect(entity.temperature, '27°');
      expect(entity.powerUsage, '360W');
      expect(entity.wifiRssi, '- dBm');
      expect(entity.heapFree, '0 KB');
    });

    test('copyWith modifies individual fields properly', () {
      const entity = EnvironmentEntity();

      final updated = entity.copyWith(
        humidity: '65%',
        temperature: '24°',
        wifiRssi: '-42 dBm',
      );

      expect(updated.humidity, '65%');
      expect(updated.temperature, '24°');
      expect(updated.wifiRssi, '-42 dBm');
      expect(updated.airflow, '80%');
      expect(updated.powerUsage, '360W');
      expect(updated.heapFree, '0 KB');
    });

    test('Equatable equality works for identical instances', () {
      const a = EnvironmentEntity(temperature: '22°', humidity: '45%');
      const b = EnvironmentEntity(temperature: '22°', humidity: '45%');

      expect(a, equals(b));
    });

    test('Equatable inequality works for different instances', () {
      const a = EnvironmentEntity(temperature: '22°');
      const b = EnvironmentEntity(temperature: '25°');

      expect(a, isNot(equals(b)));
    });
  });
}
