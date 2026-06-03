import 'device_entity.dart';

class DoorDeviceEntity extends DeviceEntity {
  final bool? isLocked;
  final int? linkedDevicesCount;

  const DoorDeviceEntity({
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
    this.isLocked,
    this.linkedDevicesCount,
  }) : super(
          type: DeviceType.door,
        );

  DoorDeviceEntity copyWith({
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
    bool? isLocked,
    int? linkedDevicesCount,
  }) {
    return DoorDeviceEntity(
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
      isLocked: isLocked ?? this.isLocked,
      linkedDevicesCount: linkedDevicesCount ?? this.linkedDevicesCount,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        isLocked,
        linkedDevicesCount,
      ];
}
