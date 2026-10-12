import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'delete_room_usecase.g.dart';

/// Use case for deleting a room by id from the smart home system.
class DeleteRoomUseCase {
  /// The repository dependency used to manage rooms.
  final RoomRepository repository;

  /// Creates a [DeleteRoomUseCase].
  DeleteRoomUseCase(this.repository);

  /// Executes the use case to remove the room with [id].
  Future<void> call(String id) async {
    await repository.deleteRoom(id);
  }
}

/// Provider for accessing [DeleteRoomUseCase].
@riverpod
DeleteRoomUseCase deleteRoomUseCase(Ref ref) {
  return DeleteRoomUseCase(ref.watch(roomRepositoryProvider));
}
