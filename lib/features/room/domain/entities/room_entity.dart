import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final int deviceCount;
  final bool isActive;
  final String iconPath; // For simple icon representation if needed
  final String? imagePath;

  const RoomEntity({
    required this.id,
    required this.name,
    required this.deviceCount,
    this.isActive = false,
    this.iconPath = '',
    this.imagePath,
  });

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
