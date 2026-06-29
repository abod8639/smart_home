import '../../domain/entities/device_entity.dart';

/// Data Transfer Object (DTO) for device serialization/deserialization.
class DeviceModel {
  final String id;
  final String name;
  final String type;
  final bool isOn;
  final String? roomId;
  final double? positionX;
  final double? positionY;
  final double? markerWidth;
  final double? markerHeight;
  final bool showAsDot;
  final int? matterNodeId;
  final int? matterEndpointId;
  final int? pin;
  final bool? isPwm;

  // AC specific
  final int? temperature;
  final String? mode;
  final int? coolingTime;
  final int? sleepTimerRemaining;
  final String? irPower;
  final String? irTempUp;
  final String? irTempDown;
  final String? irAuto;
  final String? irCool;
  final String? irHeat;
  final String? irEco;
  final String? irDry;
  final String? irFanQuiet;
  final String? irFanLow;
  final String? irFanMed;
  final String? irFanHigh;
  final String? irFanAuto;
  final String? irSwingV;
  final String? irSwingH;
  final String? irPlasmacluster;
  final String? irSuperJet;
  final String? irCoanda;
  final String? irMyArea;
  final String? irDisplay;
  final String? irClean;

  // Lamp specific
  final int? brightness;

  // RGB specific
  final int? rgbR;
  final int? rgbG;
  final int? rgbB;

  // Door specific
  final bool? isLocked;
  final int? linkedDevicesCount;

  // Vacuum specific
  final int? batteryLevel;
  final int? areaCleaned;
  final int? cleaningTime;
  final int? filterStatus;
  final String? nextCleaning;

  /// Creates a constant [DeviceModel] instance.
  const DeviceModel({
    required this.id,
    required this.name,
    required this.type,
    required this.isOn,
    this.roomId,
    this.positionX,
    this.positionY,
    this.markerWidth,
    this.markerHeight,
    required this.showAsDot,
    this.matterNodeId,
    this.matterEndpointId,
    this.pin,
    this.isPwm,
    this.temperature,
    this.mode,
    this.coolingTime,
    this.sleepTimerRemaining,
    this.irPower,
    this.irTempUp,
    this.irTempDown,
    this.irAuto,
    this.irCool,
    this.irHeat,
    this.irEco,
    this.irDry,
    this.irFanQuiet,
    this.irFanLow,
    this.irFanMed,
    this.irFanHigh,
    this.irFanAuto,
    this.irSwingV,
    this.irSwingH,
    this.irPlasmacluster,
    this.irSuperJet,
    this.irCoanda,
    this.irMyArea,
    this.irDisplay,
    this.irClean,
    this.brightness,
    this.rgbR,
    this.rgbG,
    this.rgbB,
    this.isLocked,
    this.linkedDevicesCount,
    this.batteryLevel,
    this.areaCleaned,
    this.cleaningTime,
    this.filterStatus,
    this.nextCleaning,
  });

  /// Creates a [DeviceModel] from a JSON map.
  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      isOn: json['isOn'] as bool? ?? false,
      roomId: json['roomId'] as String?,
      positionX: (json['positionX'] as num?)?.toDouble(),
      positionY: (json['positionY'] as num?)?.toDouble(),
      markerWidth: (json['markerWidth'] as num?)?.toDouble(),
      markerHeight: (json['markerHeight'] as num?)?.toDouble(),
      showAsDot: json['showAsDot'] as bool? ?? false,
      matterNodeId: json['matterNodeId'] as int?,
      matterEndpointId: json['matterEndpointId'] as int?,
      pin: json['pin'] as int?,
      isPwm: json['isPwm'] as bool?,

      // AC
      temperature: json['temperature'] as int?,
      mode: json['mode'] as String?,
      coolingTime: json['coolingTime'] as int?,
      sleepTimerRemaining: json['sleepTimerRemaining'] as int?,
      irPower: json['irPower'] as String?,
      irTempUp: json['irTempUp'] as String?,
      irTempDown: json['irTempDown'] as String?,
      irAuto: json['irAuto'] as String?,
      irCool: json['irCool'] as String?,
      irHeat: json['irHeat'] as String?,
      irEco: json['irEco'] as String?,
      irDry: json['irDry'] as String?,
      irFanQuiet: json['irFanQuiet'] as String?,
      irFanLow: json['irFanLow'] as String?,
      irFanMed: json['irFanMed'] as String?,
      irFanHigh: json['irFanHigh'] as String?,
      irFanAuto: json['irFanAuto'] as String?,
      irSwingV: json['irSwingV'] as String?,
      irSwingH: json['irSwingH'] as String?,
      irPlasmacluster: json['irPlasmacluster'] as String?,
      irSuperJet: json['irSuperJet'] as String?,
      irCoanda: json['irCoanda'] as String?,
      irMyArea: json['irMyArea'] as String?,
      irDisplay: json['irDisplay'] as String?,
      irClean: json['irClean'] as String?,

