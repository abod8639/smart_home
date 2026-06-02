import 'device_entity.dart';

class LampDeviceEntity extends DeviceEntity {
  @override
  final int? brightness;

  const LampDeviceEntity({
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
  }) : super.internal(type: DeviceType.lamp);

  @override
  List<Object?> get props => [
        ...super.props,
        brightness,
      ];
}
