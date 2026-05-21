import 'dart:convert';
import 'dart:async';
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
  final StreamController<List<DeviceModel>> _streamController = StreamController<List<DeviceModel>>.broadcast();
  
  // Demo state in case WebSocket connection fails (no ESP32 connected)
  List<DeviceModel> _demoDevices = [
    const DeviceModel(id: '1', name: 'Main Light', type: 'light', room: 'Living Room', isOn: true),
    const DeviceModel(id: '2', name: 'Air Conditioner', type: 'ac', room: 'Living Room', isOn: false),
    const DeviceModel(id: '3', name: 'Smart TV', type: 'tv', room: 'Living Room', isOn: false),
  ];

  @override
  Stream<List<DeviceModel>> get deviceStream => _streamController.stream;

  @override
  Future<void> connect(String url) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // We set up the listener immediately to catch any stream errors
      _channel!.stream.listen((message) {
        try {
          final List<dynamic> data = jsonDecode(message);
          final devices = data.map((e) => DeviceModel.fromJson(e)).toList();
          _streamController.add(devices);
        } catch (e) {
          // ignore parsing error
        }
      }, onError: (error) {
        _channel = null;
        _fallbackToDemo();
      }, onDone: () {
        _channel = null;
        _fallbackToDemo();
      });

      await _channel!.ready.catchError((e) {
        throw e;
      });

    } catch (e) {
      _channel = null;
      // Fallback to demo mode if connection fails (e.g. invalid IP or ESP32 off)
      _fallbackToDemo();
    }
  }

  void _fallbackToDemo() {
    if (!_streamController.isClosed) {
      _streamController.add(_demoDevices);
    }
  }

  @override
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    if (!_streamController.isClosed) {
      _streamController.close();
    }
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
    } else {
      // Demo mode toggle
      _demoDevices = _demoDevices.map((d) {
        if (d.id == id) {
          return DeviceModel(
            id: d.id, 
            name: d.name, 
            type: d.type, 
            room: d.room, 
            isOn: newState,
          );
        }
        return d;
      }).toList();
      
      // Simulate network delay to show the Lottie/loading indicator visually
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!_streamController.isClosed) {
           _streamController.add(_demoDevices);
        }
      });
    }
  }
}
