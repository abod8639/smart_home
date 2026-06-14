import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/room/data/datasources/room_local_datasource.dart';
import 'package:smart_home/features/room/data/models/room_model.dart';
import 'package:smart_home/features/room/data/repositories/room_repository_impl.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

// ── In-memory fake datasource for testing ────────────────────────────────────
class FakeRoomLocalDatasource extends RoomLocalDatasource {
  final List<RoomModel> _store;

  FakeRoomLocalDatasource([List<RoomModel>? initial])
      : _store = List.from(initial ?? []);

  @override
  Future<List<RoomModel>> getRooms() async => List.from(_store);

  @override
  Future<void> saveRooms(List<RoomModel> rooms) async {
    _store.clear();
    _store.addAll(rooms);
  }

  @override
  List<RoomModel> loadRooms() => List.from(_store);

  @override
  bool get hasData => _store.isNotEmpty;
}

void main() {
  group('RoomLocalDatasource Serialization Tests', () {
    test('toMap serializes RoomEntity correctly', () {
      const room = RoomEntity(
        id: 'room_1',
        name: 'Playroom',
        deviceCount: 5,
        isActive: true,
        iconPath: 'assets/play.png',
        imagePath: 'assets/play_bg.png',
      );

      final model = RoomModel.fromEntity(room);
      final map = RoomLocalDatasource.toMap(model);
      expect(map['id'], 'room_1');
      expect(map['name'], 'Playroom');
      expect(map['deviceCount'], 5);
      expect(map['isActive'], isTrue);
      expect(map['iconPath'], 'assets/play.png');
      expect(map['imagePath'], 'assets/play_bg.png');
    });

    test('toMap handles null imagePath', () {
      const room = RoomEntity(
        id: 'r1',
        name: 'Room',
        deviceCount: 0,
      );
      final model = RoomModel.fromEntity(room);
      final map = RoomLocalDatasource.toMap(model);
      expect(map['imagePath'], isNull);
    });

    test('fromMap deserializes a RoomModel correctly', () {
      final map = {
        'id': 'r2',
        'name': 'Bathroom',
        'deviceCount': 2,
        'isActive': false,
        'iconPath': 'bath.png',
        'imagePath': 'bath_bg.jpg',
      };
      final model = RoomLocalDatasource.fromMap(map);
      expect(model.id, 'r2');
      expect(model.name, 'Bathroom');
      expect(model.deviceCount, 2);
      expect(model.isActive, isFalse);
      expect(model.iconPath, 'bath.png');
      expect(model.imagePath, 'bath_bg.jpg');
    });

    test('fromMap provides defaults for missing fields', () {
      final map = <String, dynamic>{'id': 'r3', 'name': 'Room'};
      final model = RoomLocalDatasource.fromMap(map);
      expect(model.deviceCount, 0);
      expect(model.isActive, isFalse);
      expect(model.iconPath, '');
      expect(model.imagePath, isNull);
    });

    test('toMap → fromMap round-trip preserves all fields', () {
      const room = RoomEntity(
        id: 'room_42',
        name: 'Studio',
        deviceCount: 7,
        isActive: true,
        iconPath: 'studio.png',
        imagePath: 'studio_bg.jpg',
      );
      final model = RoomModel.fromEntity(room);
      final map = RoomLocalDatasource.toMap(model);
      final restored = RoomLocalDatasource.fromMap(map);
      expect(restored.id, room.id);
      expect(restored.name, room.name);
      expect(restored.deviceCount, room.deviceCount);
      expect(restored.isActive, room.isActive);
      expect(restored.iconPath, room.iconPath);
      expect(restored.imagePath, room.imagePath);
    });

    test('loadRooms returns empty list in test environment (FLUTTER_TEST set)', () {
      // The datasource returns [] in test env by checking FLUTTER_TEST env var
      final ds = RoomLocalDatasource();
      final result = ds.loadRooms();
      expect(result, isEmpty);
    });

    test('hasData returns false in test environment', () {
      final ds = RoomLocalDatasource();
      expect(ds.hasData, isFalse);
    });
  });

  group('RoomRepositoryImpl Tests', () {
    RoomRepositoryImpl buildRepo([List<RoomModel>? initial]) {
      final ds = FakeRoomLocalDatasource(initial);
      return RoomRepositoryImpl(localDatasource: ds);
    }

    test('getRooms returns all rooms from datasource', () async {
      final initialRooms = [
        RoomModel.fromEntity(
            const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 2)),
        RoomModel.fromEntity(
            const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 3)),
      ];
      final repo = buildRepo(initialRooms);

      final rooms = await repo.getRooms();
      expect(rooms.length, 2);
      expect(rooms.any((r) => r.id == '1'), isTrue);
      expect(rooms.any((r) => r.id == '2'), isTrue);
    });

    test('getRooms returns empty list when no rooms stored', () async {
      final repo = buildRepo([]);
      final rooms = await repo.getRooms();
      expect(rooms, isEmpty);
    });

    test('addRoom appends a new room', () async {
      final repo = buildRepo([
        RoomModel.fromEntity(
            const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 2)),
      ]);

      const newRoom = RoomEntity(id: '99', name: 'Garage', deviceCount: 0);
      await repo.addRoom(newRoom);

      final rooms = await repo.getRooms();
      expect(rooms.length, 2);
      expect(rooms.any((r) => r.id == '99' && r.name == 'Garage'), isTrue);
    });

    test('addRoom preserves existing rooms', () async {
      final repo = buildRepo([
        RoomModel.fromEntity(
            const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 2)),
        RoomModel.fromEntity(
            const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 3)),
      ]);

      const newRoom = RoomEntity(id: '3', name: 'Bathroom', deviceCount: 1);
      await repo.addRoom(newRoom);

      final rooms = await repo.getRooms();
      expect(rooms.length, 3);
      expect(rooms.any((r) => r.id == '1'), isTrue);
      expect(rooms.any((r) => r.id == '2'), isTrue);
      expect(rooms.any((r) => r.id == '3'), isTrue);
    });

    test('deleteRoom removes the correct room', () async {
      final repo = buildRepo([
        RoomModel.fromEntity(
            const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 2)),
        RoomModel.fromEntity(
            const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 3)),
        RoomModel.fromEntity(
            const RoomEntity(id: '3', name: 'Bathroom', deviceCount: 1)),
      ]);

      await repo.deleteRoom('2');

      final rooms = await repo.getRooms();
      expect(rooms.length, 2);
      expect(rooms.any((r) => r.id == '2'), isFalse);
      expect(rooms.any((r) => r.id == '1'), isTrue);
      expect(rooms.any((r) => r.id == '3'), isTrue);
    });

    test('deleteRoom on non-existent id does not throw or alter rooms', () async {
      final repo = buildRepo([
        RoomModel.fromEntity(
            const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 2)),
      ]);

      await repo.deleteRoom('NONEXISTENT');

      final rooms = await repo.getRooms();
      expect(rooms.length, 1);
      expect(rooms.first.id, '1');
    });
  });
}
