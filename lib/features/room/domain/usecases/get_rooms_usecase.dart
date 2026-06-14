import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'get_rooms_usecase.g.dart';

/// Use case for retrieving the list of rooms in the smart home.
class GetRoomsUseCase {
  /// The repository dependency used to retrieve rooms.
  final RoomRepository repository;

  /// Creates a [GetRoomsUseCase].
  GetRoomsUseCase(this.repository);

  /// Executes the usecase to fetch all rooms.
  Future<List<RoomEntity>> call() async {
    return await repository.getRooms();
  }
}

/// Provider for accessing [GetRoomsUseCase].
@riverpod
GetRoomsUseCase getRoomsUseCase(Ref ref) {
  return GetRoomsUseCase(ref.watch(roomRepositoryProvider));
}
