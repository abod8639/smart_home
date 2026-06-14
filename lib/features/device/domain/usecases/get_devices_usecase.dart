import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';
import '../../data/repositories/device_repository_impl.dart';

part 'get_devices_usecase.g.dart';

class GetDevicesUseCase {
  final DeviceRepository repository;

  GetDevicesUseCase(this.repository);

  Future<List<DeviceEntity>> call() async {
    return await repository.getDevices();
  }
}

@riverpod
GetDevicesUseCase getDevicesUseCase(Ref ref) {
  return GetDevicesUseCase(ref.watch(deviceRepositoryProvider));
}
