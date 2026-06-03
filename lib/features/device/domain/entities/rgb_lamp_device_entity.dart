import 'device_entity.dart';

class RgbLampDeviceEntity extends DeviceEntity {
  final int? brightness;
  final int? rgbR;
  final int? rgbG;
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
  }) : super(
          type: DeviceType.rgb,
        );

  RgbLampDeviceEntity copyWith({
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
    int? brightness,
    int? rgbR,
    int? rgbG,
    int? rgbB,
  }) {
    return RgbLampDeviceEntity(
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
      brightness: brightness ?? this.brightness,
      rgbR: rgbR ?? this.rgbR,
      rgbG: rgbG ?? this.rgbG,
      rgbB: rgbB ?? this.rgbB,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        brightness,
        rgbR,
        rgbG,
        rgbB,
      ];
}
