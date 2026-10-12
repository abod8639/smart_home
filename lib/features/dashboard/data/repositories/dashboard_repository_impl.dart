import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

part 'dashboard_repository_impl.g.dart';

/// Concrete implementation of [DashboardRepository] backed by [DashboardRemoteDataSource].
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RoomEntity>?> fetchRemoteRooms() async {
    return await remoteDataSource.fetchRooms();
  }

  @override
  Future<List<DeviceEntity>?> fetchRemoteDevices() async {
    return await remoteDataSource.fetchDevices();
  }

  @override
  Stream<List<RoomEntity>> watchRemoteRooms() {
    return remoteDataSource.roomsStream;
  }

  @override
  Stream<List<DeviceEntity>> watchRemoteDevices() {
    return remoteDataSource.devicesStream;
  }

  @override
  Future<Map<String, dynamic>> fetchRemoteIrCodes(String deviceId) async {
    return await remoteDataSource.fetchIrCodes(deviceId);
  }

  @override
  Future<void> sendEsp32Command(
    String path, {
    String method = 'POST',
    Map<String, dynamic>? data,
  }) async {
    await remoteDataSource.sendEsp32Command(path, method: method, data: data);
  }

  @override
  Future<void> toggleMatterDevice(int nodeId, int endpointId, bool isOn) async {
    await remoteDataSource.toggleMatterDevice(nodeId, endpointId, isOn);
  }
}

/// Provider for accessing [DashboardRepository].
@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  return DashboardRepositoryImpl(
    remoteDataSource: ref.watch(dashboardRemoteDataSourceProvider),
  );
}
