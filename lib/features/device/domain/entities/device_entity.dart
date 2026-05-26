import 'package:equatable/equatable.dart';

enum DeviceType { vacuum, airConditioner, lamp, door }

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  
  // Vacuum specifics
  final int? batteryLevel;
  final int? areaCleaned;
  final int? cleaningTime;
  final int? filterStatus;
  final String? nextCleaning;

  // AC specifics
  final int? temperature;
  final String? mode;
  final int? coolingTime;

  // Lamp specifics
  final int? brightness;

  // Door specifics
  final bool? isLocked;

  // Linked devices count
  final int? linkedDevicesCount;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.batteryLevel,
    this.areaCleaned,
    this.cleaningTime,
    this.filterStatus,
    this.nextCleaning,
    this.temperature,
    this.mode,
    this.coolingTime,
    this.brightness,
    this.isLocked,
    this.linkedDevicesCount,
  });

  DeviceEntity copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOn,
    int? batteryLevel,
    int? areaCleaned,
    int? cleaningTime,
    int? filterStatus,
    String? nextCleaning,
    int? temperature,
    String? mode,
    int? coolingTime,
    int? brightness,
    bool? isLocked,
    int? linkedDevicesCount,
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      areaCleaned: areaCleaned ?? this.areaCleaned,
      cleaningTime: cleaningTime ?? this.cleaningTime,
      filterStatus: filterStatus ?? this.filterStatus,
      nextCleaning: nextCleaning ?? this.nextCleaning,
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      coolingTime: coolingTime ?? this.coolingTime,
      brightness: brightness ?? this.brightness,
      isLocked: isLocked ?? this.isLocked,
      linkedDevicesCount: linkedDevicesCount ?? this.linkedDevicesCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isOn,
        batteryLevel,
        areaCleaned,
        cleaningTime,
        filterStatus,
        nextCleaning,
        temperature,
        mode,
        coolingTime,
        brightness,
        isLocked,
        linkedDevicesCount,
      ];
}
