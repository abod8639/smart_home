import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../data/datasources/device_remote_datasource.dart';
import '../../data/datasources/device_local_datasource.dart';
import '../../data/datasources/device_websocket_datasource.dart';
import '../../data/repositories/device_repository_impl.dart';
import '../../domain/entities/device_entity.dart';

// Providers for dependencies
final dioProvider = Provider<Dio>((ref) => Dio());

final deviceRemoteDatasourceProvider = Provider<DeviceRemoteDatasource>((ref) {
  return DeviceRemoteDatasourceImpl(dio: ref.read(dioProvider));
});

final deviceLocalDatasourceProvider = Provider<DeviceLocalDatasource>((ref) {
  return DeviceLocalDatasourceImpl();
});

final deviceWebSocketDatasourceProvider = Provider<DeviceWebSocketDatasource>((ref) {
  return DeviceWebSocketDatasourceImpl();
});

final deviceRepositoryProvider = Provider<DeviceRepositoryImpl>((ref) {
  return DeviceRepositoryImpl(
    remoteDatasource: ref.read(deviceRemoteDatasourceProvider),
    localDatasource: ref.read(deviceLocalDatasourceProvider),
    webSocketDatasource: ref.read(deviceWebSocketDatasourceProvider),
  );
});

// Stream Provider for real-time device updates
final deviceStreamProvider = StreamProvider<List<DeviceEntity>>((ref) {
  final repository = ref.read(deviceRepositoryProvider);
  // Auto connect when the stream is watched
  // Replace with your ESP32 IP
  repository.connectToWebSocket('ws://192.168.1.100:81'); 
  
  ref.onDispose(() {
    repository.disconnectWebSocket();
  });
  
  return repository.deviceStream;
});

// A Notifier to manage optimistic UI updates when toggling
class DeviceNotifier extends Notifier<AsyncValue<List<DeviceEntity>>> {
  @override
  AsyncValue<List<DeviceEntity>> build() {
    return ref.watch(deviceStreamProvider);
  }

  void toggleDevice(String id, bool currentState) {
    // 1. Optimistic update (show loading indicator for the specific device)
    if (state is AsyncData) {
      final currentList = state.value!;
      final updatedList = currentList.map((device) {
        if (device.id == id) {
          return device.copyWith(isLoading: true);
        }
        return device;
      }).toList();
      state = AsyncData(updatedList);
    }
    
    // 2. Send command to ESP32
    ref.read(deviceRepositoryProvider).toggleDevice(id, !currentState);
  }
}

// Provider that combines the stream and allows interaction
final deviceControllerProvider = NotifierProvider<DeviceNotifier, AsyncValue<List<DeviceEntity>>>(DeviceNotifier.new);
