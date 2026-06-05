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

  void _initFirebaseSync() {
    _firebaseSubscriptions.add(_firebase.temperatureStream.listen((event) {
      if (!isConnected.value && event.snapshot.value != null) {
        final double temp = (event.snapshot.value as num).toDouble();
        _syncSensorsWithControllers({'temperature': temp});
      }
    }));

    _firebaseSubscriptions.add(_firebase.humidityStream.listen((event) {
      if (!isConnected.value && event.snapshot.value != null) {
        final double hum = (event.snapshot.value as num).toDouble();
        _syncSensorsWithControllers({'humidity': hum});
      }
    }));

    _firebaseSubscriptions.add(_firebase.targetTempStream.listen((event) {
      if (!isConnected.value && event.snapshot.value != null) {
        final int target = (event.snapshot.value as num).toInt();
        _syncStateWithControllers({'target_temperature': target});
      }
    }));

    _firebaseSubscriptions.add(_firebase.pinsStream.listen((event) {
      if (!isConnected.value && event.snapshot.value != null) {
        try {
          final Map<dynamic, dynamic> pinsMap = event.snapshot.value as Map<dynamic, dynamic>;
          final Map<String, dynamic> formattedPins = {};
          pinsMap.forEach((key, val) {
            formattedPins[key.toString()] = val;
          });
          _syncStateWithControllers({'pins': formattedPins});
        } catch (e) {
          debugPrint('Error parsing pins map from Firebase: $e');
        }
      }
    }));
  }

  @override
  void onClose() {
    _disconnectMqtt();
    for (var sub in _firebaseSubscriptions) {
      sub.cancel();
    }
    super.onClose();
  }

  Future<void> _connectMqtt() async {
    _disconnectMqtt();
    debugPrint('Connecting to MQTT broker at: $brokerUrl');
    
    final clientId = 'flutter_client_${const Uuid().v4()}';
    _client = MqttServerClient(brokerUrl, clientId);
    _client!.port = 1883;
    _client!.logging(on: false);
    _client!.keepAlivePeriod = 20;
    _client!.onDisconnected = _onDisconnected;
    _client!.onConnected = _onConnected;
    _client!.onSubscribed = _onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean(); // Non persistent session for mobile app
    
    _client!.connectionMessage = connMess;

    try {
      await _client!.connect();
    } catch (e) {
      debugPrint('MQTT client exception: $e');
      _disconnectMqtt();
      _reconnectAfterDelay();
    }
  }

  void _onConnected() {
    debugPrint('MQTT Connected');
    isConnected.value = true;
    
    // Subscribe to topics
    _client!.subscribe(topicState, MqttQos.atLeastOnce);
    _client!.subscribe(topicSensor, MqttQos.atLeastOnce);
    _client!.subscribe(topicEvent, MqttQos.atLeastOnce);
    _client!.subscribe(topicStatus, MqttQos.atLeastOnce);

    _client!.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final recMess = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      _handleMessage(c[0].topic, payload);
    });

    // Request initial state
    sendRawMessage({'action': 'get_state'});
  }

  void _onDisconnected() {
    debugPrint('MQTT Disconnected');
    isConnected.value = false;
    _reconnectAfterDelay();
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT Subscribed to $topic');
  }

  void _disconnectMqtt() {
    if (_client != null && _client!.connectionStatus!.state == MqttConnectionState.connected) {
      _client!.disconnect();
    }
    _client = null;
  }

  bool _reconnecting = false;
  void _reconnectAfterDelay() {
    if (_reconnecting) return;
    _reconnecting = true;
    Future.delayed(const Duration(seconds: 5), () {
      _reconnecting = false;
      _connectMqtt();
    });
  }

  void _reconnect() {
    _disconnectMqtt();
    _connectMqtt();
  }

  void _handleMessage(String topic, String message) {
    debugPrint('<-- MQTT MESSAGE [$topic]: $message');
    
    if (topic == topicStatus) {
      // Device online/offline LWT handling
      if (message == 'online') {
        // You could use this to update hubReachability specifically if wanted
      }
      return;
    }

    try {
      final data = jsonDecode(message) as Map<String, dynamic>;

      if (topic == topicState) {
        if (_stateCompleter != null && !_stateCompleter!.isCompleted) {
          _stateCompleter!.complete(data);
        }
        _syncStateWithControllers(data);
      } else if (topic == topicSensor) {
        _syncSensorsWithControllers(data);
      } else if (topic == topicEvent) {
        final String? event = data['event'];
        if (event == 'relay_update') {
          _syncRelayWithControllers(data);
        } else if (event == 'pwm_update') {
          _syncPwmWithControllers(data);
        } else if (event == 'ac_update') {
          _syncAcWithControllers(data);
        } else if (event == 'ir_learn_status') {
          _handleIrLearnStatus(data);
        }
      }
    } catch (e) {
      debugPrint('Error decoding MQTT message: $e');
    }
  }

  void _syncStateWithControllers(Map<String, dynamic> state) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    
    if (state['temperature'] != null) {
      dashboard.temperature.value = '${state['temperature']}°';
    }
    if (state['humidity'] != null) {
      dashboard.humidity.value = '${state['humidity']}%';
    }
    if (state['wifi_rssi'] != null) {
      dashboard.wifiRssi.value = '${state['wifi_rssi']} dBm';
    }
    if (state['heap_free'] != null) {
      dashboard.heapFree.value = '${(state['heap_free'] / 1024).toStringAsFixed(1)} KB';
    }

    // Target AC temperature
    if (state['target_temperature'] != null) {
      final int targetTemp = state['target_temperature'];
      final acIndex = dashboard.devices.indexWhere((d) => d.id == 'ac1');
      if (acIndex != -1 && dashboard.devices[acIndex].temperature != targetTemp) {
        dashboard.devices[acIndex] = dashboard.devices[acIndex].copyWith(temperature: targetTemp);
      }
    }

    // Relay & PWM pins mapping
    if (state['pins'] != null) {
      final pinsMap = state['pins'] as Map<String, dynamic>;
      _applyPinsMap(dashboard, pinsMap);
    }
  }

  void _syncSensorsWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    if (data['temperature'] != null) {
      dashboard.temperature.value = '${data['temperature']}°';
    }
    if (data['humidity'] != null) {
      dashboard.humidity.value = '${data['humidity']}%';
    }
  }

  void _syncRelayWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    final int? endpoint = data['endpoint'];
    final int? state = data['state'];
    if (endpoint == null || state == null) return;

    // Map Endpoint to Pin
    int pin = 2;
    if (endpoint == 2) {
      pin = 18;
    } else if (endpoint == 3) {
      pin = 19;
    } else if (endpoint == 4) {
      pin = 21;
    }

    for (var i = 0; i < dashboard.devices.length; i++) {
      final device = dashboard.devices[i];
      if (device.pin == pin || (device.id == 'lamp1' && endpoint == 1) || (device.id == 'door1' && endpoint == 2)) {
        if (device.type == DeviceType.door) {
          final bool isLocked = (state == 0);
          if (device.isLocked != isLocked) {
            dashboard.devices[i] = device.copyWith(isLocked: isLocked);
          }
        } else {
          final bool isOn = (state == 1);
          if (device.isOn != isOn) {
            dashboard.devices[i] = device.copyWith(isOn: isOn);
          }
        }
      }
    }
  }

  void _syncPwmWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    final int? endpoint = data['endpoint'];
    final int? level = data['level'];
    if (endpoint == null || level == null) return;

    for (var i = 0; i < dashboard.devices.length; i++) {
      final device = dashboard.devices[i];
      if (endpoint == 5 && device.type == DeviceType.lamp && (device.pin == 22 || device.id == 'lamp1')) {
        final bool isOn = level > 0;
        if (device.brightness != level || device.isOn != isOn) {
          dashboard.devices[i] = device.copyWith(brightness: level, isOn: isOn);
        }
      } else if (endpoint == 6 && device.type == DeviceType.rgb) {
        if (device.brightness != level) {
          dashboard.devices[i] = device.copyWith(brightness: level);
        }
      }
    }
  }

  void _syncAcWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    final bool? isOn = data['isOn'];
    final int? targetTemp = data['target_temp'];
    
    final acIndex = dashboard.devices.indexWhere((d) => d.id == 'ac1');
    if (acIndex != -1) {
      var ac = dashboard.devices[acIndex];
      if (isOn != null) ac = ac.copyWith(isOn: isOn);
      if (targetTemp != null) ac = ac.copyWith(temperature: targetTemp);
      dashboard.devices[acIndex] = ac;
    }
  }

  void _applyPinsMap(DashboardController dashboard, Map<String, dynamic> pinsMap) {
    for (var i = 0; i < dashboard.devices.length; i++) {
      final device = dashboard.devices[i];
      final pin = device.pin;

      if (pin != null) {
        String? label;
        if (pin == 2) {
          label = 'relay_1';
        } else if (pin == 18) {
          label = 'relay_2';
        } else if (pin == 19) {
          label = 'relay_3';
        } else if (pin == 21) {
          label = 'relay_4';
        } else if (pin == 22) {
          label = 'pwm_lamp';
        } else if (pin == 23) {
          label = 'pwm_rgb_r';
        } else if (pin == 25) {
          label = 'pwm_rgb_g';
        } else if (pin == 26) {
          label = 'pwm_rgb_b';
        }

        if (label != null && pinsMap.containsKey(label)) {
          final val = pinsMap[label];
          if (device.type == DeviceType.door) {
            final bool isLocked = (val == 0);
            if (device.isLocked != isLocked) {
              dashboard.devices[i] = device.copyWith(isLocked: isLocked);
            }
          } else if (device.type == DeviceType.lamp && pin == 22) {
            final int brightness = val as int;
            final bool isOn = brightness > 0;
            if (device.brightness != brightness || device.isOn != isOn) {
              dashboard.devices[i] = device.copyWith(brightness: brightness, isOn: isOn);
            }
          } else if (device.type == DeviceType.rgb) {
            final int rVal = pinsMap['pwm_rgb_r'] ?? device.rgbR ?? 0;
            final int gVal = pinsMap['pwm_rgb_g'] ?? device.rgbG ?? 0;
            final int bVal = pinsMap['pwm_rgb_b'] ?? device.rgbB ?? 0;
            if (device.rgbR != rVal || device.rgbG != gVal || device.rgbB != bVal) {
              dashboard.devices[i] = device.copyWith(rgbR: rVal, rgbG: gVal, rgbB: bVal);
            }
          } else {
            if (device.type != DeviceType.airConditioner) {
              final bool isOn = (val == 1);
              if (device.isOn != isOn) {
                dashboard.devices[i] = device.copyWith(isOn: isOn);
              }
            }
          }
        }
      }
    }
  }

  void _handleIrLearnStatus(Map<String, dynamic> data) {
    if (_irLearnCompleter == null || _irLearnCompleter!.isCompleted) return;
    
    final status = data['status'];
    if (status == 'ok') {
      final entity = IrCodeEntity.fromMap(data);
      _irLearnCompleter!.complete(entity);
    } else {
      _irLearnCompleter!.completeError(data['message'] ?? 'Failed to learn IR code');
    }
  }

  /// Send raw map over MQTT
  bool sendRawMessage(Map<String, dynamic> jsonMap) {
    if (_client == null || !isConnected.value) {
      debugPrint('Cannot send MQTT message: not connected');
      return false;
    }
    try {
      debugPrint('--> MQTT SEND [$topicCmd]: $jsonMap');
      final builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(jsonMap));
      _client!.publishMessage(topicCmd, MqttQos.atLeastOnce, builder.payload!);
      return true;
    } catch (e) {
      debugPrint('Error sending MQTT message: $e');
      return false;
    }
  }

  // ─────────────── PUBLIC BACKWARD-COMPATIBLE API ───────────────

  /// Ping ESP32 to test host reachability over MQTT or fallback to Firebase online status
  Future<EspResponse<bool>> pingHub() async {
    if (isConnected.value) return EspResponse.success(true);
    _connectMqtt();
    int wait = 0;
    while (!isConnected.value && wait < 2000) {
      await Future.delayed(const Duration(milliseconds: 100));
      wait += 100;
    }
    if (isConnected.value) return EspResponse.success(true);
    
    // Fallback: check online status from Firebase
    try {
      final statusEvent = await _firebase.deviceStatusStream.first.timeout(const Duration(seconds: 2));
      final status = statusEvent.snapshot.value;
      if (status == 'online') {
        return EspResponse.success(true); // Hub is online via Firebase
      }
    } catch (_) {}
    
    return EspResponse.failure('Unable to establish MQTT connection');
  }

  /// Read real-time sensor metrics
  Future<EspResponse<Map<String, dynamic>>> getSensorData() async {
    if (isConnected.value) {
      _stateCompleter = Completer<Map<String, dynamic>>();
      if (sendRawMessage({'action': 'get_state'})) {
        try {
          final state = await _stateCompleter!.future.timeout(const Duration(seconds: 3));
          return EspResponse.success(state);
        } catch (e) {
          return EspResponse.failure(e.toString());
        }
      }
    }
    return EspResponse.failure('MQTT not connected');
  }

  /// Toggle a digital pin state / relay channel
  Future<EspResponse<bool>> setDigitalOutput(dynamic pin, bool state) async {
    final int pinInt = pin is String ? int.parse(pin) : pin as int;
    
    if (isConnected.value) {
      final success = sendRawMessage({
        'action': 'set_relay',
        'pin': pinInt,
        'value': state ? 1 : 0
      });
      return success ? EspResponse.success(true) : EspResponse.failure('MQTT transmission failed');
    } else {
      // Firebase fallback
      await _firebase.sendCommand({
        'action': 'set_relay',
        'pin': pinInt,
        'value': state ? 1 : 0,
      });
      return EspResponse.success(true);
    }
  }

  /// Write an analog/PWM duty cycle value
  Future<EspResponse<bool>> setAnalogOutput(dynamic pin, int value) async {
    final int pinInt = pin is String ? int.parse(pin) : pin as int;
    
    if (isConnected.value) {
      final success = sendRawMessage({
        'action': 'set_pwm',
        'pin': pinInt,
        'value': value.clamp(0, 255)
      });
      return success ? EspResponse.success(true) : EspResponse.failure('MQTT transmission failed');
    } else {
      // Firebase fallback
      await _firebase.sendCommand({
        'action': 'set_pwm',
        'pin': pinInt,
        'value': value.clamp(0, 255),
      });
      return EspResponse.success(true);
    }
  }

  /// Execute dynamic raw endpoints / payloads
  Future<EspResponse<dynamic>> sendRawCommand(
    String path, {
    String method = 'POST',
    dynamic data,
  }) async {
    if (path == 'control/ac') {
      if (isConnected.value) {
        final success = sendRawMessage({
          'action': 'control_ac',
          'isOn': data['isOn'] == true ? 1 : 0,
          'target_temp': data['target_temp']
        });
        return success ? EspResponse.success({'status': 'ok'}) : EspResponse.failure('MQTT transmission failed');
      } else {
        // Firebase fallback
        await _firebase.sendCommand({
          'action': 'control_ac',
          'isOn': data['isOn'] == true ? 1 : 0,
          'target_temp': data['target_temp']
        });
        return EspResponse.success({'status': 'ok'});
      }
    }
    return EspResponse.failure('Path $path not supported');
  }

  /// Starts IR remote code learning on the ESP32.
  Future<EspResponse<IrCodeEntity>> learnIrCode() async {
    if (isConnected.value) {
      _irLearnCompleter = Completer<IrCodeEntity>();
      if (sendRawMessage({'action': 'ir_learn'})) {
        try {
          final entity = await _irLearnCompleter!.future.timeout(const Duration(seconds: 12));
          return EspResponse.success(entity);
        } catch (e) {
          return EspResponse.failure(e.toString());
        }
      }
      return EspResponse.failure('MQTT not connected');
    } else {
      // Firebase fallback
      final completer = Completer<IrCodeEntity>();
      StreamSubscription? sub;
      sub = _firebase.irSignalStream.listen((event) {
        if (event.snapshot.value != null) {
          try {
            final data = Map<String, dynamic>.from(event.snapshot.value as Map);
            final protocolStr = data['protocol'] ?? 'RAW';
            final lastVal = data['last_value'] ?? '';
            final timestamp = data['timestamp'] ?? 0;
            final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
            if ((nowSec - timestamp).abs() < 15) { // within 15 seconds
              final entity = IrCodeEntity(
                protocol: IrProtocol.values.firstWhere(
                  (p) => p.name.toUpperCase() == protocolStr.toString().toUpperCase(),
                  orElse: () => IrProtocol.raw,
                ),
                value: lastVal.toString(),
                bits: lastVal.toString().split(',').length,
                frequency: 38,
              );
              if (!completer.isCompleted) {
                completer.complete(entity);
                sub?.cancel();
              }
            }
          } catch (e) {
            debugPrint('Error parsing learned IR from Firebase: $e');
          }
        }
      });
      
      await _firebase.sendCommand({'action': 'ir_learn'});
      try {
        final result = await completer.future.timeout(const Duration(seconds: 15));
        return EspResponse.success(result);
      } catch (e) {
        sub.cancel();
        return EspResponse.failure('IR Learning via Firebase timed out: $e');
      }
    }
  }

  /// Sends a recorded IR code via the ESP32 transmitter.
  Future<EspResponse<bool>> sendIrCode(IrCodeEntity irCode) async {
    if (isConnected.value) {
      final success = sendRawMessage({
        'action': 'ir_send',
        'protocol': irCode.protocol.name.toUpperCase(),
        'value': irCode.value,
        'bits': irCode.bits,
        'frequency': irCode.frequency
      });
      return success ? EspResponse.success(true) : EspResponse.failure('MQTT not connected');
    } else {
      // Firebase fallback
      await _firebase.sendCommand({
        'action': 'ir_send',
        'protocol': irCode.protocol.name.toUpperCase(),
        'value': irCode.value,
        'bits': irCode.bits,
        'frequency': irCode.frequency
      });
      return EspResponse.success(true);
    }
  }
}
