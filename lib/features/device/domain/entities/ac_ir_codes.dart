import 'package:equatable/equatable.dart';

class AcIrCodes extends Equatable {
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

  const AcIrCodes({
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
  });

  AcIrCodes copyWith({
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
    return AcIrCodes(
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
        irPower,
        irTempUp,
        irTempDown,
        irAuto,
        irCool,
        irHeat,
        irEco,
        irDry,
        irFanQuiet,
        irFanLow,
        irFanMed,
        irFanHigh,
        irFanAuto,
        irSwingV,
        irSwingH,
        irPlasmacluster,
        irSuperJet,
        irCoanda,
        irMyArea,
        irDisplay,
        irClean,
      ];
}
