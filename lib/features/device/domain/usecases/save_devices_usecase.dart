import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';

part 'save_devices_usecase.g.dart';

/// Use case to save/persist a list of smart home devices.
class SaveDevicesUseCase {
  /// The abstract device repository interface.
  final DeviceRepository repository;

  /// Creates a [SaveDevicesUseCase] instance with [repository].
  SaveDevicesUseCase(this.repository);

  /// Executes the use case to save the provided [devices].
  Future<void> call(List<DeviceEntity> devices) async {
    await repository.saveDevices(devices);
  }
}

/// Riverpod provider for [SaveDevicesUseCase].
@riverpod
SaveDevicesUseCase saveDevicesUseCase(Ref ref) {
  return SaveDevicesUseCase(ref.watch(deviceRepositoryProvider));
}
