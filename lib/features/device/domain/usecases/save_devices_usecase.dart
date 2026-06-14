import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';

part 'save_devices_usecase.g.dart';

class SaveDevicesUseCase {
  final DeviceRepository repository;

  SaveDevicesUseCase(this.repository);

  Future<void> call(List<DeviceEntity> devices) async {
    await repository.saveDevices(devices);
  }
}

@riverpod
SaveDevicesUseCase saveDevicesUseCase(Ref ref) {
  return SaveDevicesUseCase(ref.watch(deviceRepositoryProvider));
}
