import '../models/device_model.dart';

abstract class DeviceLocalDatasource {
  Future<List<DeviceModel>> getCachedDevices();
  Future<void> cacheDevices(List<DeviceModel> models);
}

class DeviceLocalDatasourceImpl implements DeviceLocalDatasource {
  // TODO: inject SharedPreferences / Hive / Isar

  @override
  Future<List<DeviceModel>> getCachedDevices() async {
    // TODO: implement local read
    throw UnimplementedError();
  }

  @override
  Future<void> cacheDevices(List<DeviceModel> models) async {
    // TODO: implement local write
    throw UnimplementedError();
  }
}
