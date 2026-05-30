import 'package:equatable/equatable.dart';

enum DeviceType { vacuum, airConditioner, lamp, door, rgb }

class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final String? roomId;
  
  // Vacuum specifics
  final int? batteryLevel;
  final int? areaCleaned;
  final int? cleaningTime;
  final int? filterStatus;
  final String? nextCleaning;

  // AC specifics
  final int? temperature;
  final String? mode;
  final int? coolingTime;

  // Lamp specifics
  final int? brightness;

  // Door specifics
  final bool? isLocked;

  // Linked devices count
  final int? linkedDevicesCount;

  // Placement coordinates (normalized 0.0 to 1.0)
  final double? positionX;
  final double? positionY;

  // Display size in logical pixels (for room placement view)
  final double? markerWidth;
  final double? markerHeight;

  // RGB specifics (0–255 per channel)
  final int? rgbR;
  final int? rgbG;
  final int? rgbB;

  // Presentation style style
  final bool showAsDot;

  // Matter fields
  final int? matterNodeId;
  final int? matterEndpointId;

  // ESP32 GPIO pin mapping
  final int? pin;

  // IR remote codes for AC (stored as JSON string containing protocol, value, bits)
  final String? irPower;
  final String? irTempUp;
  final String? irTempDown;
  final String? irAuto;
  final String? irCool;
  final String? irHeat;
  final String? irEco;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.roomId,
    this.batteryLevel,
    this.areaCleaned,
    this.cleaningTime,
    this.filterStatus,
    this.nextCleaning,
    this.temperature,
    this.mode,
    this.coolingTime,
    this.brightness,
    this.isLocked,
    this.linkedDevicesCount,
    this.positionX,
    this.positionY,
    this.markerWidth,
    this.markerHeight,
    this.rgbR,
    this.rgbG,
    this.rgbB,
    this.showAsDot = false,
    this.matterNodeId,
    this.matterEndpointId,
    this.pin,
    this.irPower,
    this.irTempUp,
    this.irTempDown,
    this.irAuto,
    this.irCool,
    this.irHeat,
    this.irEco,
  });

  DeviceEntity copyWith({
    String? id,
    String? name,
    DeviceType? type,
    bool? isOn,
    String? roomId,
    int? batteryLevel,
    int? areaCleaned,
    int? cleaningTime,
    int? filterStatus,
    String? nextCleaning,
    int? temperature,
    String? mode,
    int? coolingTime,
    int? brightness,
    bool? isLocked,
    int? linkedDevicesCount,
    double? positionX,
    double? positionY,
    double? markerWidth,
    double? markerHeight,
    int? rgbR,
    int? rgbG,
    int? rgbB,
    bool? showAsDot,
    Object? matterNodeId = const Object(),
    Object? matterEndpointId = const Object(),
    Object? pin = const Object(),
    Object? irPower = const Object(),
    Object? irTempUp = const Object(),
    Object? irTempDown = const Object(),
    Object? irAuto = const Object(),
    Object? irCool = const Object(),
    Object? irHeat = const Object(),
    Object? irEco = const Object(),
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isOn: isOn ?? this.isOn,
      roomId: roomId ?? this.roomId,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      areaCleaned: areaCleaned ?? this.areaCleaned,
      cleaningTime: cleaningTime ?? this.cleaningTime,
      filterStatus: filterStatus ?? this.filterStatus,
      nextCleaning: nextCleaning ?? this.nextCleaning,
      temperature: temperature ?? this.temperature,
      mode: mode ?? this.mode,
      coolingTime: coolingTime ?? this.coolingTime,
      brightness: brightness ?? this.brightness,
      isLocked: isLocked ?? this.isLocked,
      linkedDevicesCount: linkedDevicesCount ?? this.linkedDevicesCount,
      positionX: positionX ?? this.positionX,
      positionY: positionY ?? this.positionY,
      markerWidth: markerWidth ?? this.markerWidth,
      markerHeight: markerHeight ?? this.markerHeight,
      rgbR: rgbR ?? this.rgbR,
      rgbG: rgbG ?? this.rgbG,
      rgbB: rgbB ?? this.rgbB,
      showAsDot: showAsDot ?? this.showAsDot,
      matterNodeId: matterNodeId == const Object() ? this.matterNodeId : (matterNodeId as int?),
      matterEndpointId: matterEndpointId == const Object() ? this.matterEndpointId : (matterEndpointId as int?),
      pin: pin == const Object() ? this.pin : (pin as int?),
      irPower: irPower == const Object() ? this.irPower : (irPower as String?),
      irTempUp: irTempUp == const Object() ? this.irTempUp : (irTempUp as String?),
      irTempDown: irTempDown == const Object() ? this.irTempDown : (irTempDown as String?),
      irAuto: irAuto == const Object() ? this.irAuto : (irAuto as String?),
      irCool: irCool == const Object() ? this.irCool : (irCool as String?),
      irHeat: irHeat == const Object() ? this.irHeat : (irHeat as String?),
      irEco: irEco == const Object() ? this.irEco : (irEco as String?),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isOn,
        roomId,
        batteryLevel,
        areaCleaned,
        cleaningTime,
        filterStatus,
        nextCleaning,
        temperature,
        mode,
        coolingTime,
        brightness,
        isLocked,
        linkedDevicesCount,
        positionX,
        positionY,
        markerWidth,
        markerHeight,
        rgbR,
        rgbG,
        rgbB,
        showAsDot,
        matterNodeId,
        matterEndpointId,
        pin,
        irPower,
        irTempUp,
        irTempDown,
        irAuto,
        irCool,
        irHeat,
        irEco,
      ];
}
