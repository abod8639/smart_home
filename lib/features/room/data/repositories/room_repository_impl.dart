import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_local_datasource.dart';
import '../models/room_model.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomLocalDatasource localDatasource;

  RoomRepositoryImpl({required this.localDatasource});

  @override
  Future<List<RoomEntity>> getRooms() async {
    return await localDatasource.getRooms();
  }

  @override
  Future<void> addRoom(RoomEntity room) async {
    final currentRooms = await localDatasource.getRooms();
    currentRooms.add(RoomModel.fromEntity(room));
    await localDatasource.saveRooms(currentRooms);
  }

  @override
  Future<void> deleteRoom(String id) async {
    final currentRooms = await localDatasource.getRooms();
    currentRooms.removeWhere((room) => room.id == id);
    await localDatasource.saveRooms(currentRooms);
  }
}
