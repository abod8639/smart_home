import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/environment/domain/entities/environment_entity.dart';
import 'package:smart_home/features/environment/data/datasources/environment_local_datasource.dart';
import 'package:smart_home/features/environment/data/repositories/environment_repository_impl.dart';

void main() {
  group('EnvironmentRepositoryImpl Tests', () {
    late EnvironmentLocalDatasource datasource;
    late EnvironmentRepositoryImpl repository;

    setUp(() {
      datasource = EnvironmentLocalDatasource();
      repository = EnvironmentRepositoryImpl(datasource: datasource);
    });

    tearDown(() {
      datasource.dispose();
    });

    test('getEnvironment returns default environment initially', () {
      final env = repository.getEnvironment();

      expect(env.humidity, '50%');
      expect(env.temperature, '27°');
    });

    test('setTemperature updates datasource and getEnvironment', () {
      repository.setTemperature('21°');

      expect(repository.getEnvironment().temperature, '21°');
    });

    test('setHumidity updates datasource and getEnvironment', () {
      repository.setHumidity('40%');

      expect(repository.getEnvironment().humidity, '40%');
    });

    test('watchEnvironment emits stream of updates', () async {
      expectLater(
        repository.watchEnvironment(),
        emits(predicate<EnvironmentEntity>((env) => env.temperature == '18°')),
      );

      repository.setTemperature('18°');
    });
  });
}
