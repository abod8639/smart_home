import 'device_entity.dart';

/// Entity representing a smart robotic vacuum cleaner.
class VacuumDeviceEntity extends DeviceEntity {
  /// Current battery level percentage (0 to 100).
  final int? batteryLevel;
  /// Total area cleaned in square meters (sqm) during the current session.
  final int? areaCleaned;
  /// Clean duration in minutes.
  final int? cleaningTime;
  /// Filter life remaining percentage (0 to 100).
  final int? filterStatus;
  /// Time of the next scheduled cleaning run (e.g. "10:30 AM").
  final String? nextCleaning;

  /// Creates a constant [VacuumDeviceEntity] instance.
  const VacuumDeviceEntity({
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
    this.batteryLevel,
    this.areaCleaned,
    this.cleaningTime,
    this.filterStatus,
    this.nextCleaning,
  }) : super(
          type: DeviceType.vacuum,
        );

  VacuumDeviceEntity copyWith({
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
    int? batteryLevel,
    int? areaCleaned,
    int? cleaningTime,
    int? filterStatus,
    String? nextCleaning,
  }) {
    return VacuumDeviceEntity(
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
      batteryLevel: batteryLevel ?? this.batteryLevel,
      areaCleaned: areaCleaned ?? this.areaCleaned,
      cleaningTime: cleaningTime ?? this.cleaningTime,
      filterStatus: filterStatus ?? this.filterStatus,
      nextCleaning: nextCleaning ?? this.nextCleaning,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        batteryLevel,
        areaCleaned,
        cleaningTime,
        filterStatus,
        nextCleaning,
      ];
}
