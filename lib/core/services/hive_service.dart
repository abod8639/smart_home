import 'package:hive_flutter/hive_flutter.dart';

/// Central Hive initializer and box accessor.
/// Call [HiveService.init()] once before [runApp()].
class HiveService {
  static const String _devicesBoxName = 'devices_box';

  static Box<Map>? _devicesBox;

  /// Opens Hive and all required boxes.
  static Future<void> init() async {
    await Hive.initFlutter();
    _devicesBox = await Hive.openBox<Map>(_devicesBoxName);
  }

  /// The box used to persist device data as [Map] objects.
  static Box<Map> get devicesBox {
    assert(_devicesBox != null, 'HiveService.init() must be called first.');
    return _devicesBox!;
  }
}
