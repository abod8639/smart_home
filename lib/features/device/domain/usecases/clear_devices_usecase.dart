import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';

part 'clear_devices_usecase.g.dart';

/// Use case to clear/reset all stored smart home devices.
class ClearDevicesUseCase {
  /// The abstract device repository interface.
  final DeviceRepository repository;

  /// Creates a [ClearDevicesUseCase] instance with [repository].
  ClearDevicesUseCase(this.repository);

  /// Executes the use case to clear all devices.
  Future<void> call() async {
    await repository.clearDevices();
  }
}

/// Riverpod provider for [ClearDevicesUseCase].
@riverpod
ClearDevicesUseCase clearDevicesUseCase(Ref ref) {
  return ClearDevicesUseCase(ref.watch(deviceRepositoryProvider));
}
