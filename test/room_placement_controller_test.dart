import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  group('RoomPlacementController Unit Tests', () {
    test('Initial value of selectedDeviceId is null', () {
      final controller = Get.put(RoomPlacementController());
      expect(controller.selectedDeviceId.value, isNull);
    });

    test('selectDevice sets selectedDeviceId correctly', () {
      final controller = Get.put(RoomPlacementController());
      
      controller.selectDevice('device_lamp_1');
      expect(controller.selectedDeviceId.value, 'device_lamp_1');

      controller.selectDevice('device_ac_2');
      expect(controller.selectedDeviceId.value, 'device_ac_2');

      controller.selectDevice(null);
      expect(controller.selectedDeviceId.value, isNull);
    });
  });
}
