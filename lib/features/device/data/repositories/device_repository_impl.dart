import '../../domain/entities/device_entity.dart';
import '../../domain/repositories/device_repository.dart';
import '../datasources/device_remote_datasource.dart';
import '../datasources/device_local_datasource.dart';
import '../datasources/device_websocket_datasource.dart';
import '../models/device_model.dart';

class DeviceRepositoryImpl implements DeviceRepository {
  final DeviceRemoteDatasource remoteDatasource;
  final DeviceLocalDatasource localDatasource;
  final DeviceWebSocketDatasource webSocketDatasource;

  DeviceRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.webSocketDatasource,
  });

  @override
  Future<List<DeviceEntity>> getAllDevices() async {
    // Optionally fetch from HTTP first, or just return empty and wait for websocket.
    try {
      final models = await remoteDatasource.getAllDevices();
      await localDatasource.cacheDevices(models);
      return models;
    } catch (e) {
      // If HTTP fails, try to return cached data
      return []; // or localDatasource.getCachedDevices();
    }
  }

  @override
  Future<DeviceEntity> getDeviceById(String id) =>
      remoteDatasource.getDeviceById(id);

  @override
  Future<void> createDevice(DeviceEntity entity) =>
      remoteDatasource.createDevice(DeviceModel(
        id: entity.id, 
        name: entity.name, 
        type: entity.type, 
        room: entity.room, 
        isOn: entity.isOn
      ));

  // WebSocket Implementations
  @override
  Stream<List<DeviceEntity>> get deviceStream => webSocketDatasource.deviceStream;

  @override
  Future<void> connectToWebSocket(String url) async {
    await webSocketDatasource.connect(url);
  }

  @override
  void disconnectWebSocket() {
    webSocketDatasource.disconnect();
  }

  @override
  void toggleDevice(String id, bool newState) {
    webSocketDatasource.toggleDevice(id, newState);
  }
}
