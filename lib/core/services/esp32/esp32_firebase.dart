part of '../esp32_service.dart';

extension Esp32Firebase on Esp32Service {
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
}
