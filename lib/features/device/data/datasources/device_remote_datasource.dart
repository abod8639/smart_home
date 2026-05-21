import 'package:dio/dio.dart';
import '../models/device_model.dart';

abstract class DeviceRemoteDatasource {
  Future<List<DeviceModel>> getAllDevices();
  Future<DeviceModel> getDeviceById(String id);
  Future<void> createDevice(DeviceModel model);
}

class DeviceRemoteDatasourceImpl implements DeviceRemoteDatasource {
  final Dio dio;

  DeviceRemoteDatasourceImpl({required this.dio});

  @override
  Future<List<DeviceModel>> getAllDevices() async {
    // TODO: implement API call
    throw UnimplementedError();
  }

  @override
  Future<DeviceModel> getDeviceById(String id) async {
    // TODO: implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> createDevice(DeviceModel model) async {
    // TODO: implement API call
    throw UnimplementedError();
  }
}
