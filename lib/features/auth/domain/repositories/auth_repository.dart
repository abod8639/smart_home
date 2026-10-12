import '../entities/user_entity.dart';

/// Repository interface contract for authentication operations.
abstract class AuthRepository {
  /// Emits the current [UserEntity] whenever the authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Performs Google Sign-In and returns the authenticated [UserEntity] on success.
  Future<UserEntity?> signInWithGoogle();

  /// Signs out the currently authenticated user.
  Future<void> signOut();

  /// Returns the currently authenticated [UserEntity], or `null` if unauthenticated.
  UserEntity? get currentUser;
}
