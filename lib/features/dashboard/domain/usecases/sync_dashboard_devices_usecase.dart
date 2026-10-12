import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import '../repositories/dashboard_repository.dart';
import '../../data/repositories/dashboard_repository_impl.dart';

part 'sync_dashboard_devices_usecase.g.dart';

/// Use case for fetching and observing remote device updates.
class SyncDashboardDevicesUseCase {
  final DashboardRepository repository;

  SyncDashboardDevicesUseCase(this.repository);

  Future<List<DeviceEntity>?> fetchDevices() async {
    return await repository.fetchRemoteDevices();
  }

  Stream<List<DeviceEntity>> watchDevices() {
    return repository.watchRemoteDevices();
  }
}

/// Provider for accessing [SyncDashboardDevicesUseCase].
@riverpod
SyncDashboardDevicesUseCase syncDashboardDevicesUseCase(Ref ref) {
  return SyncDashboardDevicesUseCase(ref.watch(dashboardRepositoryProvider));
}
