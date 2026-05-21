import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/device_model.dart';

abstract class DeviceWebSocketDatasource {
  Stream<List<DeviceModel>> get deviceStream;
  Future<void> connect(String url);
  void disconnect();
  void toggleDevice(String id, bool newState);
}

class DeviceWebSocketDatasourceImpl implements DeviceWebSocketDatasource {
  WebSocketChannel? _channel;
  
  @override
  Stream<List<DeviceModel>> get deviceStream {
    if (_channel == null) {
      return const Stream.empty();
    }
    return _channel!.stream.map((message) {
      // Assuming ESP32 sends a JSON array of devices:
      // [{"id": "1", "name": "Living Room Light", "type": "light", "room": "Living Room", "isOn": true}, ...]
      try {
        final List<dynamic> data = jsonDecode(message);
        return data.map((e) => DeviceModel.fromJson(e)).toList();
      } catch (e) {
        print("Error parsing WebSocket message: \$e");
        return [];
      }
    });
  }

  @override
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      await _channel!.ready;
    } catch (e) {
      print("WebSocket connection failed: \$e");
      rethrow;
    }
  }

  @override
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }

  @override
  void toggleDevice(String id, bool newState) {
    if (_channel != null) {
      final message = jsonEncode({
        "action": "toggle",
        "id": id,
        "state": newState,
      });
      _channel!.sink.add(message);
    }
  }
}
