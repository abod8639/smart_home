import '../entities/room_entity.dart';

/// Repository interface defining room data access contracts.
abstract class RoomRepository {
  /// Retrieves all rooms from the data source.
  Future<List<RoomEntity>> getRooms();

  /// Adds a new room.
  Future<void> addRoom(RoomEntity room);

  /// Deletes a room by its [id].
  Future<void> deleteRoom(String id);

  /// Persists a list of [rooms], overwriting the existing ones.
  Future<void> saveRooms(List<RoomEntity> rooms);
}
