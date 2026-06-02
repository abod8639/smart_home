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
    required String id,
    required String name,
    bool isOn = false,
    String? roomId,
    double? positionX,
    double? positionY,
    double? markerWidth,
    double? markerHeight,
    bool showAsDot = false,
    int? matterNodeId,
    int? matterEndpointId,
    int? pin,
    this.batteryLevel,
    this.areaCleaned,
    this.cleaningTime,
    this.filterStatus,
    this.nextCleaning,
  }) : super.internal(
          id: id,
          name: name,
          type: DeviceType.vacuum,
          isOn: isOn,
          roomId: roomId,
          positionX: positionX,
          positionY: positionY,
          markerWidth: markerWidth,
          markerHeight: markerHeight,
          showAsDot: showAsDot,
          matterNodeId: matterNodeId,
          matterEndpointId: matterEndpointId,
          pin: pin,
        );

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
