import 'device_entity.dart';

class DoorDeviceEntity extends DeviceEntity {
  @override
  final bool? isLocked;
  @override
  final int? linkedDevicesCount;

  const DoorDeviceEntity({
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
    this.isLocked,
    this.linkedDevicesCount,
  }) : super.internal(
          type: DeviceType.door,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        isLocked,
        linkedDevicesCount,
      ];
}
