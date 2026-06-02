import 'package:equatable/equatable.dart';

// Imports of subclasses for factory constructor
import 'ac_ir_codes.dart';
import 'vacuum_device_entity.dart';
import 'ac_device_entity.dart';
import 'lamp_device_entity.dart';
import 'rgb_lamp_device_entity.dart';
import 'door_device_entity.dart';

// Exports of subclasses for backwards compatibility
export 'ac_ir_codes.dart';
export 'vacuum_device_entity.dart';
export 'ac_device_entity.dart';
export 'lamp_device_entity.dart';
export 'rgb_lamp_device_entity.dart';
export 'door_device_entity.dart';

enum DeviceType { vacuum, airConditioner, lamp, door, rgb }

abstract class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final String? roomId;

  // Placement coordinates (normalized 0.0 to 1.0)
  final double? positionX;
  final double? positionY;

  // Display size in logical pixels (for room placement view)
  final double? markerWidth;
  final double? markerHeight;

  // Presentation style
  final bool showAsDot;

  // Matter fields
  final int? matterNodeId;
  final int? matterEndpointId;

  // ESP32 GPIO pin mapping
  final int? pin;

  const DeviceEntity.internal({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.roomId,
    this.positionX,
    this.positionY,
    this.markerWidth,
    this.markerHeight,
    this.showAsDot = false,
    this.matterNodeId,
    this.matterEndpointId,
    this.pin,
  });

  // Factory constructor for backwards compatibility
  factory DeviceEntity({
    required String id,
    required String name,
    required DeviceType type,
    bool isOn = false,
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
    bool showAsDot = false,
    int? matterNodeId,
    int? matterEndpointId,
    int? pin,
    String? irPower,
    String? irTempUp,
    String? irTempDown,
    String? irAuto,
    String? irCool,
    String? irHeat,
    String? irEco,
    String? irDry,
    String? irFanQuiet,
    String? irFanLow,
    String? irFanMed,
    String? irFanHigh,
    String? irFanAuto,
    String? irSwingV,
    String? irSwingH,
    String? irPlasmacluster,
    String? irSuperJet,
    String? irCoanda,
    String? irMyArea,
    String? irDisplay,
    String? irClean,
  }) {
    switch (type) {
      case DeviceType.vacuum:
        return VacuumDeviceEntity(
          id: id,
          name: name,
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
          batteryLevel: batteryLevel,
          areaCleaned: areaCleaned,
          cleaningTime: cleaningTime,
          filterStatus: filterStatus,
          nextCleaning: nextCleaning,
        );
      case DeviceType.airConditioner:
        return AcDeviceEntity(
          id: id,
          name: name,
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
          temperature: temperature,
          mode: mode,
          coolingTime: coolingTime,
          acIrCodes: AcIrCodes(
            irPower: irPower,
            irTempUp: irTempUp,
            irTempDown: irTempDown,
            irAuto: irAuto,
            irCool: irCool,
            irHeat: irHeat,
            irEco: irEco,
            irDry: irDry,
            irFanQuiet: irFanQuiet,
            irFanLow: irFanLow,
            irFanMed: irFanMed,
            irFanHigh: irFanHigh,
            irFanAuto: irFanAuto,
            irSwingV: irSwingV,
            irSwingH: irSwingH,
            irPlasmacluster: irPlasmacluster,
            irSuperJet: irSuperJet,
            irCoanda: irCoanda,
            irMyArea: irMyArea,
            irDisplay: irDisplay,
            irClean: irClean,
          ),
        );
      case DeviceType.lamp:
        return LampDeviceEntity(
          id: id,
          name: name,
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
          brightness: brightness,
        );
      case DeviceType.rgb:
        return RgbLampDeviceEntity(
          id: id,
          name: name,
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
          brightness: brightness,
          rgbR: rgbR,
          rgbG: rgbG,
          rgbB: rgbB,
        );
      case DeviceType.door:
        return DoorDeviceEntity(
          id: id,
          name: name,
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
          isLocked: isLocked,
          linkedDevicesCount: linkedDevicesCount,
        );
    }
  }

  // Backwards compatible getters for subclass properties
  int? get batteryLevel => null;
  int? get areaCleaned => null;
  int? get cleaningTime => null;
  int? get filterStatus => null;
  String? get nextCleaning => null;
  int? get temperature => null;
  String? get mode => null;
  int? get coolingTime => null;
  int? get brightness => null;
  bool? get isLocked => null;
  int? get linkedDevicesCount => null;
  int? get rgbR => null;
  int? get rgbG => null;
  int? get rgbB => null;

  // IR Code legacy getters
  String? get irPower => null;
  String? get irTempUp => null;
  String? get irTempDown => null;
  String? get irAuto => null;
  String? get irCool => null;
  String? get irHeat => null;
  String? get irEco => null;
  String? get irDry => null;
  String? get irFanQuiet => null;
  String? get irFanLow => null;
  String? get irFanMed => null;
  String? get irFanHigh => null;
  String? get irFanAuto => null;
  String? get irSwingV => null;
  String? get irSwingH => null;
  String? get irPlasmacluster => null;
  String? get irSuperJet => null;
  String? get irCoanda => null;
  String? get irMyArea => null;
  String? get irDisplay => null;
  String? get irClean => null;

  DeviceEntity copyWith({
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
    // Subclass specific
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
    int? rgbR,
    int? rgbG,
    int? rgbB,
    // IR codes
    Object? irPower = const Object(),
    Object? irTempUp = const Object(),
    Object? irTempDown = const Object(),
    Object? irAuto = const Object(),
    Object? irCool = const Object(),
    Object? irHeat = const Object(),
    Object? irEco = const Object(),
    Object? irDry = const Object(),
    Object? irFanQuiet = const Object(),
    Object? irFanLow = const Object(),
    Object? irFanMed = const Object(),
    Object? irFanHigh = const Object(),
    Object? irFanAuto = const Object(),
    Object? irSwingV = const Object(),
    Object? irSwingH = const Object(),
    Object? irPlasmacluster = const Object(),
    Object? irSuperJet = const Object(),
    Object? irCoanda = const Object(),
    Object? irMyArea = const Object(),
    Object? irDisplay = const Object(),
    Object? irClean = const Object(),
  }) {
    return DeviceEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
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
      rgbR: rgbR ?? this.rgbR,
      rgbG: rgbG ?? this.rgbG,
      rgbB: rgbB ?? this.rgbB,
      irPower: irPower == const Object() ? this.irPower : (irPower as String?),
      irTempUp: irTempUp == const Object() ? this.irTempUp : (irTempUp as String?),
      irTempDown: irTempDown == const Object() ? this.irTempDown : (irTempDown as String?),
      irAuto: irAuto == const Object() ? this.irAuto : (irAuto as String?),
      irCool: irCool == const Object() ? this.irCool : (irCool as String?),
      irHeat: irHeat == const Object() ? this.irHeat : (irHeat as String?),
      irEco: irEco == const Object() ? this.irEco : (irEco as String?),
      irDry: irDry == const Object() ? this.irDry : (irDry as String?),
      irFanQuiet: irFanQuiet == const Object() ? this.irFanQuiet : (irFanQuiet as String?),
      irFanLow: irFanLow == const Object() ? this.irFanLow : (irFanLow as String?),
      irFanMed: irFanMed == const Object() ? this.irFanMed : (irFanMed as String?),
      irFanHigh: irFanHigh == const Object() ? this.irFanHigh : (irFanHigh as String?),
      irFanAuto: irFanAuto == const Object() ? this.irFanAuto : (irFanAuto as String?),
      irSwingV: irSwingV == const Object() ? this.irSwingV : (irSwingV as String?),
      irSwingH: irSwingH == const Object() ? this.irSwingH : (irSwingH as String?),
      irPlasmacluster: irPlasmacluster == const Object() ? this.irPlasmacluster : (irPlasmacluster as String?),
      irSuperJet: irSuperJet == const Object() ? this.irSuperJet : (irSuperJet as String?),
      irCoanda: irCoanda == const Object() ? this.irCoanda : (irCoanda as String?),
      irMyArea: irMyArea == const Object() ? this.irMyArea : (irMyArea as String?),
      irDisplay: irDisplay == const Object() ? this.irDisplay : (irDisplay as String?),
      irClean: irClean == const Object() ? this.irClean : (irClean as String?),
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isOn,
        roomId,
        positionX,
        positionY,
        markerWidth,
        markerHeight,
        showAsDot,
        matterNodeId,
        matterEndpointId,
        pin,
      ];
}
