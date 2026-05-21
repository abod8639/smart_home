import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class CreateDeviceUsecase {
  final DeviceRepository repository;

  CreateDeviceUsecase(this.repository);

  Future<void> call(DeviceEntity entity) => repository.createDevice(entity);
}
