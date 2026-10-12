import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/environment/data/models/environment_model.dart';
import 'package:smart_home/features/environment/domain/entities/environment_entity.dart';

void main() {
  group('EnvironmentModel Tests', () {
    test('fromJson parses full map correctly', () {
      final json = {
        'humidity': '55%',
        'airflow': '70%',
        'temperature': '23°',
        'powerUsage': '400W',
        'wifiRssi': '-58 dBm',
        'heapFree': '120 KB',
      };

      final model = EnvironmentModel.fromJson(json);

      expect(model.humidity, '55%');
      expect(model.airflow, '70%');
      expect(model.temperature, '23°');
      expect(model.powerUsage, '400W');
      expect(model.wifiRssi, '-58 dBm');
      expect(model.heapFree, '120 KB');
    });

    test('fromJson uses defaults when fields are missing', () {
      final model = EnvironmentModel.fromJson({});

      expect(model.humidity, '50%');
      expect(model.airflow, '80%');
      expect(model.temperature, '27°');
      expect(model.powerUsage, '360W');
      expect(model.wifiRssi, '- dBm');
      expect(model.heapFree, '0 KB');
    });

    test('toJson serializes model correctly', () {
      const model = EnvironmentModel(
        humidity: '40%',
        temperature: '21°',
      );

      final json = model.toJson();

      expect(json['humidity'], '40%');
      expect(json['temperature'], '21°');
      expect(json['airflow'], '80%');
    });

    test('fromEntity and toEntity map bidirectionally', () {
      const entity = EnvironmentEntity(
        humidity: '62%',
        temperature: '26°',
        wifiRssi: '-70 dBm',
      );

      final model = EnvironmentModel.fromEntity(entity);
      expect(model.humidity, '62%');
      expect(model.temperature, '26°');

      final restoredEntity = model.toEntity();
      expect(restoredEntity, equals(entity));
    });
  });
}