      // Lamp
      brightness: json['brightness'] as int?,

      // RGB
      rgbR: json['rgbR'] as int?,
      rgbG: json['rgbG'] as int?,
      rgbB: json['rgbB'] as int?,

      // Door
      isLocked: json['isLocked'] as bool?,
      linkedDevicesCount: json['linkedDevicesCount'] as int?,

      // Vacuum
      batteryLevel: json['batteryLevel'] as int?,
      areaCleaned: json['areaCleaned'] as int?,
      cleaningTime: json['cleaningTime'] as int?,
      filterStatus: json['filterStatus'] as int?,
      nextCleaning: json['nextCleaning'] as String?,
    );
  }

  /// Converts this model into a JSON-serializable map.
  Map<String, dynamic> toJson({bool excludeIrCodes = false}) {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isOn': isOn,
      'roomId': roomId,
      'positionX': positionX,
      'positionY': positionY,
      'markerWidth': markerWidth,
      'markerHeight': markerHeight,
      'showAsDot': showAsDot,
      'matterNodeId': matterNodeId,
      'matterEndpointId': matterEndpointId,
      'pin': pin,
      'isPwm': isPwm,

      // AC
      if (temperature != null) 'temperature': temperature,
      if (mode != null) 'mode': mode,
      if (coolingTime != null) 'coolingTime': coolingTime,
      if (sleepTimerRemaining != null) 'sleepTimerRemaining': sleepTimerRemaining,
      if (!excludeIrCodes) ...{
        if (irPower != null) 'irPower': irPower,
        if (irTempUp != null) 'irTempUp': irTempUp,
        if (irTempDown != null) 'irTempDown': irTempDown,
        if (irAuto != null) 'irAuto': irAuto,
        if (irCool != null) 'irCool': irCool,
        if (irHeat != null) 'irHeat': irHeat,
        if (irEco != null) 'irEco': irEco,
        if (irDry != null) 'irDry': irDry,
        if (irFanQuiet != null) 'irFanQuiet': irFanQuiet,
        if (irFanLow != null) 'irFanLow': irFanLow,
        if (irFanMed != null) 'irFanMed': irFanMed,
        if (irFanHigh != null) 'irFanHigh': irFanHigh,
        if (irFanAuto != null) 'irFanAuto': irFanAuto,
        if (irSwingV != null) 'irSwingV': irSwingV,
        if (irSwingH != null) 'irSwingH': irSwingH,
        if (irPlasmacluster != null) 'irPlasmacluster': irPlasmacluster,
        if (irSuperJet != null) 'irSuperJet': irSuperJet,
        if (irCoanda != null) 'irCoanda': irCoanda,
        if (irMyArea != null) 'irMyArea': irMyArea,
        if (irDisplay != null) 'irDisplay': irDisplay,
        if (irClean != null) 'irClean': irClean,
      },

      // Lamp
      if (brightness != null) 'brightness': brightness,

      // RGB
      if (rgbR != null) 'rgbR': rgbR,
      if (rgbG != null) 'rgbG': rgbG,
      if (rgbB != null) 'rgbB': rgbB,

      // Door
      if (isLocked != null) 'isLocked': isLocked,
      if (linkedDevicesCount != null) 'linkedDevicesCount': linkedDevicesCount,

      // Vacuum
      if (batteryLevel != null) 'batteryLevel': batteryLevel,
      if (areaCleaned != null) 'areaCleaned': areaCleaned,
      if (cleaningTime != null) 'cleaningTime': cleaningTime,
      if (filterStatus != null) 'filterStatus': filterStatus,
      if (nextCleaning != null) 'nextCleaning': nextCleaning,
    };
  }

  /// Converts this model into a clean domain [DeviceEntity].
  DeviceEntity toEntity() {
    final deviceType = DeviceType.values.firstWhere(
      (e) => e.name == type,
      orElse: () => DeviceType.lamp,
    );

    switch (deviceType) {
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
          isPwm: isPwm,
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
          isPwm: isPwm,
          temperature: temperature,
          mode: mode,
          coolingTime: coolingTime,
          sleepTimerRemaining: sleepTimerRemaining,
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
          isPwm: isPwm,
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
          isPwm: isPwm,
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
          isPwm: isPwm,
          isLocked: isLocked,
          linkedDevicesCount: linkedDevicesCount,
        );
    }
  }

  /// Creates a [DeviceModel] from a domain [DeviceEntity].
  factory DeviceModel.fromEntity(DeviceEntity d) {
    return DeviceModel(
      id: d.id,
      name: d.name,
      type: d.type.name,
      isOn: d.isOn,
      roomId: d.roomId,
      positionX: d.positionX,
      positionY: d.positionY,
      markerWidth: d.markerWidth,
      markerHeight: d.markerHeight,
      showAsDot: d.showAsDot,
      matterNodeId: d.matterNodeId,
      matterEndpointId: d.matterEndpointId,
      pin: d.pin,
      isPwm: d.isPwm,
      
      // AC
      temperature: d is AcDeviceEntity ? d.temperature : null,
      mode: d is AcDeviceEntity ? d.mode : null,
      coolingTime: d is AcDeviceEntity ? d.coolingTime : null,
      sleepTimerRemaining: d is AcDeviceEntity ? d.sleepTimerRemaining : null,
      irPower: d is AcDeviceEntity ? d.acIrCodes.irPower : null,
      irTempUp: d is AcDeviceEntity ? d.acIrCodes.irTempUp : null,
      irTempDown: d is AcDeviceEntity ? d.acIrCodes.irTempDown : null,
      irAuto: d is AcDeviceEntity ? d.acIrCodes.irAuto : null,
      irCool: d is AcDeviceEntity ? d.acIrCodes.irCool : null,
      irHeat: d is AcDeviceEntity ? d.acIrCodes.irHeat : null,
      irEco: d is AcDeviceEntity ? d.acIrCodes.irEco : null,
      irDry: d is AcDeviceEntity ? d.acIrCodes.irDry : null,
      irFanQuiet: d is AcDeviceEntity ? d.acIrCodes.irFanQuiet : null,
      irFanLow: d is AcDeviceEntity ? d.acIrCodes.irFanLow : null,
      irFanMed: d is AcDeviceEntity ? d.acIrCodes.irFanMed : null,
      irFanHigh: d is AcDeviceEntity ? d.acIrCodes.irFanHigh : null,
      irFanAuto: d is AcDeviceEntity ? d.acIrCodes.irFanAuto : null,
      irSwingV: d is AcDeviceEntity ? d.acIrCodes.irSwingV : null,
      irSwingH: d is AcDeviceEntity ? d.acIrCodes.irSwingH : null,
      irPlasmacluster: d is AcDeviceEntity ? d.acIrCodes.irPlasmacluster : null,
      irSuperJet: d is AcDeviceEntity ? d.acIrCodes.irSuperJet : null,
      irCoanda: d is AcDeviceEntity ? d.acIrCodes.irCoanda : null,
      irMyArea: d is AcDeviceEntity ? d.acIrCodes.irMyArea : null,
      irDisplay: d is AcDeviceEntity ? d.acIrCodes.irDisplay : null,
      irClean: d is AcDeviceEntity ? d.acIrCodes.irClean : null,

      // Lamp
      brightness: d is LampDeviceEntity
          ? d.brightness
          : (d is RgbLampDeviceEntity ? d.brightness : null),

      // RGB
      rgbR: d is RgbLampDeviceEntity ? d.rgbR : null,
      rgbG: d is RgbLampDeviceEntity ? d.rgbG : null,
      rgbB: d is RgbLampDeviceEntity ? d.rgbB : null,

      // Door
      isLocked: d is DoorDeviceEntity ? d.isLocked : null,
      linkedDevicesCount: d is DoorDeviceEntity ? d.linkedDevicesCount : null,

      // Vacuum
      batteryLevel: d is VacuumDeviceEntity ? d.batteryLevel : null,
      areaCleaned: d is VacuumDeviceEntity ? d.areaCleaned : null,
      cleaningTime: d is VacuumDeviceEntity ? d.cleaningTime : null,
      filterStatus: d is VacuumDeviceEntity ? d.filterStatus : null,
      nextCleaning: d is VacuumDeviceEntity ? d.nextCleaning : null,
    );
  }
}
