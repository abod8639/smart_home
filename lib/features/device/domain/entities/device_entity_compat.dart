import 'device_entity.dart';

/// Backward-compatibility extension to access subtype-specific fields on the base [DeviceEntity].
extension DeviceEntityCompat on DeviceEntity {
  // Getters for AC
  int? get temperature => this is AcDeviceEntity ? (this as AcDeviceEntity).temperature : null;
  String? get mode => this is AcDeviceEntity ? (this as AcDeviceEntity).mode : null;
  int? get coolingTime => this is AcDeviceEntity ? (this as AcDeviceEntity).coolingTime : null;
  int? get sleepTimerRemaining => this is AcDeviceEntity ? (this as AcDeviceEntity).sleepTimerRemaining : null;
  
  // Getters for Lamps
  int? get brightness {
    if (this is LampDeviceEntity) return (this as LampDeviceEntity).brightness;
    if (this is RgbLampDeviceEntity) return (this as RgbLampDeviceEntity).brightness;
    return null;
  }
  
  // Getters for RGB Lamps
  int? get rgbR => this is RgbLampDeviceEntity ? (this as RgbLampDeviceEntity).rgbR : null;
  int? get rgbG => this is RgbLampDeviceEntity ? (this as RgbLampDeviceEntity).rgbG : null;
  int? get rgbB => this is RgbLampDeviceEntity ? (this as RgbLampDeviceEntity).rgbB : null;
  
  // Getters for Doors
  bool? get isLocked => this is DoorDeviceEntity ? (this as DoorDeviceEntity).isLocked : null;
  int? get linkedDevicesCount => this is DoorDeviceEntity ? (this as DoorDeviceEntity).linkedDevicesCount : null;
  
  // Getters for Vacuums
  int? get batteryLevel => this is VacuumDeviceEntity ? (this as VacuumDeviceEntity).batteryLevel : null;
  int? get areaCleaned => this is VacuumDeviceEntity ? (this as VacuumDeviceEntity).areaCleaned : null;
  int? get cleaningTime => this is VacuumDeviceEntity ? (this as VacuumDeviceEntity).cleaningTime : null;
  int? get filterStatus => this is VacuumDeviceEntity ? (this as VacuumDeviceEntity).filterStatus : null;
  String? get nextCleaning => this is VacuumDeviceEntity ? (this as VacuumDeviceEntity).nextCleaning : null;

  // IR Codes
  AcIrCodes? get acIrCodes => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes : null;
  String? get irPower => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irPower : null;
  String? get irTempUp => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irTempUp : null;
  String? get irTempDown => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irTempDown : null;
  String? get irAuto => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irAuto : null;
  String? get irCool => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irCool : null;
  String? get irHeat => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irHeat : null;
  String? get irEco => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irEco : null;
  String? get irDry => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irDry : null;
  String? get irFanQuiet => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irFanQuiet : null;
  String? get irFanLow => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irFanLow : null;
  String? get irFanMed => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irFanMed : null;
  String? get irFanHigh => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irFanHigh : null;
  String? get irFanAuto => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irFanAuto : null;
  String? get irSwingV => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irSwingV : null;
  String? get irSwingH => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irSwingH : null;
  String? get irPlasmacluster => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irPlasmacluster : null;
  String? get irSuperJet => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irSuperJet : null;
  String? get irCoanda => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irCoanda : null;
  String? get irMyArea => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irMyArea : null;
  String? get irDisplay => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irDisplay : null;
  String? get irClean => this is AcDeviceEntity ? (this as AcDeviceEntity).acIrCodes.irClean : null;

  // Unified copyWith for backwards compatibility
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
    int? temperature,
    String? mode,
    int? coolingTime,
    int? brightness,
    int? rgbR,
    int? rgbG,
    int? rgbB,
    bool? isLocked,
    int? linkedDevicesCount,
    int? batteryLevel,
    int? areaCleaned,
    int? cleaningTime,
    int? filterStatus,
    String? nextCleaning,
    int? sleepTimerRemaining,
    AcIrCodes? acIrCodes,
  }) {
    if (this is AcDeviceEntity) {
      return (this as AcDeviceEntity).copyWith(
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
        sleepTimerRemaining: sleepTimerRemaining,
        acIrCodes: acIrCodes,
      );
    } else if (this is LampDeviceEntity) {
      return (this as LampDeviceEntity).copyWith(
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
    } else if (this is RgbLampDeviceEntity) {
      return (this as RgbLampDeviceEntity).copyWith(
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
    } else if (this is DoorDeviceEntity) {
      return (this as DoorDeviceEntity).copyWith(
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
    } else if (this is VacuumDeviceEntity) {
      return (this as VacuumDeviceEntity).copyWith(
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
    }
    return this;
  }
}
