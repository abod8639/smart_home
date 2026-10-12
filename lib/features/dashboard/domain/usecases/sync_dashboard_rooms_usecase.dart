import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import '../repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

part 'sync_dashboard_rooms_usecase.g.dart';

/// Use case for fetching and observing remote room updates.
class SyncDashboardRoomsUseCase {
  final DashboardRepository repository;

  SyncDashboardRoomsUseCase(this.repository);

  Future<List<RoomEntity>?> fetchRooms() async {
    return await repository.fetchRemoteRooms();
  }

  Stream<List<RoomEntity>> watchRooms() {
    return repository.watchRemoteRooms();
  }
}

/// Provider for accessing [SyncDashboardRoomsUseCase].
@riverpod
SyncDashboardRoomsUseCase syncDashboardRoomsUseCase(Ref ref) {
  return SyncDashboardRoomsUseCase(ref.watch(dashboardRepositoryProvider));
}
