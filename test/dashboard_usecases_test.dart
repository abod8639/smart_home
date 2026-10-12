import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:smart_home/features/dashboard/domain/usecases/send_hardware_command_usecase.dart';
import 'package:smart_home/features/dashboard/domain/usecases/sync_dashboard_devices_usecase.dart';
import 'package:smart_home/features/dashboard/domain/usecases/sync_dashboard_rooms_usecase.dart';
import 'package:smart_home/features/dashboard/domain/usecases/sync_ir_codes_usecase.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

class FakeDashboardRepository implements DashboardRepository {
  List<RoomEntity> rooms = [
    const RoomEntity(id: '1', name: 'Living Room', deviceCount: 3),
  ];
  List<DeviceEntity> devices = [
    const LampDeviceEntity(id: 'd1', name: 'Ceiling Lamp'),
  ];
  Map<String, dynamic> irCodes = {'power': 'code_123'};

  final StreamController<List<RoomEntity>> roomsController =
      StreamController<List<RoomEntity>>.broadcast();
  final StreamController<List<DeviceEntity>> devicesController =
      StreamController<List<DeviceEntity>>.broadcast();

  String? lastEsp32Path;
  String? lastEsp32Method;
  Map<String, dynamic>? lastEsp32Data;

  int? lastMatterNodeId;
  int? lastMatterEndpointId;
  bool? lastMatterIsOn;

  @override
  Future<List<RoomEntity>?> fetchRemoteRooms() async => rooms;

  @override
  Future<List<DeviceEntity>?> fetchRemoteDevices() async => devices;

  @override
  Stream<List<RoomEntity>> watchRemoteRooms() => roomsController.stream;

  @override
  Stream<List<DeviceEntity>> watchRemoteDevices() => devicesController.stream;

  @override
  Future<Map<String, dynamic>> fetchRemoteIrCodes(String deviceId) async => irCodes;

  @override
  Future<void> sendEsp32Command(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? data,
  }) async {
    lastEsp32Path = path;
    lastEsp32Method = method;
    lastEsp32Data = data;
  }

  @override
  Future<void> toggleMatterDevice(int nodeId, int endpointId, bool isOn) async {
    lastMatterNodeId = nodeId;
    lastMatterEndpointId = endpointId;
    lastMatterIsOn = isOn;
  }

  void dispose() {
    roomsController.close();
    devicesController.close();
  }
}

void main() {
  late FakeDashboardRepository repository;

  setUp(() {
    repository = FakeDashboardRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  group('Dashboard Use Cases Tests', () {
    test('SyncDashboardRoomsUseCase fetches and observes rooms', () async {
      final usecase = SyncDashboardRoomsUseCase(repository);
      final fetched = await usecase.fetchRooms();
      expect(fetched?.length, 1);
      expect(fetched?.first.name, 'Living Room');

      expectLater(
        usecase.watchRooms(),
        emits([
          const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 1),
        ]),
      );
      repository.roomsController.add([
        const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 1),
      ]);
    });

    test('SyncDashboardDevicesUseCase fetches and observes devices', () async {
      final usecase = SyncDashboardDevicesUseCase(repository);
      final fetched = await usecase.fetchDevices();
      expect(fetched?.length, 1);
      expect(fetched?.first.name, 'Ceiling Lamp');

      expectLater(
        usecase.watchDevices(),
        emits([
          const DoorDeviceEntity(id: 'd2', name: 'Main Door'),
        ]),
      );
      repository.devicesController.add([
        const DoorDeviceEntity(id: 'd2', name: 'Main Door'),
      ]);
    });

    test('SyncIrCodesUseCase fetches codes for device', () async {
      final usecase = SyncIrCodesUseCase(repository);
      final codes = await usecase('ac_1');
      expect(codes['power'], 'code_123');
    });

    test('SendHardwareCommandUseCase dispatches ESP32 and Matter commands', () async {
      final usecase = SendHardwareCommandUseCase(repository);

      await usecase.sendEsp32Command('control/ac', data: {'temp': 22});
      expect(repository.lastEsp32Path, 'control/ac');
      expect(repository.lastEsp32Data?['temp'], 22);

      await usecase.toggleMatterDevice(10, 1, true);
      expect(repository.lastMatterNodeId, 10);
      expect(repository.lastMatterEndpointId, 1);
      expect(repository.lastMatterIsOn, isTrue);
    });
  });
}
