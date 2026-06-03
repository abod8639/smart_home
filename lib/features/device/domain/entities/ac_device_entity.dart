import 'device_entity.dart';

class AcDeviceEntity extends DeviceEntity {
  final int? temperature;
  final String? mode;
  final int? coolingTime;
  final AcIrCodes acIrCodes;

  const AcDeviceEntity({
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
    this.temperature,
    this.mode,
    this.coolingTime,
    required this.acIrCodes,
  }) : super(
          type: DeviceType.airConditioner,
        );

  AcDeviceEntity copyWith({
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
    int? temperature,
    String? mode,
    int? coolingTime,
    AcIrCodes? acIrCodes,
  }) {
    return AcDeviceEntity(
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
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      coolingTime: coolingTime ?? this.coolingTime,
      acIrCodes: acIrCodes ?? this.acIrCodes,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        temperature,
        mode,
        coolingTime,
        acIrCodes,
      ];
}
