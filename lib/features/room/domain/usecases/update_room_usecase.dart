import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'update_room_usecase.g.dart';

/// Use case for updating an existing room in the smart home system.
class UpdateRoomUseCase {
  /// The repository dependency used to manage rooms.
  final RoomRepository repository;

  /// Creates an [UpdateRoomUseCase].
  UpdateRoomUseCase(this.repository);

  /// Executes the use case to update [room].
  Future<void> call(RoomEntity room) async {
    await repository.updateRoom(room);
  }
}

/// Provider for accessing [UpdateRoomUseCase].
@riverpod
UpdateRoomUseCase updateRoomUseCase(Ref ref) {
  return UpdateRoomUseCase(ref.watch(roomRepositoryProvider));
}
