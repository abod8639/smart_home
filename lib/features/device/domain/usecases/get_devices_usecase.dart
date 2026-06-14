import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';

part 'get_devices_usecase.g.dart';

/// Use case to retrieve all smart home devices.
class GetDevicesUseCase {
  /// The abstract device repository interface.
  final DeviceRepository repository;

  /// Creates a [GetDevicesUseCase] instance with [repository].
  GetDevicesUseCase(this.repository);

  /// Executes the use case to load all devices.
  Future<List<DeviceEntity>> call() async {
    return await repository.getDevices();
  }
}

/// Riverpod provider for [GetDevicesUseCase].
@riverpod
GetDevicesUseCase getDevicesUseCase(Ref ref) {
  return GetDevicesUseCase(ref.watch(deviceRepositoryProvider));
}
