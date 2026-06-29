import 'device_entity.dart';

/// Entity representing a smart RGB LED lamp/strip.
class RgbLampDeviceEntity extends DeviceEntity {
  /// Current brightness level (0 to 255).
  final int? brightness;
  /// Red color component value (0 to 255).
  final int? rgbR;
  /// Green color component value (0 to 255).
  final int? rgbG;
  /// Blue color component value (0 to 255).
  final int? rgbB;

  /// Creates a constant [RgbLampDeviceEntity] instance.
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
    super.isPwm,
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
    Object? isPwm = const Object(),
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
      isPwm: isPwm == const Object() ? this.isPwm : (isPwm as bool?),
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
