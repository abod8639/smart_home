import 'package:smart_home/features/device/data/models/device_model.dart';

void main() {
  final Map<dynamic, dynamic> value = {
    "device_1": {
      "id": "device_1",
      "name": "Living Room AC",
      "type": "ac", 
      "isOn": true
    }
  };

  try {
    final list = [];
    final sortedKeys = value.keys.toList()..sort((a, b) => a.toString().compareTo(b.toString()));
    for (final key in sortedKeys) {
      final val = value[key];
      if (val is Map) {
        list.add(Map<String, dynamic>.from(val));
      }
    }
    
    print('List size: ${list.length}');
    final entities = list.map((json) => DeviceModel.fromJson(json).toEntity()).toList();
    print('Entities size: ${entities.length}');
    print('Success');
  } catch (e, st) {
    print('Error: $e\n$st');
  }
}
