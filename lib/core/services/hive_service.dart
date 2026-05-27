import 'package:hive_flutter/hive_flutter.dart';

/// Central Hive initializer and box accessor.
/// Call [HiveService.init()] once before [runApp()].
class HiveService {
  static const String _devicesBoxName = 'devices_box';
  static const String _roomsBoxName = 'rooms_box';

  static Box<Map>? _devicesBox;
  static Box<Map>? _roomsBox;

  /// Opens Hive and all required boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    _devicesBox = await Hive.openBox<Map>(_devicesBoxName);
    _roomsBox = await Hive.openBox<Map>(_roomsBoxName);
  }

  /// The box used to persist device data as [Map] objects.
  static Box<Map> get devicesBox {
    assert(_devicesBox != null, 'HiveService.init() must be called first.');
    return _devicesBox!;
  }

  /// The box used to persist room data as [Map] objects.
  static Box<Map> get roomsBox {
    assert(_roomsBox != null, 'HiveService.init() must be called first.');
    return _roomsBox!;
  }
}
