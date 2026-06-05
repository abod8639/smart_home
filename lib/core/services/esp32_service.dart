import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
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

/// Professional and flexible control service for ESP32 microcontrollers using WebSockets
class Esp32Service extends GetxService {
  WebSocketChannel? _channel;
  final isConnected = false.obs;
  
  Completer<IrCodeEntity>? _irLearnCompleter;
  Completer<Map<String, dynamic>>? _stateCompleter;
  
  // Retrieves SettingsController which holds the current reactive IP Address
  SettingsController get _settings => Get.find<SettingsController>();

  // Base WebSocket URL computed dynamically from settings IP
  String get wsUrl => 'ws://${_settings.ipAddress.value}/ws';

  // Retrieves FirebaseService for external network fallback
  FirebaseService get _firebase => Get.find<FirebaseService>();

  // Subscription list for cleaning up Firebase listeners if needed
  final List<StreamSubscription> _firebaseSubscriptions = [];

  @override
  void onInit() { 
    super.onInit();
    
    // Initialize WebSocket connection
    _connectWebSocket();
    
    // Auto-reconnect if the IP address configuration changes
    ever(_settings.ipAddress, (_) {
      debugPrint('ESP32 IP changed, reconnecting to WebSocket...');
      _reconnect();
    });

    // Start listening to Firebase states to sync UI when WebSocket is disconnected
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
    _closeWebSocket();
    for (var sub in _firebaseSubscriptions) {
      sub.cancel();
    }
    super.onClose();
  }


  void _connectWebSocket() {
    _closeWebSocket();
    debugPrint('Connecting to ESP32 WebSocket at: $wsUrl');
    try {
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (message) {
          isConnected.value = true;
          _handleMessage(message);
        },
        onError: (err) {
          debugPrint('ESP32 WebSocket Error: $err');
          isConnected.value = false;
          _reconnectAfterDelay();
        },
        onDone: () {
          debugPrint('ESP32 WebSocket Connection closed by server');
          isConnected.value = false;
          _reconnectAfterDelay();
        },
      );
    } catch (e) {
      debugPrint('ESP32 WebSocket connection exception: $e');
      isConnected.value = false;
      _reconnectAfterDelay();
    }
  }

  void _closeWebSocket() {
    try {
      _channel?.sink.close();
    } catch (_) {}
    _channel = null;
  }

  bool _reconnecting = false;
  void _reconnectAfterDelay() {
    if (_reconnecting) return;
    _reconnecting = true;
    Future.delayed(const Duration(seconds: 3), () {
      _reconnecting = false;
      _connectWebSocket();
    });
  }

  void _reconnect() {
    _closeWebSocket();
    _connectWebSocket();
  }

  void _handleMessage(dynamic message) {
    debugPrint('<-- ESP32 WS MESSAGE: $message');
    try {
      final data = jsonDecode(message.toString()) as Map<String, dynamic>;
      
      // Handshake
      if (data['status'] == 'connected') {
        debugPrint('ESP32 WS handshake success, requesting full state...');
        isConnected.value = true;
        sendRawMessage({'action': 'get_state'});
        return;
      }

      // Handle server-to-client events
      final String? event = data['event'];
      if (event == null) return;

      if (event == 'state') {
        if (_stateCompleter != null && !_stateCompleter!.isCompleted) {
          _stateCompleter!.complete(data);
        }
        _syncStateWithControllers(data);
      } else if (event == 'sensor_data') {
        _syncSensorsWithControllers(data);
      } else if (event == 'relay_update') {
        _syncRelayWithControllers(data);
      } else if (event == 'pwm_update') {
        _syncPwmWithControllers(data);
      } else if (event == 'ac_update') {
        _syncAcWithControllers(data);
      } else if (event == 'ir_learn_status') {
        _handleIrLearnStatus(data);
      }
    } catch (e) {
      debugPrint('Error decoding WS message: $e');
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

  /// Send raw map over WebSocket
  bool sendRawMessage(Map<String, dynamic> jsonMap) {
    if (_channel == null || !isConnected.value) {
      debugPrint('Cannot send WebSocket message: not connected');
      return false;
    }
    try {
      debugPrint('--> ESP32 WS SEND: $jsonMap');
      _channel!.sink.add(jsonEncode(jsonMap));
      return true;
    } catch (e) {
      debugPrint('Error sending WebSocket message: $e');
      return false;
    }
  }

  // ─────────────── PUBLIC BACKWARD-COMPATIBLE API ───────────────

  /// Ping ESP32 to test host reachability over WebSockets or fallback to Firebase online status
  Future<EspResponse<bool>> pingHub() async {
    if (isConnected.value) return EspResponse.success(true);
    _connectWebSocket();
    int wait = 0;
    while (!isConnected.value && wait < 1500) {
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
    
    return EspResponse.failure('Unable to establish WebSocket connection');
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
    return EspResponse.failure('WebSocket not connected');
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
      return success ? EspResponse.success(true) : EspResponse.failure('WebSocket transmission failed');
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
      return success ? EspResponse.success(true) : EspResponse.failure('WebSocket transmission failed');
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
        return success ? EspResponse.success({'status': 'ok'}) : EspResponse.failure('WebSocket transmission failed');
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
      return EspResponse.failure('WebSocket not connected');
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
        sub?.cancel();
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
      return success ? EspResponse.success(true) : EspResponse.failure('WebSocket not connected');
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
