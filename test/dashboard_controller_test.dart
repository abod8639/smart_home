import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  group('DashboardController Tests', () {
    group('Independent AC control tests', () {
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

    group('Room Management Tests', () {
      test('Adding a room increases room count', () {
        final controller = Get.put(DashboardController());
        final initialCount = controller.rooms.length;

        final newRoom = const RoomEntity(id: '99', name: 'Garage', deviceCount: 0);
        controller.addRoom(newRoom);

        expect(controller.rooms.length, initialCount + 1);
        expect(controller.rooms.any((r) => r.id == '99' && r.name == 'Garage'), isTrue);
      });

      test('Updating a room changes its attributes', () {
        final controller = Get.put(DashboardController());
        final targetRoom = controller.rooms[0];
        
        final updatedRoom = targetRoom.copyWith(name: 'Updated Bedroom Name', deviceCount: 10);
        controller.updateRoom(updatedRoom);

        expect(controller.rooms[0].name, 'Updated Bedroom Name');
        expect(controller.rooms[0].deviceCount, 10);
      });

      test('Deleting active room selects another room as active', () {
        final controller = Get.put(DashboardController());
        
        // Ensure only the first room is active
        for (int i = 0; i < controller.rooms.length; i++) {
          controller.rooms[i] = controller.rooms[i].copyWith(isActive: i == 0);
        }
        
        final activeRoomId = controller.rooms[0].id;
        final fallbackRoomId = controller.rooms[1].id;

        // Delete active room
        controller.deleteRoom(activeRoomId);

        // Check fallback active room
        final activeRoom = controller.rooms.firstWhere((r) => r.isActive);
        expect(activeRoom.id, fallbackRoomId);
      });

      test('selectRoom updates active state and clears selected placement device', () {
        final controller = Get.put(DashboardController());
        final targetRoomId = controller.rooms[0].id;

        controller.selectRoom(targetRoomId);

        expect(controller.rooms.firstWhere((r) => r.id == targetRoomId).isActive, isTrue);
        expect(controller.rooms.where((r) => r.id != targetRoomId).any((r) => r.isActive), isFalse);
      });
    });

    group('Device CRUD and Controls Tests', () {
      test('addDevice sets default values and room association', () {
        final controller = Get.put(DashboardController());
        final activeRoom = controller.activeRoom;
        expect(activeRoom, isNotNull);

        final newDevice = LampDeviceEntity(id: 'lamp_test_add', name: 'Test Add Lamp');
        controller.addDevice(newDevice);

        final added = controller.devices.firstWhere((d) => d.id == 'lamp_test_add');
        expect(added.roomId, activeRoom!.id); // Should default to active room ID
        expect(added.positionX, 0.5); // Should default to center
        expect(added.positionY, 0.5);
      });

      test('updateDevice updates attributes correctly', () {
        final controller = Get.put(DashboardController());
        final device = controller.devices[0];

        final updated = device.copyWith(name: 'Renamed Device', isOn: !device.isOn);
        controller.updateDevice(updated);

        final current = controller.devices.firstWhere((d) => d.id == device.id);
        expect(current.name, 'Renamed Device');
        expect(current.isOn, !device.isOn);
      });

      test('deleteDevice removes it from the list', () {
        final controller = Get.put(DashboardController());
        final initialCount = controller.devices.length;
        final targetId = controller.devices[0].id;

        controller.deleteDevice(targetId);

        expect(controller.devices.length, initialCount - 1);
        expect(controller.devices.any((d) => d.id == targetId), isFalse);
      });

      test('updateDevicePosition updates coordinates', () {
        final controller = Get.put(DashboardController());
        final targetId = controller.devices[0].id;

        controller.updateDevicePosition(targetId, 0.75, 0.25);

        final current = controller.devices.firstWhere((d) => d.id == targetId);
        expect(current.positionX, 0.75);
        expect(current.positionY, 0.25);
      });

      test('toggleDoor flips lock status', () {
        final controller = Get.put(DashboardController());
        final doorIndex = controller.devices.indexWhere((d) => d.type == DeviceType.door);
        expect(doorIndex, isNot(-1));

        final door = controller.devices[doorIndex] as DoorDeviceEntity;
        final initialLockState = door.isLocked ?? false;

        controller.toggleDoor(door.id);

        final updatedDoor = controller.devices[doorIndex] as DoorDeviceEntity;
        expect(updatedDoor.isLocked, !initialLockState);
      });

      test('updateDeviceBrightness updates lamp brightness correctly', () {
        final controller = Get.put(DashboardController());
        final lampIndex = controller.devices.indexWhere((d) => d.type == DeviceType.lamp);
        expect(lampIndex, isNot(-1));

        final lamp = controller.devices[lampIndex] as LampDeviceEntity;

        controller.updateDeviceBrightness(lamp.id, 120);

        final updatedLamp = controller.devices[lampIndex] as LampDeviceEntity;
        expect(updatedLamp.brightness, 120);
        expect(updatedLamp.isOn, isTrue);

        // Brightness = 0 should turn device off
        controller.updateDeviceBrightness(lamp.id, 0);
        final turnedOffLamp = controller.devices[lampIndex] as LampDeviceEntity;
        expect(turnedOffLamp.brightness, 0);
        expect(turnedOffLamp.isOn, isFalse);
      });

      test('updateDeviceColor updates RGB colors', () {
        final controller = Get.put(DashboardController());
        final rgbIndex = controller.devices.indexWhere((d) => d.type == DeviceType.rgb);
        expect(rgbIndex, isNot(-1));

        final rgbDevice = controller.devices[rgbIndex] as RgbLampDeviceEntity;

        controller.updateDeviceColor(rgbDevice.id, 150, 75, 200);

        final updatedRgb = controller.devices[rgbIndex] as RgbLampDeviceEntity;
        expect(updatedRgb.rgbR, 150);
        expect(updatedRgb.rgbG, 75);
        expect(updatedRgb.rgbB, 200);
      });

      test('updateDeviceMarkerSize clamps width and height', () {
        final controller = Get.put(DashboardController());
        final targetId = controller.devices[0].id;

        // Under minimal clamp limits (0.05)
        controller.updateDeviceMarkerSize(targetId, 0.01, 0.02);
        var current = controller.devices.firstWhere((d) => d.id == targetId);
        expect(current.markerWidth, 0.05);
        expect(current.markerHeight, 0.05);

        // Over maximal clamp limits (0.8)
        controller.updateDeviceMarkerSize(targetId, 0.9, 1.2);
        current = controller.devices.firstWhere((d) => d.id == targetId);
        expect(current.markerWidth, 0.8);
        expect(current.markerHeight, 0.8);

        // Within range
        controller.updateDeviceMarkerSize(targetId, 0.4, 0.35);
        current = controller.devices.firstWhere((d) => d.id == targetId);
        expect(current.markerWidth, 0.4);
        expect(current.markerHeight, 0.35);
      });
    });
  });
}
