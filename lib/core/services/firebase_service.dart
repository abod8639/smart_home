import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class FirebaseService extends GetxService {
  FirebaseDatabase? get _db => Firebase.apps.isNotEmpty
      ? FirebaseDatabase.instance
      : null;
  
  // Hardcoded device ID for demonstration; in a real app, this should be selected dynamically.
  final String _deviceId = 'esp32_smart_home_1';

  /// Stream of the latest IR Signal
  Stream<DatabaseEvent> get irSignalStream => _db != null
      ? _db!.ref('devices/$_deviceId/ir_signal').onValue
      : const Stream.empty();

  /// Stream of the device's online status
  Stream<DatabaseEvent> get deviceStatusStream => _db != null
      ? _db!.ref('devices/$_deviceId/status').onValue
      : const Stream.empty();

  /// Stream of temperature sensor
  Stream<DatabaseEvent> get temperatureStream => _db != null
      ? _db!.ref('devices/$_deviceId/temperature').onValue
      : const Stream.empty();

  /// Stream of humidity sensor
  Stream<DatabaseEvent> get humidityStream => _db != null
      ? _db!.ref('devices/$_deviceId/humidity').onValue
      : const Stream.empty();

  /// Stream of target AC temperature
  Stream<DatabaseEvent> get targetTempStream => _db != null
      ? _db!.ref('devices/$_deviceId/target_temperature').onValue
      : const Stream.empty();

  /// Stream of output pin states (relays, PWM, etc.)
  Stream<DatabaseEvent> get pinsStream => _db != null
      ? _db!.ref('devices/$_deviceId/pins').onValue
      : const Stream.empty();

  /// Send a command to the ESP32 via Firebase RTDB
  Future<void> sendCommand(Map<String, dynamic> command) async {
    if (_db == null) {
      if (kDebugMode) {
        print('Firebase not initialized. Cannot send command.');
      }
      return;
    }
    try {
      final ref = _db!.ref('devices/$_deviceId/commands');
      await ref.set({
        ...command,
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      if (kDebugMode) {
        print('Command sent via Firebase: $command');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send command via Firebase: $e');
      }
    }
  }

  /// Send an IR command to the ESP32 via Firebase RTDB
  Future<void> sendIrCommand(String protocol, String value) async {
    await sendCommand({
      'action': 'send_ir',
      'protocol': protocol,
      'value': value,
    });
  }
}
