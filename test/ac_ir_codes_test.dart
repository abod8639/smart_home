import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/device/domain/entities/ac_ir_codes.dart';

void main() {
  group('AcIrCodes', () {
    const fullCodes = AcIrCodes(
      irPower: 'power_code',
      irTempUp: 'temp_up_code',
      irTempDown: 'temp_down_code',
      irAuto: 'auto_code',
      irCool: 'cool_code',
      irHeat: 'heat_code',
      irEco: 'eco_code',
      irDry: 'dry_code',
      irFanQuiet: 'fan_quiet_code',
      irFanLow: 'fan_low_code',
      irFanMed: 'fan_med_code',
      irFanHigh: 'fan_high_code',
      irFanAuto: 'fan_auto_code',
      irSwingV: 'swing_v_code',
      irSwingH: 'swing_h_code',
      irPlasmacluster: 'plasma_code',
      irSuperJet: 'superjet_code',
      irCoanda: 'coanda_code',
      irMyArea: 'myarea_code',
      irDisplay: 'display_code',
      irClean: 'clean_code',
    );

    // ── construction ───────────────────────────────────────────────────────────
    group('construction', () {
      test('creates empty AcIrCodes with all nulls', () {
        const codes = AcIrCodes();
        expect(codes.irPower, isNull);
        expect(codes.irTempUp, isNull);
        expect(codes.irTempDown, isNull);
        expect(codes.irAuto, isNull);
        expect(codes.irCool, isNull);
        expect(codes.irHeat, isNull);
        expect(codes.irEco, isNull);
        expect(codes.irDry, isNull);
        expect(codes.irFanQuiet, isNull);
        expect(codes.irFanLow, isNull);
        expect(codes.irFanMed, isNull);
        expect(codes.irFanHigh, isNull);
        expect(codes.irFanAuto, isNull);
        expect(codes.irSwingV, isNull);
        expect(codes.irSwingH, isNull);
        expect(codes.irPlasmacluster, isNull);
        expect(codes.irSuperJet, isNull);
        expect(codes.irCoanda, isNull);
        expect(codes.irMyArea, isNull);
        expect(codes.irDisplay, isNull);
        expect(codes.irClean, isNull);
      });

      test('creates AcIrCodes with all fields populated', () {
        expect(fullCodes.irPower, 'power_code');
        expect(fullCodes.irTempUp, 'temp_up_code');
        expect(fullCodes.irTempDown, 'temp_down_code');
        expect(fullCodes.irAuto, 'auto_code');
        expect(fullCodes.irCool, 'cool_code');
        expect(fullCodes.irHeat, 'heat_code');
        expect(fullCodes.irEco, 'eco_code');
        expect(fullCodes.irDry, 'dry_code');
        expect(fullCodes.irFanQuiet, 'fan_quiet_code');
        expect(fullCodes.irFanLow, 'fan_low_code');
        expect(fullCodes.irFanMed, 'fan_med_code');
        expect(fullCodes.irFanHigh, 'fan_high_code');
        expect(fullCodes.irFanAuto, 'fan_auto_code');
        expect(fullCodes.irSwingV, 'swing_v_code');
        expect(fullCodes.irSwingH, 'swing_h_code');
        expect(fullCodes.irPlasmacluster, 'plasma_code');
        expect(fullCodes.irSuperJet, 'superjet_code');
        expect(fullCodes.irCoanda, 'coanda_code');
        expect(fullCodes.irMyArea, 'myarea_code');
        expect(fullCodes.irDisplay, 'display_code');
        expect(fullCodes.irClean, 'clean_code');
      });
    });

    // ── copyWith ───────────────────────────────────────────────────────────────
    group('copyWith', () {
      test('returns same values when no args passed', () {
        final copy = fullCodes.copyWith();
        expect(copy, equals(fullCodes));
      });

      test('copyWith updates irPower', () {
        final copy = fullCodes.copyWith(irPower: 'new_power');
        expect(copy.irPower, 'new_power');
        expect(copy.irTempUp, fullCodes.irTempUp); // unchanged
      });

      test('copyWith clears irPower to null', () {
        final copy = fullCodes.copyWith(irPower: null);
        expect(copy.irPower, isNull);
        expect(copy.irTempUp, fullCodes.irTempUp); // unchanged
      });

      test('copyWith updates irTempUp', () {
        final copy = fullCodes.copyWith(irTempUp: 'new_temp_up');
        expect(copy.irTempUp, 'new_temp_up');
      });

      test('copyWith updates irTempDown', () {
        final copy = fullCodes.copyWith(irTempDown: 'new_temp_down');
        expect(copy.irTempDown, 'new_temp_down');
      });

      test('copyWith updates irAuto', () {
        final copy = fullCodes.copyWith(irAuto: 'new_auto');
        expect(copy.irAuto, 'new_auto');
      });

      test('copyWith updates irCool', () {
        final copy = fullCodes.copyWith(irCool: 'new_cool');
        expect(copy.irCool, 'new_cool');
      });

      test('copyWith updates irHeat', () {
        final copy = fullCodes.copyWith(irHeat: 'new_heat');
        expect(copy.irHeat, 'new_heat');
      });

      test('copyWith updates irEco', () {
        final copy = fullCodes.copyWith(irEco: 'new_eco');
        expect(copy.irEco, 'new_eco');
      });

      test('copyWith updates irDry', () {
        final copy = fullCodes.copyWith(irDry: 'new_dry');
        expect(copy.irDry, 'new_dry');
      });

      test('copyWith updates irFanQuiet', () {
        final copy = fullCodes.copyWith(irFanQuiet: 'new_fan_quiet');
        expect(copy.irFanQuiet, 'new_fan_quiet');
      });

      test('copyWith updates irFanLow', () {
        final copy = fullCodes.copyWith(irFanLow: 'new_fan_low');
        expect(copy.irFanLow, 'new_fan_low');
      });

      test('copyWith updates irFanMed', () {
        final copy = fullCodes.copyWith(irFanMed: 'new_fan_med');
        expect(copy.irFanMed, 'new_fan_med');
      });

      test('copyWith updates irFanHigh', () {
        final copy = fullCodes.copyWith(irFanHigh: 'new_fan_high');
        expect(copy.irFanHigh, 'new_fan_high');
      });

      test('copyWith updates irFanAuto', () {
        final copy = fullCodes.copyWith(irFanAuto: 'new_fan_auto');
        expect(copy.irFanAuto, 'new_fan_auto');
      });

      test('copyWith updates irSwingV', () {
        final copy = fullCodes.copyWith(irSwingV: 'new_swing_v');
        expect(copy.irSwingV, 'new_swing_v');
      });

      test('copyWith updates irSwingH', () {
        final copy = fullCodes.copyWith(irSwingH: 'new_swing_h');
        expect(copy.irSwingH, 'new_swing_h');
      });

      test('copyWith updates irPlasmacluster', () {
        final copy = fullCodes.copyWith(irPlasmacluster: 'new_plasma');
        expect(copy.irPlasmacluster, 'new_plasma');
      });

      test('copyWith updates irSuperJet', () {
        final copy = fullCodes.copyWith(irSuperJet: 'new_superjet');
        expect(copy.irSuperJet, 'new_superjet');
      });

      test('copyWith updates irCoanda', () {
        final copy = fullCodes.copyWith(irCoanda: 'new_coanda');
        expect(copy.irCoanda, 'new_coanda');
      });

      test('copyWith updates irMyArea', () {
        final copy = fullCodes.copyWith(irMyArea: 'new_myarea');
        expect(copy.irMyArea, 'new_myarea');
      });

      test('copyWith updates irDisplay', () {
        final copy = fullCodes.copyWith(irDisplay: 'new_display');
        expect(copy.irDisplay, 'new_display');
      });

      test('copyWith updates irClean', () {
        final copy = fullCodes.copyWith(irClean: 'new_clean');
        expect(copy.irClean, 'new_clean');
      });

      test('copyWith on empty codes adds one field', () {
        const empty = AcIrCodes();
        final copy = empty.copyWith(irPower: 'power_added');
        expect(copy.irPower, 'power_added');
        expect(copy.irCool, isNull);
      });

      test('copyWith preserves all unchanged fields', () {
        final copy = fullCodes.copyWith(irPower: 'changed');
        expect(copy.irTempUp, fullCodes.irTempUp);
        expect(copy.irTempDown, fullCodes.irTempDown);
        expect(copy.irAuto, fullCodes.irAuto);
        expect(copy.irCool, fullCodes.irCool);
        expect(copy.irHeat, fullCodes.irHeat);
        expect(copy.irEco, fullCodes.irEco);
        expect(copy.irDry, fullCodes.irDry);
        expect(copy.irFanQuiet, fullCodes.irFanQuiet);
        expect(copy.irFanLow, fullCodes.irFanLow);
        expect(copy.irFanMed, fullCodes.irFanMed);
        expect(copy.irFanHigh, fullCodes.irFanHigh);
        expect(copy.irFanAuto, fullCodes.irFanAuto);
        expect(copy.irSwingV, fullCodes.irSwingV);
        expect(copy.irSwingH, fullCodes.irSwingH);
        expect(copy.irPlasmacluster, fullCodes.irPlasmacluster);
        expect(copy.irSuperJet, fullCodes.irSuperJet);
        expect(copy.irCoanda, fullCodes.irCoanda);
        expect(copy.irMyArea, fullCodes.irMyArea);
        expect(copy.irDisplay, fullCodes.irDisplay);
        expect(copy.irClean, fullCodes.irClean);
      });
    });

    // ── Equatable (props / equality) ──────────────────────────────────────────
    group('equality (Equatable)', () {
      test('two identical AcIrCodes are equal', () {
        const a = AcIrCodes(irPower: 'p', irCool: 'c');
        const b = AcIrCodes(irPower: 'p', irCool: 'c');
        expect(a, equals(b));
      });

      test('two AcIrCodes with different irPower are not equal', () {
        const a = AcIrCodes(irPower: 'p1');
        const b = AcIrCodes(irPower: 'p2');
        expect(a, isNot(equals(b)));
      });

      test('empty AcIrCodes are equal to each other', () {
        const a = AcIrCodes();
        const b = AcIrCodes();
        expect(a, equals(b));
      });

      test('props list has 21 elements', () {
        const codes = AcIrCodes();
        expect(codes.props.length, 21);
      });

      test('full codes are not equal to empty codes', () {
        const empty = AcIrCodes();
        expect(fullCodes, isNot(equals(empty)));
      });
    });
  });
}
