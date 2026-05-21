import 'package:equatable/equatable.dart';

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final String type; // e.g., 'light', 'ac', 'tv'
  final String room; // e.g., 'Living Room'
  final bool isOn;
  final bool isLoading; // For UI visual feedback (optimistic update/wait)

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.room,
    required this.isOn,
    this.isLoading = false,
  });

  DeviceEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? room,
    bool? isOn,
    bool? isLoading,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      room: room ?? this.room,
      isOn: isOn ?? this.isOn,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [id, name, type, room, isOn, isLoading];
}
