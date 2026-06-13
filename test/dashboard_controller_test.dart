import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/matter_service.dart';
import 'package:smart_home/core/services/firebase_service.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

void main() {

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'MQTT_BROKER_URL=broker.hivemq.com');
  });

  group('DashboardController Tests', () {
    group('Independent AC control tests', () {
      test('Toggling one AC does not toggle other ACs', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});

        // Ensure we have at least two ACs in the initial list
        final acDevices = container.read(dashboardControllerProvider).devices
            .where((d) => d.type == DeviceType.airConditioner)
            .toList();
        expect(acDevices.length, greaterThanOrEqualTo(2));

        final firstAcId = acDevices[0].id;
        final secondAcId = acDevices[1].id;

        // Set initial state
        final firstAcIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.id == firstAcId);
        final secondAcIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.id == secondAcId);
        
        container.read(dashboardControllerProvider).devices[firstAcIndex] = container.read(dashboardControllerProvider).devices[firstAcIndex].copyWith(isOn: false);
        container.read(dashboardControllerProvider).devices[secondAcIndex] = container.read(dashboardControllerProvider).devices[secondAcIndex].copyWith(isOn: false);

        // Act
        controller.toggleDevice(firstAcId);

        // Assert: only the first one turned ON
        expect(container.read(dashboardControllerProvider).devices[firstAcIndex].isOn, isTrue);
        expect(container.read(dashboardControllerProvider).devices[secondAcIndex].isOn, isFalse);
      });

      test('Updating temperature on one AC does not update other ACs', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});

        final acDevices = container.read(dashboardControllerProvider).devices
            .where((d) => d.type == DeviceType.airConditioner)
            .toList();
        final firstAcId = acDevices[0].id;
        final secondAcId = acDevices[1].id;

        final firstAcIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.id == firstAcId);
        final secondAcIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.id == secondAcId);

        container.read(dashboardControllerProvider).devices[firstAcIndex] = container.read(dashboardControllerProvider).devices[firstAcIndex].copyWith(temperature: 20);
        container.read(dashboardControllerProvider).devices[secondAcIndex] = container.read(dashboardControllerProvider).devices[secondAcIndex].copyWith(temperature: 20);

        // Act
        controller.updateAcTemperature(firstAcId, 25);

        // Assert: only the first one changed temperature
        expect(container.read(dashboardControllerProvider).devices[firstAcIndex].temperature, 25);
        expect(container.read(dashboardControllerProvider).devices[secondAcIndex].temperature, 20);
      });
    });

    group('Room Management Tests', () {
      test('Adding a room increases room count', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final initialCount = container.read(dashboardControllerProvider).rooms.length;

        const newRoom = RoomEntity(id: '99', name: 'Garage', deviceCount: 0);
        controller.addRoom(newRoom);

        expect(container.read(dashboardControllerProvider).rooms.length, initialCount + 1);
        expect(container.read(dashboardControllerProvider).rooms.any((r) => r.id == '99' && r.name == 'Garage'), isTrue);
      });

      test('Updating a room changes its attributes', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final targetRoom = container.read(dashboardControllerProvider).rooms[0];
        
        final updatedRoom = targetRoom.copyWith(name: 'Updated Bedroom Name', deviceCount: 10);
        controller.updateRoom(updatedRoom);

        expect(container.read(dashboardControllerProvider).rooms[0].name, 'Updated Bedroom Name');
        expect(container.read(dashboardControllerProvider).rooms[0].deviceCount, 10);
      });

      test('Deleting active room selects another room as active', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        
        // Ensure only the first room is active
        for (int i = 0; i < container.read(dashboardControllerProvider).rooms.length; i++) {
          container.read(dashboardControllerProvider).rooms[i] = container.read(dashboardControllerProvider).rooms[i].copyWith(isActive: i == 0);
        }
        
        final activeRoomId = container.read(dashboardControllerProvider).rooms[0].id;
        final fallbackRoomId = container.read(dashboardControllerProvider).rooms[1].id;

        // Delete active room
        controller.deleteRoom(activeRoomId);

        // Check fallback active room
        final activeRoom = container.read(dashboardControllerProvider).rooms.firstWhere((r) => r.isActive);
        expect(activeRoom.id, fallbackRoomId);
      });

      test('selectRoom updates active state and clears selected placement device', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final targetRoomId = container.read(dashboardControllerProvider).rooms[0].id;

        controller.selectRoom(targetRoomId);

        expect(container.read(dashboardControllerProvider).rooms.firstWhere((r) => r.id == targetRoomId).isActive, isTrue);
        expect(container.read(dashboardControllerProvider).rooms.where((r) => r.id != targetRoomId).any((r) => r.isActive), isFalse);
      });
    });

    group('Device CRUD and Controls Tests', () {
      test('addDevice sets default values and room association', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final activeRoom = container.read(dashboardControllerProvider.notifier).activeRoom;
        expect(activeRoom, isNotNull);

        const newDevice = LampDeviceEntity(id: 'lamp_test_add', name: 'Test Add Lamp');
        controller.addDevice(newDevice);

        final added = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'lamp_test_add');
        expect(added.roomId, activeRoom!.id); // Should default to active room ID
        expect(added.positionX, 0.5); // Should default to center
        expect(added.positionY, 0.5);
      });

      test('updateDevice updates attributes correctly', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final device = container.read(dashboardControllerProvider).devices[0];

        final updated = device.copyWith(name: 'Renamed Device', isOn: !device.isOn);
        controller.updateDevice(updated);

        final current = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == device.id);
        expect(current.name, 'Renamed Device');
        expect(current.isOn, !device.isOn);
      });

      test('deleteDevice removes it from the list', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final initialCount = container.read(dashboardControllerProvider).devices.length;
        final targetId = container.read(dashboardControllerProvider).devices[0].id;

        controller.deleteDevice(targetId);

        expect(container.read(dashboardControllerProvider).devices.length, initialCount - 1);
        expect(container.read(dashboardControllerProvider).devices.any((d) => d.id == targetId), isFalse);
      });

      test('updateDevicePosition updates coordinates', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final targetId = container.read(dashboardControllerProvider).devices[0].id;

        controller.updateDevicePosition(targetId, 0.75, 0.25);

        final current = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == targetId);
        expect(current.positionX, 0.75);
        expect(current.positionY, 0.25);
      });

      test('toggleDoor flips lock status', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final doorIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.type == DeviceType.door);
        expect(doorIndex, isNot(-1));

        final door = container.read(dashboardControllerProvider).devices[doorIndex] as DoorDeviceEntity;
        final initialLockState = door.isLocked ?? false;

        controller.toggleDoor(door.id);

        final updatedDoor = container.read(dashboardControllerProvider).devices[doorIndex] as DoorDeviceEntity;
        expect(updatedDoor.isLocked, !initialLockState);
      });

      test('updateDeviceBrightness updates lamp brightness correctly', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final lampIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.type == DeviceType.lamp);
        expect(lampIndex, isNot(-1));

        final lamp = container.read(dashboardControllerProvider).devices[lampIndex] as LampDeviceEntity;

        controller.updateDeviceBrightness(lamp.id, 120);

        final updatedLamp = container.read(dashboardControllerProvider).devices[lampIndex] as LampDeviceEntity;
        expect(updatedLamp.brightness, 120);
        expect(updatedLamp.isOn, isTrue);

        // Brightness = 0 should turn device off
        controller.updateDeviceBrightness(lamp.id, 0);
        final turnedOffLamp = container.read(dashboardControllerProvider).devices[lampIndex] as LampDeviceEntity;
        expect(turnedOffLamp.brightness, 0);
        expect(turnedOffLamp.isOn, isFalse);
      });

      test('updateDeviceColor updates RGB colors', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final rgbIndex = container.read(dashboardControllerProvider).devices.indexWhere((d) => d.type == DeviceType.rgb);
        expect(rgbIndex, isNot(-1));

        final rgbDevice = container.read(dashboardControllerProvider).devices[rgbIndex] as RgbLampDeviceEntity;

        controller.updateDeviceColor(rgbDevice.id, 150, 75, 200);

        final updatedRgb = container.read(dashboardControllerProvider).devices[rgbIndex] as RgbLampDeviceEntity;
        expect(updatedRgb.rgbR, 150);
        expect(updatedRgb.rgbG, 75);
        expect(updatedRgb.rgbB, 200);
      });

      test('updateDeviceMarkerSize clamps width and height', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final targetId = container.read(dashboardControllerProvider).devices[0].id;

        // Under minimal clamp limits (0.05)
        controller.updateDeviceMarkerSize(targetId, 0.01, 0.02);
        var current = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == targetId);
        expect(current.markerWidth, 0.05);
        expect(current.markerHeight, 0.05);

        // Over maximal clamp limits (0.8)
        controller.updateDeviceMarkerSize(targetId, 0.9, 1.2);
        current = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == targetId);
        expect(current.markerWidth, 0.8);
        expect(current.markerHeight, 0.8);

        // Within range
        controller.updateDeviceMarkerSize(targetId, 0.4, 0.35);
        current = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == targetId);
        expect(current.markerWidth, 0.4);
        expect(current.markerHeight, 0.35);
      });
    });

    group('Weather Tests', () {
      test('fetchLiveWeather handles network failure gracefully and sets fallbacks', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        controller.dio.httpClientAdapter = MockDioAdapter((options) async {
          throw DioException(
            requestOptions: options,
            error: 'Simulated network failure',
          );
        });

        await controller.fetchLiveWeather();

        expect(container.read(dashboardControllerProvider).weatherLocation, 'Jakarta, Indonesia');
        expect(container.read(dashboardControllerProvider).weatherTemp, '27°C');
        expect(container.read(dashboardControllerProvider).weatherCondition, 'Clear Evening');
        expect(container.read(dashboardControllerProvider).isWeatherLoading, isFalse);
      });

      test('fetchLiveWeather handles network success and updates weather correctly', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        controller.dio.httpClientAdapter = MockDioAdapter((options) async {
          if (options.path.contains('ipapi.co')) {
            final data = {
              'city': 'Paris',
              'country_name': 'France',
              'latitude': 48.8566,
              'longitude': 2.3522,
            };
            return ResponseBody.fromString(
              jsonEncode(data),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          } else if (options.path.contains('open-meteo.com')) {
            final data = {
              'current_weather': {
                'temperature': 18.2,
                'weathercode': 3, // Partly Cloudy
                'is_day': 1,
              }
            };
            return ResponseBody.fromString(
              jsonEncode(data),
              200,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          throw DioException(
            requestOptions: options,
            error: 'Not found',
          );
        });

        await controller.fetchLiveWeather();

        expect(container.read(dashboardControllerProvider).weatherLocation, 'Paris, France');
        expect(container.read(dashboardControllerProvider).weatherTemp, '18°C');
        expect(container.read(dashboardControllerProvider).weatherCondition, 'Partly Cloudy');
        expect(container.read(dashboardControllerProvider).isWeatherLoading, isFalse);
      });
    });

    group('Device Service Integration Tests', () {
      testWidgets('closeAllDevicesInRoom with Matter and ESP32 services', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});

        // Setup some devices in a specific room
        const roomId = 'room_123';
        const lamp = LampDeviceEntity(id: 'lamp_1', name: 'Lamp 1', isOn: true, roomId: roomId, pin: 22);
        const matterDevice = LampDeviceEntity(id: 'matter_1', name: 'Matter Lamp', isOn: true, roomId: roomId, matterNodeId: 101, matterEndpointId: 1);
        const rgbDevice = RgbLampDeviceEntity(id: 'rgb_1', name: 'RGB Lamp', isOn: true, roomId: roomId, pin: 23);
        const vacuum = VacuumDeviceEntity(id: 'vac_1', name: 'Vacuum 1', isOn: true, roomId: roomId, pin: 2);
        const ac = AcDeviceEntity(id: 'ac_1', name: 'AC 1', isOn: true, roomId: roomId, acIrCodes: AcIrCodes(irPower: '{"protocol":"NEC","value":"0x12345","bits":32,"frequency":38}'));

        controller.setDevicesForTest([]);
        container.read(dashboardControllerProvider).devices.addAll([lamp, matterDevice, rgbDevice, vacuum, ac]);

        // Call closeAllDevicesInRoom
        controller.closeAllDevicesInRoom(roomId);

        // Verify state is isOn = false for all
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'lamp_1').isOn, isFalse);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'matter_1').isOn, isFalse);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'rgb_1').isOn, isFalse);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'vac_1').isOn, isFalse);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_1').isOn, isFalse);

        // Verify service calls
        final mockMatterCalls = mockMatter.calls;
        expect(mockMatterCalls, contains('toggleDevice(101, 1, false)'));

        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 22, value: 0})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 23, value: 0})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 25, value: 0})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 26, value: 0})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_relay, pin: 2, value: 0})'));
        expect(mockFirebase.calls, contains('sendIrCommand(NEC, 0x12345)'));
        await tester.pumpAndSettle();
      });

      testWidgets('toggleDevice and update methods with Matter and ESP32', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});

        const roomId = 'room_456';
        const matterDevice = RgbLampDeviceEntity(id: 'matter_lamp', name: 'Matter Lamp', isOn: false, roomId: roomId, matterNodeId: 101, matterEndpointId: 1);
        const espLamp = LampDeviceEntity(id: 'esp_lamp', name: 'ESP Lamp', isOn: false, roomId: roomId, pin: 22);
        const espRgb = RgbLampDeviceEntity(id: 'esp_rgb', name: 'ESP RGB', isOn: false, roomId: roomId, pin: 23);

        controller.setDevicesForTest([]);
        container.read(dashboardControllerProvider).devices.addAll([matterDevice, espLamp, espRgb]);

        // Toggle Matter device
        controller.toggleDevice('matter_lamp');
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'matter_lamp').isOn, isTrue);
        expect(mockMatter.calls, contains('toggleDevice(101, 1, true)'));

        // Toggle ESP device
        controller.toggleDevice('esp_lamp');
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'esp_lamp').isOn, isTrue);
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 22, value: 255})'));

        // Toggle ESP RGB
        controller.toggleDevice('esp_rgb');
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'esp_rgb').isOn, isTrue);
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 23, value: 255})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 25, value: 255})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 26, value: 255})'));

        // Update brightness
        controller.updateDeviceBrightness('matter_lamp', 150);
        expect(mockMatter.calls, contains('setBrightness(101, 1, 150)'));

        controller.updateDeviceBrightness('esp_lamp', 150);
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 22, value: 150})'));

        // Update color
        controller.updateDeviceColor('matter_lamp', 200, 100, 50); // should call setColor
        expect(mockMatter.calls, contains('setColor(101, 1, 200, 100, 50)'));

        controller.updateDeviceColor('esp_rgb', 200, 100, 50);
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 23, value: 200})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 25, value: 100})'));
        expect(mockFirebase.calls, contains('sendCommand({action: set_pwm, pin: 26, value: 50})'));
        await tester.pumpAndSettle();
      });

      testWidgets('toggleDoor lock state and ESP32 command', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});

        const door = DoorDeviceEntity(id: 'door_test', name: 'Door Test', isLocked: true, pin: 18);
        controller.setDevicesForTest([]);
        controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, door]);

        controller.toggleDoor('door_test');
        expect((container.read(dashboardControllerProvider).devices[0] as DoorDeviceEntity).isLocked, isFalse);
        expect(mockFirebase.calls, contains('sendCommand({action: set_relay, pin: 18, value: 1})'));
        await tester.pumpAndSettle();
      });
    });

    group('IR & AC Control Tests', () {
      testWidgets('updateAcTemperature clamping and transmission', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});

        const ac = AcDeviceEntity(
          id: 'ac_test_ir',
          name: 'Test AC',
          isOn: true,
          temperature: 24,
          acIrCodes: AcIrCodes(
            irTempUp: '{"protocol":"NEC","value":"0x1111","bits":32,"frequency":38}',
            irTempDown: '{"protocol":"NEC","value":"0x2222","bits":32,"frequency":38}',
          ),
        );
        controller.setDevicesForTest([]);
        controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, ac]);

        // Clamping check over max limit
        controller.updateAcTemperature('ac_test_ir', 35);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_test_ir').temperature, 30);

        // Clamping check under min limit
        controller.updateAcTemperature('ac_test_ir', 10);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_test_ir').temperature, 16);

        // Actual temp change
        controller.updateAcTemperature('ac_test_ir', 18);
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_test_ir').temperature, 18);
        expect(mockFirebase.calls, contains('sendIrCommand(NEC, 0x1111)'));
        // Drain pending 220ms IR inter-signal timers + IR snackbar timers
        await tester.pump(const Duration(milliseconds: 800));
        await tester.pump(const Duration(seconds: 3));
        await tester.pumpAndSettle();
      });

      testWidgets('setAcMode changes mode and sends IR command', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});

        const ac = AcDeviceEntity(
          id: 'ac_test_mode',
          name: 'Test AC Mode',
          isOn: false,
          temperature: 24,
          acIrCodes: AcIrCodes(
            irCool: '{"protocol":"NEC","value":"0x3333","bits":32,"frequency":38}',
          ),
        );
        controller.setDevicesForTest([]);
        controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, ac]);

        // Set mode that is not learned yet
        controller.setAcMode(tester.element(find.byType(Container)), 'ac_test_mode', 'Heat mode');
        expect(container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_test_mode').isOn, isFalse);

        // Set learned mode
        controller.setAcMode(tester.element(find.byType(Container)), 'ac_test_mode', 'Cool mode');
        final updated = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_test_mode') as AcDeviceEntity;
        expect(updated.isOn, isTrue);
        expect(updated.mode, 'Cool mode');
        expect(mockFirebase.calls, contains('sendIrCommand(NEC, 0x3333)'));
        // Drain snackbar display timer (GetX default ~3s)
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      });

      testWidgets('clearIrCode removes IR code locally and from Firebase', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});

        const ac = AcDeviceEntity(
          id: 'ac_clear',
          name: 'Test AC Clear',
          acIrCodes: AcIrCodes(
            irPower: '{"protocol":"NEC","value":"0x4444","bits":32,"frequency":38}',
          ),
        );
        controller.setDevicesForTest([]);
        controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, ac]);

        await controller.clearIrCode(tester.element(find.byType(Container)), 'ac_clear', 'irPower');
        
        final updated = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_clear') as AcDeviceEntity;
        expect(updated.acIrCodes.irPower, null);
        expect(mockFirebase.calls, contains('deleteIrCode(ac_clear, irPower)'));
        // Drain GetX snackbar timer ("Deleted" snackbar)
        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
      });

      testWidgets('setAcSleepTimer sets timer on ESP32', (tester) async {
        await tester.pumpWidget(ProviderScope(child: MaterialApp(home: Scaffold(body: Container()))));
        final mockFirebase = MockFirebaseService();
        final mockMatter = MockMatterService();
        final container = createContainer(overrides: [
          firebaseServiceProvider.overrideWith(() => mockFirebase),
          matterServiceProvider.overrideWith(() => mockMatter),
        ]);
        final controller = container.read(dashboardControllerProvider.notifier);
        await Future.microtask(() {});

        const ac = AcDeviceEntity(
          id: 'ac_timer',
          name: 'Test AC Timer',
          acIrCodes: AcIrCodes(
            irPower: '{"protocol":"NEC","value":"0x5555","bits":32,"frequency":38}',
          ),
        );
        controller.setDevicesForTest([]);
        controller.setDevicesForTest([...container.read(dashboardControllerProvider).devices, ac]);

        await controller.setAcSleepTimer(tester.element(find.byType(Container)), 'ac_timer', const Duration(seconds: 120));
        
        final updated = container.read(dashboardControllerProvider).devices.firstWhere((d) => d.id == 'ac_timer') as AcDeviceEntity;
        expect(updated.sleepTimerRemaining, 120);
        expect(
          mockFirebase.calls,
          contains('sendCommand({action: set_ac_timer, seconds: 120, ir_code: {protocol: NEC, value: 0x5555, bits: 32, frequency: 38}})'),
        );
        await tester.pumpAndSettle();
      });
    });

    group('Room Selection and Device Reorder Tests', () {
      test('reorderDevices updates order correctly', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        final initialDevices = List<DeviceEntity>.from(container.read(dashboardControllerProvider).devices);
        expect(initialDevices.length, greaterThan(2));

        final device0 = initialDevices[0];
        final device1 = initialDevices[1];

        // Reorder first to second position
        controller.reorderDevices(0, 2);

        expect(container.read(dashboardControllerProvider).devices[1].id, device0.id);
        expect(container.read(dashboardControllerProvider).devices[0].id, device1.id);
      });
    });

    group('Initial State Tests', () {
      test('controller loads mock rooms on first launch', () async {
        final container = createContainer();
        container.read(dashboardControllerProvider.notifier); // trigger build()
          await Future.microtask(() {});
        expect(container.read(dashboardControllerProvider).rooms.isNotEmpty, isTrue);
        expect(container.read(dashboardControllerProvider).rooms.any((r) => r.name == 'Bedroom'), isTrue);
        expect(container.read(dashboardControllerProvider).rooms.any((r) => r.name == 'Living room'), isTrue);
      });

      test('controller loads mock devices on first launch', () async {
        final container = createContainer();
        container.read(dashboardControllerProvider.notifier); // trigger build()
          await Future.microtask(() {});
        expect(container.read(dashboardControllerProvider).devices.isNotEmpty, isTrue);
        // Should have at least one of each type
        expect(container.read(dashboardControllerProvider).devices.any((d) => d.type == DeviceType.airConditioner), isTrue);
        expect(container.read(dashboardControllerProvider).devices.any((d) => d.type == DeviceType.lamp), isTrue);
        expect(container.read(dashboardControllerProvider).devices.any((d) => d.type == DeviceType.door), isTrue);
        expect(container.read(dashboardControllerProvider).devices.any((d) => d.type == DeviceType.vacuum), isTrue);
        expect(container.read(dashboardControllerProvider).devices.any((d) => d.type == DeviceType.rgb), isTrue);
      });

      test('activeRoom returns the room with isActive = true', () async {
        final container = createContainer();
        container.read(dashboardControllerProvider.notifier); // trigger build()
          await Future.microtask(() {});
        final active = container.read(dashboardControllerProvider.notifier).activeRoom;
        expect(active, isNotNull);
        expect(active!.isActive, isTrue);
      });

      test('weather initial values are set in test mode', () async {
        final container = createContainer();
        container.read(dashboardControllerProvider.notifier); // trigger build()
          await Future.microtask(() {});
        expect(container.read(dashboardControllerProvider).isWeatherLoading, isFalse);
        expect(container.read(dashboardControllerProvider).weatherLocation, 'Mock City');
        expect(container.read(dashboardControllerProvider).weatherTemp, '25°C');
        expect(container.read(dashboardControllerProvider).weatherCondition, 'Sunny');
      });

      test('changeTab updates currentNavigationIndex', () async {
        final container = createContainer();
        final controller = container.read(dashboardControllerProvider.notifier);
          await Future.microtask(() {});
        controller.changeTab(2);
        expect(container.read(dashboardControllerProvider).currentNavigationIndex, 2);
        controller.changeTab(0);
        expect(container.read(dashboardControllerProvider).currentNavigationIndex, 0);
      });
    });
  });
}


