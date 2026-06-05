import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

class FirebaseService extends GetxService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  
  // Hardcoded device ID for demonstration; in a real app, this should be selected dynamically.
  final String _deviceId = 'esp32_smart_home_1';

  /// Stream of the latest IR Signal
  Stream<DatabaseEvent> get irSignalStream =>
      _db.ref('devices/$_deviceId/ir_signal').onValue;

  /// Stream of the device's online status
  Stream<DatabaseEvent> get deviceStatusStream =>
      _db.ref('devices/$_deviceId/status').onValue;

  /// Send an IR command to the ESP32 via Firebase RTDB
  Future<void> sendIrCommand(String protocol, String value) async {
    try {
      final ref = _db.ref('devices/$_deviceId/commands');
      await ref.set({
        'action': 'send_ir',
        'protocol': protocol,
        'value': value, // Can be "0xFFE01F" or raw CSV string "9000,4500,560..."
        'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      if (kDebugMode) {
        print('IR Command sent via Firebase: $protocol, $value');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send IR Command via Firebase: $e');
      }
    }
  }
}
