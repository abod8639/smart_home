import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  group('DashboardController independent AC control tests', () {
    test('Toggling one AC does not toggle other ACs', () {
      final controller = Get.put(DashboardController());

      // Ensure we have at least two ACs in the initial list
      final acDevices = controller.devices
          .where((d) => d.type == DeviceType.airConditioner)
          .toList();
      expect(acDevices.length, greaterThanOrEqualTo(2));

      final firstAcId = acDevices[0].id;
      final secondAcId = acDevices[1].id;

      // Set initial state
      final firstAcIndex = controller.devices.indexWhere((d) => d.id == firstAcId);
      final secondAcIndex = controller.devices.indexWhere((d) => d.id == secondAcId);
      
      controller.devices[firstAcIndex] = controller.devices[firstAcIndex].copyWith(isOn: false);
      controller.devices[secondAcIndex] = controller.devices[secondAcIndex].copyWith(isOn: false);

      // Act
      controller.toggleDevice(firstAcId);

      // Assert: only the first one turned ON
      expect(controller.devices[firstAcIndex].isOn, isTrue);
      expect(controller.devices[secondAcIndex].isOn, isFalse);
    });

    test('Updating temperature on one AC does not update other ACs', () {
      final controller = Get.put(DashboardController());

      final acDevices = controller.devices
          .where((d) => d.type == DeviceType.airConditioner)
          .toList();
      final firstAcId = acDevices[0].id;
      final secondAcId = acDevices[1].id;

      final firstAcIndex = controller.devices.indexWhere((d) => d.id == firstAcId);
      final secondAcIndex = controller.devices.indexWhere((d) => d.id == secondAcId);

      controller.devices[firstAcIndex] = controller.devices[firstAcIndex].copyWith(temperature: 20);
      controller.devices[secondAcIndex] = controller.devices[secondAcIndex].copyWith(temperature: 20);

      // Act
      controller.updateAcTemperature(firstAcId, 25);

      // Assert: only the first one changed temperature
      expect(controller.devices[firstAcIndex].temperature, 25);
      expect(controller.devices[secondAcIndex].temperature, 20);
    });
  });
}
