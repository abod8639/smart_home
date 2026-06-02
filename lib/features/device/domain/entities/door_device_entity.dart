import 'device_entity.dart';

class DoorDeviceEntity extends DeviceEntity {
  @override
  final bool? isLocked;
  @override
  final int? linkedDevicesCount;

  const DoorDeviceEntity({
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
    this.isLocked,
    this.linkedDevicesCount,
  }) : super.internal(
          id: id,
          name: name,
          type: DeviceType.door,
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
        isLocked,
        linkedDevicesCount,
      ];
}
