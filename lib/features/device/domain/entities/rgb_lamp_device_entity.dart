import 'device_entity.dart';

class RgbLampDeviceEntity extends DeviceEntity {
  @override
  final int? brightness;
  @override
  final int? rgbR;
  @override
  final int? rgbG;
  @override
  final int? rgbB;

  const RgbLampDeviceEntity({
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
    this.rgbR,
    this.rgbG,
    this.rgbB,
  }) : super.internal(
          id: id,
          name: name,
          type: DeviceType.rgb,
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
        rgbR,
        rgbG,
        rgbB,
      ];
}
