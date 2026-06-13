part of '../esp32_service.dart';

extension Esp32Api on Esp32Service {
  // ─────────────── PUBLIC BACKWARD-COMPATIBLE API ───────────────

  /// Ping ESP32 to test host reachability over MQTT or fallback to Firebase online status
  Future<EspResponse<bool>> pingHub() async {
    if (isConnected) return EspResponse.success(true);
    _connectMqtt();
    int wait = 0;
    while (!isConnected && wait < 2000) {
      await Future.delayed(const Duration(milliseconds: 100));
      wait += 100;
    }
    if (isConnected) return EspResponse.success(true);
    
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
    if (isConnected) {
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
    
    if (isConnected) {
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
    
    if (isConnected) {
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
      if (isConnected) {
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
    } else if (path == 'control/ac/timer') {
      if (isConnected) {
        final success = sendRawMessage({
          'action': 'set_ac_timer',
          'seconds': data['seconds'],
          'ir_code': data['ir_code']
        });
        return success ? EspResponse.success({'status': 'ok'}) : EspResponse.failure('MQTT transmission failed');
      } else {
        // Firebase fallback
        await _firebase.sendCommand({
          'action': 'set_ac_timer',
          'seconds': data['seconds'],
          'ir_code': data['ir_code']
        });
        return EspResponse.success({'status': 'ok'});
      }
    }
    return EspResponse.failure('Path $path not supported');
  }

  /// Starts IR remote code learning on the ESP32.
  Future<EspResponse<IrCodeEntity>> learnIrCode() async {
    if (isConnected) {
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
    if (isConnected) {
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
}
