import 'package:equatable/equatable.dart';

/// Set of IR commands learned or assigned for an Air Conditioner.
class AcIrCodes extends Equatable {
  /// Hex/timing payload for toggle power.
  final String? irPower;
  /// Hex/timing payload to increase temperature.
  final String? irTempUp;
  /// Hex/timing payload to decrease temperature.
  final String? irTempDown;
  /// Hex/timing payload to set AC to Auto mode.
  final String? irAuto;
  /// Hex/timing payload to set AC to Cool mode.
  final String? irCool;
  /// Hex/timing payload to set AC to Heat mode.
  final String? irHeat;
  /// Hex/timing payload to set AC to Eco mode.
  final String? irEco;
  /// Hex/timing payload to set AC to Dry mode.
  final String? irDry;
  /// Hex/timing payload for quiet fan speed.
  final String? irFanQuiet;
  /// Hex/timing payload for low fan speed.
  final String? irFanLow;
  /// Hex/timing payload for medium fan speed.
  final String? irFanMed;
  /// Hex/timing payload for high fan speed.
  final String? irFanHigh;
  /// Hex/timing payload for automatic fan speed.
  final String? irFanAuto;
  /// Hex/timing payload for vertical swing.
  final String? irSwingV;
  /// Hex/timing payload for horizontal swing.
  final String? irSwingH;
  /// Hex/timing payload for plasmacluster mode.
  final String? irPlasmacluster;
  /// Hex/timing payload for super jet mode.
  final String? irSuperJet;
  /// Hex/timing payload for coanda airflow mode.
  final String? irCoanda;
  /// Hex/timing payload for my area mode.
  final String? irMyArea;
  /// Hex/timing payload to toggle display light.
  final String? irDisplay;
  /// Hex/timing payload for clean mode.
  final String? irClean;

  /// Creates a constant [AcIrCodes] instance.
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
