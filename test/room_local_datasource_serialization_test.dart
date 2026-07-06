import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/room/data/datasources/room_local_datasource.dart';
import 'package:smart_home/features/room/data/models/room_model.dart';

void main() {
  group('RoomLocalDatasource - Serialization', () {
    // ── Test fixtures ──────────────────────────────────────────────────────────
    const fullModel = RoomModel(
      id: 'room-001',
      name: 'Living Room',
      deviceCount: 5,
      isActive: true,
      iconPath: 'assets/icons/living_room.png',
      imagePath: 'https://example.com/lr.jpg',
    );

    const minimalModel = RoomModel(
      id: 'room-002',
      name: 'Bedroom',
      deviceCount: 0,
      isActive: false,
      iconPath: '',
    );

    // ── toMap ─────────────────────────────────────────────────────────────────
    group('toMap (static)', () {
      test('serializes all fields from full model', () {
        final map = RoomLocalDatasource.toMap(fullModel);
        expect(map['id'], 'room-001');
        expect(map['name'], 'Living Room');
        expect(map['deviceCount'], 5);
        expect(map['isActive'], isTrue);
        expect(map['iconPath'], 'assets/icons/living_room.png');
        expect(map['imagePath'], 'https://example.com/lr.jpg');
      });

      test('serializes null imagePath correctly', () {
        final map = RoomLocalDatasource.toMap(minimalModel);
        expect(map['imagePath'], isNull);
      });

      test('serializes isActive = false correctly', () {
        final map = RoomLocalDatasource.toMap(minimalModel);
        expect(map['isActive'], isFalse);
      });

      test('serializes deviceCount = 0 correctly', () {
        final map = RoomLocalDatasource.toMap(minimalModel);
        expect(map['deviceCount'], 0);
      });

      test('serializes empty iconPath correctly', () {
        final map = RoomLocalDatasource.toMap(minimalModel);
        expect(map['iconPath'], '');
      });

      test('map contains exactly 6 keys', () {
        final map = RoomLocalDatasource.toMap(fullModel);
        expect(map.keys.length, 6);
        expect(map.containsKey('id'), isTrue);
        expect(map.containsKey('name'), isTrue);
        expect(map.containsKey('deviceCount'), isTrue);
        expect(map.containsKey('isActive'), isTrue);
        expect(map.containsKey('iconPath'), isTrue);
        expect(map.containsKey('imagePath'), isTrue);
      });

      test('id in map matches model id', () {
        final map = RoomLocalDatasource.toMap(fullModel);
        expect(map['id'], fullModel.id);
      });
    });

    // ── fromMap ───────────────────────────────────────────────────────────────
    group('fromMap (static)', () {
      test('restores all fields from full map', () {
        final map = <String, dynamic>{
          'id': 'room-001',
          'name': 'Living Room',
          'deviceCount': 5,
          'isActive': true,
          'iconPath': 'assets/icons/living_room.png',
          'imagePath': 'https://example.com/lr.jpg',
        };
        final model = RoomLocalDatasource.fromMap(map);
        expect(model.id, 'room-001');
        expect(model.name, 'Living Room');
        expect(model.deviceCount, 5);
        expect(model.isActive, isTrue);
        expect(model.iconPath, 'assets/icons/living_room.png');
        expect(model.imagePath, 'https://example.com/lr.jpg');
      });

      test('defaults deviceCount to 0 when missing', () {
        final map = <String, dynamic>{
          'id': 'r1', 'name': 'Bath',
        };
        final model = RoomLocalDatasource.fromMap(map);
        expect(model.deviceCount, 0);
      });

      test('defaults isActive to false when missing', () {
        final map = <String, dynamic>{
          'id': 'r1', 'name': 'Bath',
        };
        final model = RoomLocalDatasource.fromMap(map);
        expect(model.isActive, isFalse);
      });

      test('defaults iconPath to empty string when missing', () {
        final map = <String, dynamic>{
          'id': 'r1', 'name': 'Bath',
        };
        final model = RoomLocalDatasource.fromMap(map);
        expect(model.iconPath, '');
      });

      test('imagePath is null when missing from map', () {
        final map = <String, dynamic>{
          'id': 'r1', 'name': 'Bath',
        };
        final model = RoomLocalDatasource.fromMap(map);
        expect(model.imagePath, isNull);
      });

      test('returns a RoomModel instance', () {
        final map = <String, dynamic>{'id': 'r1', 'name': 'R'};
        final result = RoomLocalDatasource.fromMap(map);
        expect(result, isA<RoomModel>());
      });
    });

    // ── toMap → fromMap roundtrip ─────────────────────────────────────────────
    group('roundtrip (toMap → fromMap)', () {
      test('full model roundtrip preserves all fields', () {
        final map = RoomLocalDatasource.toMap(fullModel);
        final restored = RoomLocalDatasource.fromMap(map);
        expect(restored.id, fullModel.id);
        expect(restored.name, fullModel.name);
        expect(restored.deviceCount, fullModel.deviceCount);
        expect(restored.isActive, fullModel.isActive);
        expect(restored.iconPath, fullModel.iconPath);
        expect(restored.imagePath, fullModel.imagePath);
      });

      test('minimal model roundtrip preserves all fields', () {
        final map = RoomLocalDatasource.toMap(minimalModel);
        final restored = RoomLocalDatasource.fromMap(map);
        expect(restored.id, minimalModel.id);
        expect(restored.name, minimalModel.name);
        expect(restored.deviceCount, 0);
        expect(restored.isActive, isFalse);
        expect(restored.iconPath, '');
        expect(restored.imagePath, isNull);
      });

      test('multiple models roundtrip independently', () {
        final rooms = [fullModel, minimalModel];
        for (final original in rooms) {
          final restored = RoomLocalDatasource.fromMap(RoomLocalDatasource.toMap(original));
          expect(restored.id, original.id);
          expect(restored.name, original.name);
        }
      });

      test('restored model equality matches original', () {
        final map = RoomLocalDatasource.toMap(fullModel);
        final restored = RoomLocalDatasource.fromMap(map);
        expect(restored, equals(fullModel));
      });

      test('kitchen room roundtrip', () {
        const kitchen = RoomModel(
          id: 'kitchen-1',
          name: 'Kitchen',
          deviceCount: 3,
          isActive: false,
          iconPath: 'assets/kitchen.png',
          imagePath: 'https://example.com/kitchen.jpg',
        );
        final restored = RoomLocalDatasource.fromMap(RoomLocalDatasource.toMap(kitchen));
        expect(restored.name, 'Kitchen');
        expect(restored.deviceCount, 3);
        expect(restored.imagePath, 'https://example.com/kitchen.jpg');
      });
    });
  });
}
