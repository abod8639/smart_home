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
    this.brightness,
    this.rgbR,
    this.rgbG,
    this.rgbB,
  }) : super.internal(
          type: DeviceType.rgb,
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
