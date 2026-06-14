import 'package:equatable/equatable.dart';

/// Represents a room in the smart home system.
class RoomEntity extends Equatable {
  /// The unique identifier of the room.
  final String id;

  /// The user-facing name of the room.
  final String name;

  /// The number of devices assigned to this room.
  final int deviceCount;

  /// Whether this room is currently selected as the active room on the dashboard.
  final bool isActive;

  /// Path to the icon representing this room.
  final String iconPath;

  /// Optional path to an image representing the room layout.
  final String? imagePath;

  /// Creates a [RoomEntity].
  const RoomEntity({
    required this.id,
    required this.name,
    required this.deviceCount,
    this.isActive = false,
    this.iconPath = '',
    this.imagePath,
  });

  /// Creates a copy of this room with the given fields replaced by new values.
  RoomEntity copyWith({
    String? id,
    String? name,
    int? deviceCount,
    bool? isActive,
    String? iconPath,
    String? imagePath,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      deviceCount: deviceCount ?? this.deviceCount,
      isActive: isActive ?? this.isActive,
      iconPath: iconPath ?? this.iconPath,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [id, name, deviceCount, isActive, iconPath, imagePath];
}
