import 'device_entity.dart';

class AcDeviceEntity extends DeviceEntity {
  @override
  final int? temperature;
  @override
  final String? mode;
  @override
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
  }) : super.internal(
          type: DeviceType.airConditioner,
        );

  // IR fields mapped to acIrCodes
  @override
  String? get irPower => acIrCodes.irPower;
  @override
  String? get irTempUp => acIrCodes.irTempUp;
  @override
  String? get irTempDown => acIrCodes.irTempDown;
  @override
  String? get irAuto => acIrCodes.irAuto;
  @override
  String? get irCool => acIrCodes.irCool;
  @override
  String? get irHeat => acIrCodes.irHeat;
  @override
  String? get irEco => acIrCodes.irEco;
  @override
  String? get irDry => acIrCodes.irDry;
  @override
  String? get irFanQuiet => acIrCodes.irFanQuiet;
  @override
  String? get irFanLow => acIrCodes.irFanLow;
  @override
  String? get irFanMed => acIrCodes.irFanMed;
  @override
  String? get irFanHigh => acIrCodes.irFanHigh;
  @override
  String? get irFanAuto => acIrCodes.irFanAuto;
  @override
  String? get irSwingV => acIrCodes.irSwingV;
  @override
  String? get irSwingH => acIrCodes.irSwingH;
  @override
  String? get irPlasmacluster => acIrCodes.irPlasmacluster;
  @override
  String? get irSuperJet => acIrCodes.irSuperJet;
  @override
  String? get irCoanda => acIrCodes.irCoanda;
  @override
  String? get irMyArea => acIrCodes.irMyArea;
  @override
  String? get irDisplay => acIrCodes.irDisplay;
  @override
  String? get irClean => acIrCodes.irClean;

  @override
  List<Object?> get props => [
        ...super.props,
        temperature,
        mode,
        coolingTime,
        acIrCodes,
      ];
}
