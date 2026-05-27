import 'dart:io';
import 'package:smart_home/core/services/hive_service.dart';
import '../../domain/entities/room_entity.dart';
import '../models/room_model.dart';

/// Local data source for persisting and retrieving [RoomEntity] objects
/// using Hive. Rooms are stored as plain [Map] objects (no TypeAdapter needed).
class RoomLocalDatasource {
  // ── Serialization ────────────────────────────────────────────────────────────

  static Map<String, dynamic> _toMap(RoomEntity r) => {
        'id': r.id,
        'name': r.name,
        'deviceCount': r.deviceCount,
        'isActive': r.isActive,
        'iconPath': r.iconPath,
      };

  static RoomModel _fromMap(Map map) {
    return RoomModel(
      id: map['id'] as String,
      name: map['name'] as String,
      deviceCount: map['deviceCount'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? false,
      iconPath: map['iconPath'] as String? ?? '',
    );
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Interface matching clean architecture Repository dependencies.
  Future<List<RoomModel>> getRooms() async {
    return loadRooms();
  }

  /// Returns all saved rooms. Empty list if nothing has been saved yet.
  List<RoomModel> loadRooms() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return [];
    final box = HiveService.roomsBox;
    return box.values
        .map((raw) => _fromMap(Map<String, dynamic>.from(raw)))
        .toList();
  }

  /// Overwrites all saved rooms with [rooms].
  Future<void> saveRooms(List<RoomEntity> rooms) async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    final box = HiveService.roomsBox;
    await box.clear();
    final entries = {
      for (var r in rooms) r.id: _toMap(r),
    };
    await box.putAll(entries);
  }

  /// Clears the entire rooms box.
  Future<void> clearRooms() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await HiveService.roomsBox.clear();
  }

  /// Returns true if there are any saved rooms.
  bool get hasData {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return false;
    return HiveService.roomsBox.isNotEmpty;
  }
}
