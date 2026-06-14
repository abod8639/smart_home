import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/room_entity.dart';
import '../repositories/room_repository.dart';
import '../../data/repositories/room_repository_impl.dart';

part 'save_rooms_usecase.g.dart';

class SaveRoomsUseCase {
  final RoomRepository repository;

  SaveRoomsUseCase(this.repository);

  Future<void> call(List<RoomEntity> rooms) async {
    await repository.saveRooms(rooms);
  }
}

@riverpod
SaveRoomsUseCase saveRoomsUseCase(Ref ref) {
  return SaveRoomsUseCase(ref.watch(roomRepositoryProvider));
}
