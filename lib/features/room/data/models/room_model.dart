import '../../domain/entities/room_entity.dart';

/// Data transfer object representing a [RoomEntity] for data serialization.
class RoomModel extends RoomEntity {
  /// Creates a [RoomModel].
  const RoomModel({
    required super.id,
    required super.name,
    required super.deviceCount,
    required super.isActive,
    required super.iconPath,
    super.imagePath,
  });

  /// De-serializes a JSON map into a [RoomModel].
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceCount: json['deviceCount'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      iconPath: json['iconPath'] as String? ?? '',
      imagePath: json['imagePath'] as String?,
    );
  }

  /// Serializes this [RoomModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceCount': deviceCount,
      'isActive': isActive,
      'iconPath': iconPath,
      'imagePath': imagePath,
    };
  }

  /// Creates a [RoomModel] from a base [RoomEntity].
  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      deviceCount: entity.deviceCount,
      isActive: entity.isActive,
      iconPath: entity.iconPath,
      imagePath: entity.imagePath,
    );
  }
}
