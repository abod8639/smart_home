import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/dashboard/domain/entities/dashboard_overview_entity.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

void main() {
  group('DashboardOverviewEntity Tests', () {
    const room1 = RoomEntity(id: 'r1', name: 'Living Room', deviceCount: 2);
    const room2 = RoomEntity(id: 'r2', name: 'Bedroom', deviceCount: 1, isActive: true);
    const device1 = LampDeviceEntity(id: 'd1', name: 'Desk Lamp', isOn: false);

    test('instantiates with expected properties', () {
      const entity = DashboardOverviewEntity(
        rooms: [room1, room2],
        devices: [device1],
        sendingIrKeys: {'ac::power'},
        pendingDeviceIds: {'d1'},
      );

      expect(entity.rooms.length, 2);
      expect(entity.devices.length, 1);
      expect(entity.sendingIrKeys, contains('ac::power'));
      expect(entity.pendingDeviceIds, contains('d1'));
      expect(entity.activeRoom, equals(room2));
    });

    test('activeRoom returns null when no room is active', () {
      const entity = DashboardOverviewEntity(
        rooms: [room1],
      );
      expect(entity.activeRoom, isNull);
    });

    test('copyWith updates fields correctly', () {
      const entity = DashboardOverviewEntity(rooms: [room1]);
      final updated = entity.copyWith(
        rooms: [room1, room2],
        sendingIrKeys: {'new_key'},
      );

      expect(updated.rooms.length, 2);
      expect(updated.sendingIrKeys, contains('new_key'));
      expect(updated.devices, isEmpty);
    });
  });
}
