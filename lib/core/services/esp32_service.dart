import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/device/data/models/ir_code_model.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/core/services/firebase_service.dart';

part 'esp32/esp32_mqtt.dart';
part 'esp32/esp32_firebase.dart';
part 'esp32/esp32_controller_sync.dart';
part 'esp32/esp32_api.dart';
part 'esp32_service.g.dart';

/// Generic response wrapper for ESP32 operations
class EspResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  EspResponse.success(this.data) : isSuccess = true, errorMessage = null;
  EspResponse.failure(this.errorMessage) : isSuccess = false, data = null;

  @override
  String toString() {
    if (isSuccess) return 'EspResponse: Success(data: $data)';
    return 'EspResponse: Failure(error: $errorMessage)';
  }
}


class IsConnectedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool val) => state = val;
}
final isConnectedProvider = NotifierProvider<IsConnectedNotifier, bool>(IsConnectedNotifier.new);


/// Professional and flexible control service for ESP32 microcontrollers using MQTT
@Riverpod(keepAlive: true)
class Esp32Service extends _$Esp32Service {
  MqttServerClient? _client;
  
  Completer<IrCodeEntity>? _irLearnCompleter;
  Completer<Map<String, dynamic>>? _stateCompleter;

  bool get isConnected => _client?.connectionStatus?.state == MqttConnectionState.connected;
  
  // Broker URL
  String get brokerUrl => ref.read(settingsControllerProvider).ipAddress;

  // Device ID must match ESP32
  static const String deviceId = 'esp32_smart_home_1';

  // Topics
  static const String topicCmd = 'smarthome/$deviceId/cmd';
  static const String topicState = 'smarthome/$deviceId/state';
  static const String topicSensor = 'smarthome/$deviceId/sensor';
  static const String topicEvent = 'smarthome/$deviceId/event';
  static const String topicStatus = 'smarthome/$deviceId/status';

  // Retrieves FirebaseService for external network fallback
  FirebaseService get _firebase => ref.read(firebaseServiceProvider.notifier);

  // Subscription list for cleaning up Firebase listeners if needed
  final List<StreamSubscription> _firebaseSubscriptions = [];

  bool _reconnecting = false;

  @override
  void build() { 
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest) {
      // Initialize MQTT connection
      _connectMqtt();
      
      // Auto-reconnect if the broker address configuration changes
      ref.listen(settingsControllerProvider.select((s) => s.ipAddress), (prev, next) {
        if (prev != next) {
          debugPrint('MQTT Broker URL changed, reconnecting...');
          _reconnect();
        }
      });

      // Start listening to Firebase states to sync UI when MQTT is disconnected
      _initFirebaseSync();
    }
    
    ref.onDispose(() {
      _disconnectMqtt();
      for (var sub in _firebaseSubscriptions) {
        sub.cancel();
      }
    });
  }

  // ─────────────── DYNAMIC DISPATCH / MOCKING SUPPORT ───────────────
  // These forwarding methods allow the Esp32Api extension methods to be mockable/overridden.
  Future<EspResponse<bool>> pingHub() => Esp32Api(this).pingHub();
  Future<EspResponse<Map<String, dynamic>>> getSensorData() => Esp32Api(this).getSensorData();
  Future<EspResponse<bool>> setDigitalOutput(dynamic pin, bool state) => Esp32Api(this).setDigitalOutput(pin, state);
  Future<EspResponse<bool>> setAnalogOutput(dynamic pin, int value) => Esp32Api(this).setAnalogOutput(pin, value);
  Future<EspResponse<dynamic>> sendRawCommand(String path, {String method = 'POST', dynamic data}) => Esp32Api(this).sendRawCommand(path, method: method, data: data);
  Future<EspResponse<IrCodeEntity>> learnIrCode() => Esp32Api(this).learnIrCode();
  Future<EspResponse<bool>> sendIrCode(IrCodeEntity irCode) => Esp32Api(this).sendIrCode(irCode);
}
