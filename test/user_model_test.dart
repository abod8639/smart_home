import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/auth/data/models/user_model.dart';
import 'package:smart_home/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserModel Tests', () {
    test('is a subtype of UserEntity', () {
      const model = UserModel(id: '1', email: 'test@test.com');
      expect(model, isA<UserEntity>());
    });

    test('serializes to and deserializes from JSON', () {
      const model = UserModel(
        id: 'u456',
        email: 'alex@smart.home',
        displayName: 'Alex',
        photoUrl: 'https://smart.home/alex.png',
      );

      final json = model.toJson();
      expect(json['id'], 'u456');
      expect(json['email'], 'alex@smart.home');
      expect(json['displayName'], 'Alex');
      expect(json['photoUrl'], 'https://smart.home/alex.png');

      final fromJson = UserModel.fromJson(json);
      expect(fromJson, equals(model));
    });

    test('creates from Entity correctly', () {
      const entity = UserEntity(
        id: 'ent1',
        email: 'entity@test.com',
        displayName: 'Entity User',
        photoUrl: 'https://pic.jpg',
      );

      final model = UserModel.fromEntity(entity);
      expect(model.id, entity.id);
      expect(model.email, entity.email);
      expect(model.displayName, entity.displayName);
      expect(model.photoUrl, entity.photoUrl);
    });
  });
}
