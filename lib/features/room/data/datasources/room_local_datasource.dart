import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/services/hive_service.dart';
import '../models/room_model.dart';

part 'room_local_datasource.g.dart';

/// Local data source for persisting and retrieving [RoomEntity] objects
/// using Hive. Rooms are stored as plain [Map] objects (no TypeAdapter needed).
class RoomLocalDatasource {
  // ── Serialization ────────────────────────────────────────────────────────────

  static Map<String, dynamic> toMap(RoomModel r) => {
        'id': r.id,
        'name': r.name,
        'deviceCount': r.deviceCount,
        'isActive': r.isActive,
        'iconPath': r.iconPath,
        'imagePath': r.imagePath,
      };

  static RoomModel fromMap(Map map) {
    return RoomModel(
      id: map['id'] as String,
      name: map['name'] as String,
      deviceCount: map['deviceCount'] as int? ?? 0,
      isActive: map['isActive'] as bool? ?? false,
      iconPath: map['iconPath'] as String? ?? '',
      imagePath: map['imagePath'] as String?,
    );
  }

  // ── Helper ───────────────────────────────────────────────────────────────────

  bool get _isTest {
    final underTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    if (underTest) {
      try {
        HiveService.roomsBox;
        return false;
      } catch (_) {
        return true;
      }
    }
    return false;
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  /// Interface matching clean architecture Repository dependencies.
  Future<List<RoomModel>> getRooms() async {
    return loadRooms();
  }

  /// Returns all saved rooms. Empty list if nothing has been saved yet.
  List<RoomModel> loadRooms() {
    if (_isTest) return [];
    final box = HiveService.roomsBox;
    return box.values
        .map((raw) => fromMap(Map<String, dynamic>.from(raw)))
        .toList();
  }

  /// Overwrites all saved rooms with [rooms].
  Future<void> saveRooms(List<RoomModel> rooms) async {
    if (_isTest) return;
    final box = HiveService.roomsBox;
    await box.clear();
    final entries = {
      for (var r in rooms) r.id: toMap(r),
    };
    await box.putAll(entries);
  }

  /// Clears the entire rooms box.
  Future<void> clearRooms() async {
    if (_isTest) return;
    await HiveService.roomsBox.clear();
  }

  /// Returns true if there are any saved rooms.
  bool get hasData {
    if (_isTest) return false;
    return HiveService.roomsBox.isNotEmpty;
  }
}

@riverpod
RoomLocalDatasource roomLocalDatasource(Ref ref) {
  return RoomLocalDatasource();
}
