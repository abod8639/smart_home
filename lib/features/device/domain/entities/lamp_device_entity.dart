import 'device_entity.dart';

class LampDeviceEntity extends DeviceEntity {
  @override
  final int? brightness;

  const LampDeviceEntity({
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
    this.brightness,
  }) : super.internal(
          id: id,
          name: name,
          type: DeviceType.lamp,
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
        brightness,
      ];
}