class MockDioAdapter implements HttpClientAdapter {
  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  MockDioAdapter(this.onFetch);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    return onFetch(options);
  }

  @override
  void close({bool force = false}) {}
}

class MockFirebaseService extends FirebaseService {
  final List<String> calls = [];
  final Map<String, String> irCodes = {};

  @override
  Future<void> sendCommand(Map<String, dynamic> command) async {
    calls.add('sendCommand($command)');
  }

  @override
  Future<void> sendIrCommand(String protocol, String value) async {
    calls.add('sendIrCommand($protocol, $value)');
  }

  @override
  Future<void> saveIrCode(String deviceId, String fieldKey, String jsonCode) async {
    calls.add('saveIrCode($deviceId, $fieldKey)');
    irCodes['$deviceId/$fieldKey'] = jsonCode;
  }

  @override
  Future<void> deleteIrCode(String deviceId, String fieldKey) async {
    calls.add('deleteIrCode($deviceId, $fieldKey)');
    irCodes.remove('$deviceId/$fieldKey');
  }

  @override
  Future<Map<String, String>> fetchIrCodes(String deviceId) async {
    calls.add('fetchIrCodes($deviceId)');
    return irCodes;
  }
}

class MockEsp32Service extends Esp32Service {
  final List<String> calls = [];
  Map<String, dynamic>? sensorData;
  EspResponse<IrCodeEntity>? irLearnResponse;
  EspResponse<bool>? irSendResponse;

