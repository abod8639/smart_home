import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'add_room_usecase.g.dart';

/// Use case for adding a new room to the smart home system.
class AddRoomUseCase {
  /// The repository dependency used to manage rooms.
  final RoomRepository repository;

  /// Creates an [AddRoomUseCase].
  AddRoomUseCase(this.repository);

  /// Executes the use case to persist the new [room].
  Future<void> call(RoomEntity room) async {
    await repository.addRoom(room);
  }
}

/// Provider for accessing [AddRoomUseCase].
@riverpod
AddRoomUseCase addRoomUseCase(Ref ref) {
  return AddRoomUseCase(ref.watch(roomRepositoryProvider));
}
