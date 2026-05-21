import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/room_entity.dart';
import '../../data/datasources/room_local_datasource.dart';
import '../../data/repositories/room_repository_impl.dart';

// Dependencies
final roomLocalDatasourceProvider = Provider<RoomLocalDatasource>((ref) {
  return RoomLocalDatasourceImpl();
});

final roomRepositoryProvider = Provider<RoomRepositoryImpl>((ref) {
  return RoomRepositoryImpl(
    localDatasource: ref.read(roomLocalDatasourceProvider),
  );
});

// Notifier
class RoomNotifier extends AsyncNotifier<List<RoomEntity>> {
  @override
  Future<List<RoomEntity>> build() async {
    return _fetchRooms();
  }

  Future<List<RoomEntity>> _fetchRooms() async {
    return await ref.read(roomRepositoryProvider).getRooms();
  }

  Future<void> addRoom(RoomEntity room) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(roomRepositoryProvider).addRoom(room);
      return _fetchRooms();
    });
  }

  Future<void> deleteRoom(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(roomRepositoryProvider).deleteRoom(id);
      return _fetchRooms();
    });
  }
}

final roomControllerProvider = AsyncNotifierProvider<RoomNotifier, List<RoomEntity>>(RoomNotifier.new);
