import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_local_datasource.dart';
import '../models/device_model.dart';

part 'device_repository_impl.g.dart';

/// Concrete implementation of [DeviceRepository] using [DeviceLocalDatasource].
class DeviceRepositoryImpl implements DeviceRepository {
  /// The local data source for reading/writing devices.
  final DeviceLocalDatasource localDatasource;

  /// Creates a [DeviceRepositoryImpl] instance.
  DeviceRepositoryImpl({required this.localDatasource});

  @override
  Future<List<DeviceEntity>> getDevices() async {
    final models = localDatasource.loadDevices();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveDevices(List<DeviceEntity> devices) async {
    final models = devices.map((d) => DeviceModel.fromEntity(d)).toList();
    await localDatasource.saveDevices(models);
  }

  @override
  Future<void> clearDevices() async {
    await localDatasource.clearDevices();
  }
}

/// Riverpod provider for [DeviceRepository].
@riverpod
DeviceRepository deviceRepository(Ref ref) {
  return DeviceRepositoryImpl(
    localDatasource: ref.watch(deviceLocalDatasourceProvider),
  );
}
