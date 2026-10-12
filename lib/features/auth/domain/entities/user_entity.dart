import 'package:equatable/equatable.dart';

/// Represents an authenticated user in the smart home system.
class UserEntity extends Equatable {
  /// The unique identifier of the user (e.g. Firebase UID).
  final String id;

  /// The user's primary email address.
  final String? email;

  /// The user's display name.
  final String? displayName;

  /// Optional URL pointing to the user's avatar image.
  final String? photoUrl;

  /// Creates a [UserEntity].
  const UserEntity({
    required this.id,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  /// Creates a copy of this entity with the specified fields replaced.
  UserEntity copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, displayName, photoUrl];
}
