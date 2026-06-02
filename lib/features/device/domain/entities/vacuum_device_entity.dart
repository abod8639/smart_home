import 'device_entity.dart';

class VacuumDeviceEntity extends DeviceEntity {
  @override
  final int? batteryLevel;
  @override
  final int? areaCleaned;
  @override
  final int? cleaningTime;
  @override
  final int? filterStatus;
  @override
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
  }) : super.internal(type: DeviceType.vacuum);

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
