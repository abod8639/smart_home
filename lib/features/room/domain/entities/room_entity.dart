import 'package:equatable/equatable.dart';

class RoomEntity extends Equatable {
  final String id;
  final String name;
  final int iconCode; // Store icon codepoint to easily save in JSON

  const RoomEntity({
    required this.id,
    required this.name,
    required this.iconCode,
  });

  @override
  List<Object?> get props => [id, name, iconCode];
}
