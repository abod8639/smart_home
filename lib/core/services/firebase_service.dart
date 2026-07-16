import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_service.g.dart';

@Riverpod(keepAlive: true)
class FirebaseService extends _$FirebaseService {
  @override
  void build() {}
  FirebaseDatabase? get _db {
    if (Firebase.apps.isEmpty) return null;
    
    final dbUrl = dotenv.env['FIREBASE_DATABASE_URL'];
    return FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: dbUrl,
    );
  }
  
  // Hardcoded device ID for demonstration; in a real app, this should be selected dynamically.
  final String _deviceId = 'esp32_smart_home_1';

  String get _userPath {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null ? 'users/$uid' : 'app_data';
  }

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

  /// Stream of Matter Setup Payload
  Stream<DatabaseEvent> get matterPayloadStream => _db != null
      ? _db!.ref('devices/$_deviceId/matter_payload').onValue
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
  /// Save an IR code configuration to Firebase
  Future<void> saveIrCode(String deviceId, String fieldKey, String jsonCode) async {
    if (_db == null) return;
    try {
      final ref = _db!.ref('$_userPath/ir_codes/$deviceId/$fieldKey');
      await ref.set(jsonCode);
      if (kDebugMode) {
        print('IR code saved to Firebase for $deviceId -> $fieldKey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save IR code to Firebase: $e');
      }
    }
  }

  /// Delete an IR code configuration from Firebase
  Future<void> deleteIrCode(String deviceId, String fieldKey) async {
    if (_db == null) return;
    try {
      final ref = _db!.ref('$_userPath/ir_codes/$deviceId/$fieldKey');
      await ref.remove();
      if (kDebugMode) {
        print('IR code deleted from Firebase for $deviceId -> $fieldKey');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete IR code from Firebase: $e');
      }
    }
  }

  /// Fetch all IR codes from Firebase for a specific device
  Future<Map<String, String>> fetchIrCodes(String deviceId) async {
    if (_db == null) return {};
    try {
      final snapshot = await _db!.ref('$_userPath/ir_codes/$deviceId').get();
      if (snapshot.exists && snapshot.value != null) {
        final Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
        return data.map((key, value) => MapEntry(key.toString(), value.toString()));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch IR codes from Firebase: $e');
      }
    }
    return {};
  }

  /// Stream of devices from Firebase RTDB
  Stream<List<Map<String, dynamic>>> get devicesStream => _db != null
      ? _db!.ref('$_userPath/devices').onValue.map((event) => _parseFirebaseList(event.snapshot.value))
      : const Stream.empty();

  /// Stream of rooms from Firebase RTDB
  Stream<List<Map<String, dynamic>>> get roomsStream => _db != null
      ? _db!.ref('$_userPath/rooms').onValue.map((event) => _parseFirebaseList(event.snapshot.value))
      : const Stream.empty();

  /// Fetch rooms list from Firebase RTDB once
  Future<List<Map<String, dynamic>>?> fetchRooms() async {
    if (_db == null) return null;
    try {
      final snapshot = await _db!.ref('$_userPath/rooms').get();
      if (snapshot.exists && snapshot.value != null) {
        return _parseFirebaseList(snapshot.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch rooms from Firebase: $e');
      }
    }
    return null;
  }

  /// Fetch devices list from Firebase RTDB once
  Future<List<Map<String, dynamic>>?> fetchDevices() async {
    if (_db == null) return null;
    try {
      final snapshot = await _db!.ref('$_userPath/devices').get();
      if (snapshot.exists && snapshot.value != null) {
        return _parseFirebaseList(snapshot.value);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch devices from Firebase: $e');
      }
    }
    return null;
  }

  List<Map<String, dynamic>> _parseFirebaseList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
    } else if (value is Map) {
      final List<Map<String, dynamic>> list = [];
      final sortedKeys = value.keys.toList()..sort((a, b) => a.toString().compareTo(b.toString()));
      for (final key in sortedKeys) {
        final val = value[key];
        if (val is Map) {
          list.add(Map<String, dynamic>.from(val));
        }
      }
      return list;
    }
    return [];
  }

  /// Sync rooms list to Firebase RTDB
  Future<void> syncRooms(List<Map<String, dynamic>> roomsJson) async {
    if (_db == null) return;
    try {
      final ref = _db!.ref('$_userPath/rooms');
      await ref.set(roomsJson);
      if (kDebugMode) {
        print('Rooms successfully synced to Firebase RTDB');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync rooms to Firebase: $e');
      }
    }
  }

  /// Sync devices list to Firebase RTDB
  Future<void> syncDevices(List<Map<String, dynamic>> devicesJson) async {
    if (_db == null) return;
    try {
      final ref = _db!.ref('$_userPath/devices');
      await ref.set(devicesJson);
      if (kDebugMode) {
        print('Devices successfully synced to Firebase RTDB');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync devices to Firebase: $e');
      }
    }
  }
}
