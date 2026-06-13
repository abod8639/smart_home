import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/data/models/room_model.dart';

void main() {
  group('RoomEntity Tests', () {
    test('default values are assigned correctly', () {
      const room = RoomEntity(
        id: 'r1',
        name: 'Living Room',
        deviceCount: 5,
      );
      expect(room.id, 'r1');
      expect(room.name, 'Living Room');
      expect(room.deviceCount, 5);
      expect(room.isActive, isFalse);
      expect(room.iconPath, '');
      expect(room.imagePath, isNull);
    });

    test('copyWith updates fields correctly', () {
      const room = RoomEntity(
        id: 'r1',
        name: 'Old Name',
        deviceCount: 3,
        isActive: false,
        iconPath: 'old_icon.png',
      );
      final updated = room.copyWith(
        name: 'New Name',
        isActive: true,
        deviceCount: 7,
      );
      expect(updated.id, 'r1');
      expect(updated.name, 'New Name');
      expect(updated.deviceCount, 7);
      expect(updated.isActive, isTrue);
      expect(updated.iconPath, 'old_icon.png');
    });

    test('copyWith preserves imagePath when not provided', () {
      const room = RoomEntity(
        id: 'r1',
        name: 'Bedroom',
        deviceCount: 2,
        imagePath: 'bedroom.jpg',
      );
      final updated = room.copyWith(name: 'Master Bedroom');
      expect(updated.imagePath, 'bedroom.jpg');
    });

    test('copyWith can update imagePath', () {
      const room = RoomEntity(
        id: 'r1',
        name: 'Room',
        deviceCount: 1,
        imagePath: 'old.jpg',
      );
      final updated = room.copyWith(imagePath: 'new.jpg');
      expect(updated.imagePath, 'new.jpg');
    });

    test('Equatable: identical rooms are equal', () {
      const a = RoomEntity(
        id: 'r1',
        name: 'Bedroom',
        deviceCount: 3,
        isActive: true,
        iconPath: 'icon.png',
        imagePath: 'bg.jpg',
      );
      const b = RoomEntity(
        id: 'r1',
        name: 'Bedroom',
        deviceCount: 3,
        isActive: true,
        iconPath: 'icon.png',
        imagePath: 'bg.jpg',
      );
      expect(a, equals(b));
    });

    test('Equatable: rooms with different ids are not equal', () {
      const a = RoomEntity(id: 'r1', name: 'Bedroom', deviceCount: 3);
      const b = RoomEntity(id: 'r2', name: 'Bedroom', deviceCount: 3);
      expect(a, isNot(equals(b)));
    });

    test('Equatable: rooms with different names are not equal', () {
      const a = RoomEntity(id: 'r1', name: 'Bedroom', deviceCount: 3);
      const b = RoomEntity(id: 'r1', name: 'Kitchen', deviceCount: 3);
      expect(a, isNot(equals(b)));
    });

    test('Equatable: rooms with different deviceCount are not equal', () {
      const a = RoomEntity(id: 'r1', name: 'Bedroom', deviceCount: 3);
      const b = RoomEntity(id: 'r1', name: 'Bedroom', deviceCount: 5);
      expect(a, isNot(equals(b)));
    });
  });

  group('RoomModel Tests', () {
    const testRoomMap = {
      'id': 'r1',
      'name': 'Kitchen',
      'deviceCount': 4,
      'isActive': true,
      'iconPath': 'kitchen_icon.png',
      'imagePath': 'kitchen_bg.jpg',
    };

    test('fromJson parses all fields correctly', () {
      final model = RoomModel.fromJson(testRoomMap);
      expect(model.id, 'r1');
      expect(model.name, 'Kitchen');
      expect(model.deviceCount, 4);
      expect(model.isActive, isTrue);
      expect(model.iconPath, 'kitchen_icon.png');
      expect(model.imagePath, 'kitchen_bg.jpg');
    });

    test('fromJson handles null imagePath', () {
      final map = Map<String, dynamic>.from(testRoomMap);
      map['imagePath'] = null;
      final model = RoomModel.fromJson(map);
      expect(model.imagePath, isNull);
    });

    test('toJson serializes all fields correctly', () {
      final model = RoomModel.fromJson(testRoomMap);
      final json = model.toJson();
      expect(json['id'], 'r1');
      expect(json['name'], 'Kitchen');
      expect(json['deviceCount'], 4);
      expect(json['isActive'], isTrue);
      expect(json['iconPath'], 'kitchen_icon.png');
      expect(json['imagePath'], 'kitchen_bg.jpg');
    });

    test('toJson → fromJson round-trip preserves all fields', () {
      final original = RoomModel.fromJson(testRoomMap);
      final json = original.toJson();
      final restored = RoomModel.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.deviceCount, original.deviceCount);
      expect(restored.isActive, original.isActive);
      expect(restored.iconPath, original.iconPath);
      expect(restored.imagePath, original.imagePath);
    });

    test('fromEntity creates RoomModel from RoomEntity', () {
      const entity = RoomEntity(
        id: 'r99',
        name: 'Garage',
        deviceCount: 2,
        isActive: false,
        iconPath: 'garage.png',
        imagePath: 'garage_bg.jpg',
      );
      final model = RoomModel.fromEntity(entity);
      expect(model.id, 'r99');
      expect(model.name, 'Garage');
      expect(model.deviceCount, 2);
      expect(model.isActive, isFalse);
      expect(model.iconPath, 'garage.png');
      expect(model.imagePath, 'garage_bg.jpg');
    });

    test('RoomModel is a RoomEntity (inheritance)', () {
      final model = RoomModel.fromJson(testRoomMap);
      expect(model, isA<RoomEntity>());
    });
  });
}
