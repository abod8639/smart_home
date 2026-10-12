import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

part 'sync_ir_codes_usecase.g.dart';

/// Use case for retrieving learned IR code configurations from remote storage.
class SyncIrCodesUseCase {
  final DashboardRepository repository;

  SyncIrCodesUseCase(this.repository);

  Future<Map<String, dynamic>> call(String deviceId) async {
    return await repository.fetchRemoteIrCodes(deviceId);
  }
}

/// Provider for accessing [SyncIrCodesUseCase].
@riverpod
SyncIrCodesUseCase syncIrCodesUseCase(Ref ref) {
  return SyncIrCodesUseCase(ref.watch(dashboardRepositoryProvider));
}
