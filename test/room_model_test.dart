import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/room/data/models/room_model.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';

void main() {
  group('RoomModel', () {
    // ── Test fixtures ──────────────────────────────────────────────────────────
    const fullJson = <String, dynamic>{
      'id': 'room-001',
      'name': 'Living Room',
      'deviceCount': 5,
      'isActive': true,
      'iconPath': 'assets/icons/living_room.png',
      'imagePath': 'https://example.com/living_room.jpg',
    };

    const minimalJson = <String, dynamic>{
      'id': 'room-002',
      'name': 'Bedroom',
    };

    // ── fromJson ───────────────────────────────────────────────────────────────
    group('fromJson', () {
      test('parses all fields from full JSON', () {
        final model = RoomModel.fromJson(fullJson);
        expect(model.id, 'room-001');
        expect(model.name, 'Living Room');
        expect(model.deviceCount, 5);
        expect(model.isActive, isTrue);
        expect(model.iconPath, 'assets/icons/living_room.png');
        expect(model.imagePath, 'https://example.com/living_room.jpg');
      });

      test('applies default deviceCount = 0 when missing', () {
        final model = RoomModel.fromJson(minimalJson);
        expect(model.deviceCount, 0);
      });

      test('applies default isActive = false when missing', () {
        final model = RoomModel.fromJson(minimalJson);
        expect(model.isActive, isFalse);
      });

      test('applies default iconPath = empty string when missing', () {
        final model = RoomModel.fromJson(minimalJson);
        expect(model.iconPath, '');
      });

      test('imagePath is null when missing', () {
        final model = RoomModel.fromJson(minimalJson);
        expect(model.imagePath, isNull);
      });

      test('parses isActive = false correctly', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['isActive'] = false;
        final model = RoomModel.fromJson(json);
        expect(model.isActive, isFalse);
      });

      test('parses imagePath as null when explicitly null', () {
        final json = Map<String, dynamic>.from(fullJson);
        json['imagePath'] = null;
        final model = RoomModel.fromJson(json);
        expect(model.imagePath, isNull);
      });

      test('parses large deviceCount', () {
        final json = Map<String, dynamic>.from(fullJson)..['deviceCount'] = 100;
        final model = RoomModel.fromJson(json);
        expect(model.deviceCount, 100);
      });
    });

    // ── toJson ─────────────────────────────────────────────────────────────────
    group('toJson', () {
      test('serializes all fields correctly', () {
        const model = RoomModel(
          id: 'room-001',
          name: 'Living Room',
          deviceCount: 5,
          isActive: true,
          iconPath: 'assets/icons/living_room.png',
          imagePath: 'https://example.com/living_room.jpg',
        );
        final json = model.toJson();
        expect(json['id'], 'room-001');
        expect(json['name'], 'Living Room');
        expect(json['deviceCount'], 5);
        expect(json['isActive'], isTrue);
        expect(json['iconPath'], 'assets/icons/living_room.png');
        expect(json['imagePath'], 'https://example.com/living_room.jpg');
      });

      test('serializes null imagePath correctly', () {
        const model = RoomModel(
          id: 'r1',
          name: 'Kitchen',
          deviceCount: 2,
          isActive: false,
          iconPath: '',
        );
        final json = model.toJson();
        expect(json['imagePath'], isNull);
      });

      test('serializes default values correctly', () {
        const model = RoomModel(
          id: 'r2',
          name: 'Bedroom',
          deviceCount: 0,
          isActive: false,
          iconPath: '',
        );
        final json = model.toJson();
        expect(json['deviceCount'], 0);
        expect(json['isActive'], isFalse);
        expect(json['iconPath'], '');
      });

      test('toJson map has exactly 6 keys', () {
        const model = RoomModel(
          id: 'r3',
          name: 'Bath',
          deviceCount: 1,
          isActive: false,
          iconPath: '',
        );
        final json = model.toJson();
        expect(json.keys.length, 6);
      });
    });

    // ── fromEntity ─────────────────────────────────────────────────────────────
    group('fromEntity', () {
      test('creates RoomModel from RoomEntity', () {
        const entity = RoomEntity(
          id: 'entity-001',
          name: 'Master Bedroom',
          deviceCount: 3,
          isActive: true,
          iconPath: 'assets/bedroom.png',
          imagePath: 'https://example.com/bedroom.jpg',
        );
        final model = RoomModel.fromEntity(entity);
        expect(model.id, 'entity-001');
        expect(model.name, 'Master Bedroom');
        expect(model.deviceCount, 3);
        expect(model.isActive, isTrue);
        expect(model.iconPath, 'assets/bedroom.png');
        expect(model.imagePath, 'https://example.com/bedroom.jpg');
      });

      test('creates RoomModel from minimal RoomEntity', () {
        const entity = RoomEntity(
          id: 'e-002',
          name: 'Office',
          deviceCount: 0,
        );
        final model = RoomModel.fromEntity(entity);
        expect(model.id, 'e-002');
        expect(model.name, 'Office');
        expect(model.deviceCount, 0);
        expect(model.isActive, isFalse);
        expect(model.iconPath, '');
        expect(model.imagePath, isNull);
      });

      test('RoomModel extends RoomEntity', () {
        const entity = RoomEntity(id: 'e1', name: 'Hall', deviceCount: 1);
        final model = RoomModel.fromEntity(entity);
        expect(model, isA<RoomEntity>());
      });
    });

    // ── roundtrip ─────────────────────────────────────────────────────────────
    group('roundtrip', () {
      test('fromJson → toJson produces identical map', () {
        final model = RoomModel.fromJson(fullJson);
        final json = model.toJson();
        expect(json['id'], fullJson['id']);
        expect(json['name'], fullJson['name']);
        expect(json['deviceCount'], fullJson['deviceCount']);
        expect(json['isActive'], fullJson['isActive']);
        expect(json['iconPath'], fullJson['iconPath']);
        expect(json['imagePath'], fullJson['imagePath']);
      });

      test('fromEntity → toJson → fromJson produces equivalent model', () {
        const entity = RoomEntity(
          id: 'r-roundtrip',
          name: 'Roundtrip Room',
          deviceCount: 7,
          isActive: false,
          iconPath: 'path/icon.png',
          imagePath: 'https://example.com/room.png',
        );
        final model = RoomModel.fromEntity(entity);
        final json = model.toJson();
        final restored = RoomModel.fromJson(json);

        expect(restored.id, entity.id);
        expect(restored.name, entity.name);
        expect(restored.deviceCount, entity.deviceCount);
        expect(restored.isActive, entity.isActive);
        expect(restored.iconPath, entity.iconPath);
        expect(restored.imagePath, entity.imagePath);
      });
    });

    // ── Equatable (inherited from RoomEntity) ──────────────────────────────────
    group('equality', () {
      test('two models with same data are equal', () {
        const a = RoomModel(
          id: 'r1', name: 'Room', deviceCount: 2,
          isActive: false, iconPath: '',
        );
        const b = RoomModel(
          id: 'r1', name: 'Room', deviceCount: 2,
          isActive: false, iconPath: '',
        );
        expect(a, equals(b));
      });

      test('models with different id are not equal', () {
        const a = RoomModel(
          id: 'r1', name: 'Room', deviceCount: 2,
          isActive: false, iconPath: '',
        );
        const b = RoomModel(
          id: 'r2', name: 'Room', deviceCount: 2,
          isActive: false, iconPath: '',
        );
        expect(a, isNot(equals(b)));
      });
    });
  });
}
