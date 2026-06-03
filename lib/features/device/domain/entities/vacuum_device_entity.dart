import 'device_entity.dart';

class VacuumDeviceEntity extends DeviceEntity {
  final int? batteryLevel;
  final int? areaCleaned;
  final int? cleaningTime;
  final int? filterStatus;
  final String? nextCleaning;

  const VacuumDeviceEntity({
    required super.id,
    required super.name,
    super.isOn,
    super.roomId,
    super.positionX,
    super.positionY,
    super.markerWidth,
    super.markerHeight,
    super.showAsDot,
    super.matterNodeId,
    super.matterEndpointId,
    super.pin,
    this.batteryLevel,
    this.areaCleaned,
    this.cleaningTime,
    this.filterStatus,
    this.nextCleaning,
  }) : super(
          type: DeviceType.vacuum,
        );

  VacuumDeviceEntity copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOn,
    String? roomId,
    double? positionX,
    double? positionY,
    double? markerWidth,
    double? markerHeight,
    bool? showAsDot,
    Object? matterNodeId = const Object(),
    Object? matterEndpointId = const Object(),
    Object? pin = const Object(),
    int? batteryLevel,
    int? areaCleaned,
    int? cleaningTime,
    int? filterStatus,
    String? nextCleaning,
  }) {
    return VacuumDeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isOn: isOn ?? this.isOn,
      roomId: roomId ?? this.roomId,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      markerWidth: markerWidth ?? this.markerWidth,
      markerHeight: markerHeight ?? this.markerHeight,
      showAsDot: showAsDot ?? this.showAsDot,
      matterNodeId: matterNodeId == const Object() ? this.matterNodeId : (matterNodeId as int?),
      matterEndpointId: matterEndpointId == const Object() ? this.matterEndpointId : (matterEndpointId as int?),
      pin: pin == const Object() ? this.pin : (pin as int?),
      batteryLevel: batteryLevel ?? this.batteryLevel,
      areaCleaned: areaCleaned ?? this.areaCleaned,
      cleaningTime: cleaningTime ?? this.cleaningTime,
      filterStatus: filterStatus ?? this.filterStatus,
      nextCleaning: nextCleaning ?? this.nextCleaning,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        batteryLevel,
        areaCleaned,
        cleaningTime,
        filterStatus,
        nextCleaning,
      ];
}
