import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    required super.deviceCount,
    required super.isActive,
    required super.iconPath,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      deviceCount: json['deviceCount'] as int,
      isActive: json['isActive'] as bool,
      iconPath: json['iconPath'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'deviceCount': deviceCount,
      'isActive': isActive,
      'iconPath': iconPath,
    };
  }

  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      deviceCount: entity.deviceCount,
      isActive: entity.isActive,
      iconPath: entity.iconPath,
    );
  }
}
