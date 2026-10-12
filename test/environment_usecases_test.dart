import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/environment/domain/entities/environment_entity.dart';
import 'package:smart_home/features/environment/domain/repositories/environment_repository.dart';
import 'package:smart_home/features/environment/domain/usecases/get_environment_usecase.dart';
import 'package:smart_home/features/environment/domain/usecases/update_environment_usecase.dart';
import 'package:smart_home/features/environment/domain/usecases/watch_environment_usecase.dart';

class MockEnvironmentRepository implements EnvironmentRepository {
  EnvironmentEntity current = const EnvironmentEntity();
  final controller = StreamController<EnvironmentEntity>.broadcast();

  @override
  EnvironmentEntity getEnvironment() => current;

  @override
  Stream<EnvironmentEntity> watchEnvironment() => controller.stream;

  @override
  void setTemperature(String temperature) {
    current = current.copyWith(temperature: temperature);
    controller.add(current);
  }

  @override
  void setHumidity(String humidity) {
    current = current.copyWith(humidity: humidity);
    controller.add(current);
  }

  @override
  void setAirflow(String airflow) {
    current = current.copyWith(airflow: airflow);
    controller.add(current);
  }

  @override
  void setPowerUsage(String powerUsage) {
    current = current.copyWith(powerUsage: powerUsage);
    controller.add(current);
  }

  @override
  void setWifiRssi(String wifiRssi) {
    current = current.copyWith(wifiRssi: wifiRssi);
    controller.add(current);
  }

  @override
  void setHeapFree(String heapFree) {
    current = current.copyWith(heapFree: heapFree);
    controller.add(current);
  }
}

void main() {
  group('Environment Use Cases Tests', () {
    late MockEnvironmentRepository repository;
    late GetEnvironmentUseCase getEnvironmentUseCase;
    late UpdateEnvironmentUseCase updateEnvironmentUseCase;
    late WatchEnvironmentUseCase watchEnvironmentUseCase;

    setUp(() {
      repository = MockEnvironmentRepository();
      getEnvironmentUseCase = GetEnvironmentUseCase(repository);
      updateEnvironmentUseCase = UpdateEnvironmentUseCase(repository);
      watchEnvironmentUseCase = WatchEnvironmentUseCase(repository);
    });

    test('GetEnvironmentUseCase returns current entity', () {
      repository.current = const EnvironmentEntity(temperature: '25°');

      final result = getEnvironmentUseCase();

      expect(result.temperature, '25°');
    });

    test('UpdateEnvironmentUseCase dispatches changes to repository', () {
      updateEnvironmentUseCase.setTemperature('19°');
      expect(repository.current.temperature, '19°');

      updateEnvironmentUseCase.setHumidity('45%');
      expect(repository.current.humidity, '45%');

      updateEnvironmentUseCase.setAirflow('90%');
      expect(repository.current.airflow, '90%');

      updateEnvironmentUseCase.setPowerUsage('250W');
      expect(repository.current.powerUsage, '250W');

      updateEnvironmentUseCase.setWifiRssi('-50 dBm');
      expect(repository.current.wifiRssi, '-50 dBm');

      updateEnvironmentUseCase.setHeapFree('150 KB');
      expect(repository.current.heapFree, '150 KB');
    });

    test('WatchEnvironmentUseCase streams environment updates', () async {
      final stream = watchEnvironmentUseCase();

      expectLater(
        stream,
        emitsInOrder([
          predicate<EnvironmentEntity>((e) => e.temperature == '30°'),
        ]),
      );

      updateEnvironmentUseCase.setTemperature('30°');
    });
  });
}
