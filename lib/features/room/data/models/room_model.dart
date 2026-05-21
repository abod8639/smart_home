import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.name,
    required super.iconCode,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      iconCode: json['iconCode'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCode': iconCode,
    };
  }

  factory RoomModel.fromEntity(RoomEntity entity) {
    return RoomModel(
      id: entity.id,
      name: entity.name,
      iconCode: entity.iconCode,
    );
  }
}
