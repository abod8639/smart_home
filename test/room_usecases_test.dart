import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/domain/repositories/room_repository.dart';
import 'package:smart_home/features/room/domain/usecases/add_room_usecase.dart';
import 'package:smart_home/features/room/domain/usecases/delete_room_usecase.dart';
import 'package:smart_home/features/room/domain/usecases/get_rooms_usecase.dart';
import 'package:smart_home/features/room/domain/usecases/save_rooms_usecase.dart';
import 'package:smart_home/features/room/domain/usecases/update_room_usecase.dart';

class FakeRoomRepository implements RoomRepository {
  final List<RoomEntity> rooms = [];

  @override
  Future<List<RoomEntity>> getRooms() async => List.unmodifiable(rooms);

  @override
  Future<void> addRoom(RoomEntity room) async {
    rooms.add(room);
  }

  @override
  Future<void> updateRoom(RoomEntity room) async {
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      rooms[index] = room;
    }
  }

  @override
  Future<void> deleteRoom(String id) async {
    rooms.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> saveRooms(List<RoomEntity> newRooms) async {
    rooms.clear();
    rooms.addAll(newRooms);
  }
}

void main() {
  group('Room Use Cases Tests', () {
    late FakeRoomRepository repository;

    setUp(() {
      repository = FakeRoomRepository();
    });

    test('GetRoomsUseCase returns room list from repository', () async {
      repository.rooms.addAll([
        const RoomEntity(id: '1', name: 'Living Room', deviceCount: 3),
        const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
      ]);

      final useCase = GetRoomsUseCase(repository);
      final result = await useCase.call();

      expect(result.length, 2);
      expect(result.first.name, 'Living Room');
    });

    test('AddRoomUseCase adds a room to repository', () async {
      final useCase = AddRoomUseCase(repository);
      await useCase.call(const RoomEntity(id: 'r_new', name: 'Office', deviceCount: 1));

      expect(repository.rooms.length, 1);
      expect(repository.rooms.first.id, 'r_new');
      expect(repository.rooms.first.name, 'Office');
    });

    test('UpdateRoomUseCase modifies an existing room in repository', () async {
      repository.rooms.add(const RoomEntity(id: 'r1', name: 'Bedroom', deviceCount: 2));

      final useCase = UpdateRoomUseCase(repository);
      await useCase.call(const RoomEntity(id: 'r1', name: 'Guest Room', deviceCount: 3));

      expect(repository.rooms.length, 1);
      expect(repository.rooms.first.name, 'Guest Room');
      expect(repository.rooms.first.deviceCount, 3);
    });

    test('DeleteRoomUseCase removes room by id from repository', () async {
      repository.rooms.addAll([
        const RoomEntity(id: 'r1', name: 'Balcony', deviceCount: 1),
        const RoomEntity(id: 'r2', name: 'Garage', deviceCount: 0),
      ]);

      final useCase = DeleteRoomUseCase(repository);
      await useCase.call('r1');

      expect(repository.rooms.length, 1);
      expect(repository.rooms.first.id, 'r2');
    });

    test('SaveRoomsUseCase overwrites all rooms in repository', () async {
      repository.rooms.add(const RoomEntity(id: 'old', name: 'Old Room', deviceCount: 0));

      final useCase = SaveRoomsUseCase(repository);
      final newRooms = [
        const RoomEntity(id: 'n1', name: 'Room 1', deviceCount: 2),
        const RoomEntity(id: 'n2', name: 'Room 2', deviceCount: 4),
      ];

      await useCase.call(newRooms);

      expect(repository.rooms.length, 2);
      expect(repository.rooms.map((r) => r.id).toList(), ['n1', 'n2']);
    });
  });
}
