import 'device_entity.dart';

/// Entity representing a smart Air Conditioner.
class AcDeviceEntity extends DeviceEntity {
  /// Target temperature setting in degrees Celsius.
  final int? temperature;
  /// Active operating mode (e.g. "Auto mode", "Cool mode").
  final String? mode;
  /// Total cooling runtime in hours.
  final int? coolingTime;
  /// Associated IR commands for this AC.
  final AcIrCodes acIrCodes;
  /// Remaining time in seconds for the sleep/off timer.
  final int? sleepTimerRemaining;

  /// Creates a constant [AcDeviceEntity] instance.
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
    super.isPwm,
    this.temperature,
    this.mode,
    this.coolingTime,
    required this.acIrCodes,
    this.sleepTimerRemaining,
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
    Object? isPwm = const Object(),
    int? temperature,
    String? mode,
    int? coolingTime,
    AcIrCodes? acIrCodes,
    int? sleepTimerRemaining,
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
      isPwm: isPwm == const Object() ? this.isPwm : (isPwm as bool?),
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      coolingTime: coolingTime ?? this.coolingTime,
      acIrCodes: acIrCodes ?? this.acIrCodes,
      sleepTimerRemaining: sleepTimerRemaining ?? this.sleepTimerRemaining,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        temperature,
        mode,
        coolingTime,
        acIrCodes,
        sleepTimerRemaining,
      ];
}
