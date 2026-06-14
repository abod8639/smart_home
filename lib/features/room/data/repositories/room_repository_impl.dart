import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_local_datasource.dart';
import '../models/room_model.dart';

part 'room_repository_impl.g.dart';

/// Concrete implementation of [RoomRepository] using a local datasource.
class RoomRepositoryImpl implements RoomRepository {
  /// The local data source used for persistence.
  final RoomLocalDatasource localDatasource;

  /// Creates a [RoomRepositoryImpl].
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

  @override
  Future<void> saveRooms(List<RoomEntity> rooms) async {
    await localDatasource.saveRooms(rooms.map((r) => RoomModel.fromEntity(r)).toList());
  }
}

/// Provider for accessing the [RoomRepository] implementation.
@riverpod
RoomRepository roomRepository(Ref ref) {
  return RoomRepositoryImpl(
    localDatasource: ref.watch(roomLocalDatasourceProvider),
  );
}
