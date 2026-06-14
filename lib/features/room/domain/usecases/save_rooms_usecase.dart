import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'save_rooms_usecase.g.dart';

/// Use case for persisting the list of rooms in the smart home.
class SaveRoomsUseCase {
  /// The repository dependency used to save rooms.
  final RoomRepository repository;

  /// Creates a [SaveRoomsUseCase].
  SaveRoomsUseCase(this.repository);

  /// Executes the usecase to persist the list of [rooms].
  Future<void> call(List<RoomEntity> rooms) async {
    await repository.saveRooms(rooms);
  }
}

/// Provider for accessing [SaveRoomsUseCase].
@riverpod
SaveRoomsUseCase saveRoomsUseCase(Ref ref) {
  return SaveRoomsUseCase(ref.watch(roomRepositoryProvider));
}
