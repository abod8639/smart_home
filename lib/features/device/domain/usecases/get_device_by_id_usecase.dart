import '../entities/device_entity.dart';
import '../repositories/device_repository.dart';

class GetDeviceByIdUsecase {
  final DeviceRepository repository;

  GetDeviceByIdUsecase(this.repository);

  Future<DeviceEntity> call(String id) => repository.getDeviceById(id);
}
