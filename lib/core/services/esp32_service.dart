import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/core/services/firebase_service.dart';

part 'esp32/esp32_mqtt.dart';
part 'esp32/esp32_firebase.dart';
part 'esp32/esp32_controller_sync.dart';
part 'esp32/esp32_api.dart';

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

/// Professional and flexible control service for ESP32 microcontrollers using MQTT
class Esp32Service extends GetxService {
  MqttServerClient? _client;
  final isConnected = false.obs;
  
  Completer<IrCodeEntity>? _irLearnCompleter;
  Completer<Map<String, dynamic>>? _stateCompleter;
  
  // Retrieves SettingsController which holds the current broker URL (formerly IP)
  SettingsController get _settings => Get.find<SettingsController>();

  // Broker URL
  String get brokerUrl => _settings.ipAddress.value;

  // Device ID must match ESP32
  static const String deviceId = 'esp32_smart_home_1';

  // Topics
  static const String topicCmd = 'smarthome/$deviceId/cmd';
  static const String topicState = 'smarthome/$deviceId/state';
  static const String topicSensor = 'smarthome/$deviceId/sensor';
  static const String topicEvent = 'smarthome/$deviceId/event';
  static const String topicStatus = 'smarthome/$deviceId/status';

  // Retrieves FirebaseService for external network fallback
  FirebaseService get _firebase => Get.find<FirebaseService>();

  // Subscription list for cleaning up Firebase listeners if needed
  final List<StreamSubscription> _firebaseSubscriptions = [];

  bool _reconnecting = false;

  @override
  void onInit() { 
    super.onInit();
    
    // Initialize MQTT connection
    _connectMqtt();
    
    // Auto-reconnect if the broker address configuration changes
    ever(_settings.ipAddress, (_) {
      debugPrint('MQTT Broker URL changed, reconnecting...');
      _reconnect();
    });

    // Start listening to Firebase states to sync UI when MQTT is disconnected
    _initFirebaseSync();
  }

  @override
  void onClose() {
    _disconnectMqtt();
    for (var sub in _firebaseSubscriptions) {
      sub.cancel();
    }
    super.onClose();
  }
}
