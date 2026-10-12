import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity Tests', () {
    test('instantiates with expected properties', () {
      const user = UserEntity(
        id: 'u123',
        email: 'user@example.com',
        displayName: 'John Doe',
        photoUrl: 'https://example.com/avatar.png',
      );

      expect(user.id, 'u123');
      expect(user.email, 'user@example.com');
      expect(user.displayName, 'John Doe');
      expect(user.photoUrl, 'https://example.com/avatar.png');
    });

    test('supports value equality', () {
      const user1 = UserEntity(
        id: 'u1',
        email: 'test@example.com',
        displayName: 'Test',
      );
      const user2 = UserEntity(
        id: 'u1',
        email: 'test@example.com',
        displayName: 'Test',
      );

      expect(user1, equals(user2));
    });

    test('copyWith updates specified fields only', () {
      const user = UserEntity(
        id: 'u1',
        email: 'old@example.com',
        displayName: 'Old Name',
      );

      final updated = user.copyWith(
        email: 'new@example.com',
        displayName: 'New Name',
        photoUrl: 'https://newphoto.com',
      );

      expect(updated.id, 'u1');
      expect(updated.email, 'new@example.com');
      expect(updated.displayName, 'New Name');
      expect(updated.photoUrl, 'https://newphoto.com');
    });
  });
}
