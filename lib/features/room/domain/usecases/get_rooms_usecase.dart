import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'get_rooms_usecase.g.dart';

class GetRoomsUseCase {
  final RoomRepository repository;

  GetRoomsUseCase(this.repository);

  Future<List<RoomEntity>> call() async {
    return await repository.getRooms();
  }
}

@riverpod
GetRoomsUseCase getRoomsUseCase(Ref ref) {
  return GetRoomsUseCase(ref.watch(roomRepositoryProvider));
}
