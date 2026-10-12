import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/environment/presentation/controllers/environment_controller.dart';

void main() {
  group('EnvironmentController Tests', () {
    test('initial state has default environment values', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(environmentControllerProvider);

      expect(state.humidity, '50%');
      expect(state.temperature, '27°');
      expect(state.airflow, '80%');
      expect(state.powerUsage, '360W');
    });

    test('updating fields updates controller state correctly', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final controller = container.read(environmentControllerProvider.notifier);

      controller.setTemperature('23°');
      expect(container.read(environmentControllerProvider).temperature, '23°');

      controller.setHumidity('45%');
      expect(container.read(environmentControllerProvider).humidity, '45%');

      controller.setAirflow('75%');
      expect(container.read(environmentControllerProvider).airflow, '75%');

      controller.setPowerUsage('420W');
      expect(container.read(environmentControllerProvider).powerUsage, '420W');

      controller.setWifiRssi('-48 dBm');
      expect(container.read(environmentControllerProvider).wifiRssi, '-48 dBm');

      controller.setHeapFree('195 KB');
      expect(container.read(environmentControllerProvider).heapFree, '195 KB');
    });
  });
}
