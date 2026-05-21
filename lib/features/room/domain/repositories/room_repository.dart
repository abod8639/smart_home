import '../entities/room_entity.dart';

abstract class RoomRepository {
  Future<List<RoomEntity>> getRooms();
  Future<void> addRoom(RoomEntity room);
  Future<void> deleteRoom(String id);
}