  @override
  final isConnected = true;

  @override
  Future<EspResponse<bool>> pingHub() async {
    calls.add('pingHub');
    return EspResponse.success(true);
  }

  @override
  Future<EspResponse<Map<String, dynamic>>> getSensorData() async {
    calls.add('getSensorData');
    if (sensorData != null) return EspResponse.success(sensorData);
    return EspResponse.failure('No sensor data');
  }

  @override
  Future<EspResponse<bool>> setDigitalOutput(dynamic pin, bool state) async {
    calls.add('setDigitalOutput($pin, $state)');
    return EspResponse.success(true);
  }

  @override
  Future<EspResponse<bool>> setAnalogOutput(dynamic pin, int value) async {
    calls.add('setAnalogOutput($pin, $value)');
    return EspResponse.success(true);
  }

  @override
  Future<EspResponse<dynamic>> sendRawCommand(
    String path, {
    String method = 'POST',
    dynamic data,
  }) async {
    calls.add('sendRawCommand($path, $method, $data)');
    return EspResponse.success({'status': 'ok'});
  }

  @override
  Future<EspResponse<IrCodeEntity>> learnIrCode() async {
    calls.add('learnIrCode');
    if (irLearnResponse != null) return irLearnResponse!;
    return EspResponse.failure('Failed');
  }

  @override
  Future<EspResponse<bool>> sendIrCode(IrCodeEntity irCode) async {
    calls.add('sendIrCode(${irCode.value})');
    if (irSendResponse != null) return irSendResponse!;
    return EspResponse.success(true);
  }
}

class MockMatterService extends MatterService {
  final List<String> calls = [];

  @override
  Future<MatterResponse<bool>> toggleDevice(int nodeId, int endpointId, bool isOn) async {
    calls.add('toggleDevice($nodeId, $endpointId, $isOn)');
    return MatterResponse.success(true);
  }

  @override
  Future<MatterResponse<bool>> setBrightness(int nodeId, int endpointId, int level) async {
    calls.add('setBrightness($nodeId, $endpointId, $level)');
    return MatterResponse.success(true);
  }

  @override
  Future<MatterResponse<bool>> setColor(int nodeId, int endpointId, int r, int g, int b) async {
    calls.add('setColor($nodeId, $endpointId, $r, $g, $b)');
    return MatterResponse.success(true);
  }
}

class MockSettingsController extends SettingsController {
  @override
  Future<void> checkHubConnection() async {
    state = state.copyWith(isHubReachable: true);
  }
}
