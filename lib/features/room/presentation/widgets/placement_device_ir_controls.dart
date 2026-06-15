import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'ir_record_row.dart';

/// Widget for displaying and managing IR remote command learning controls.
class PlacementDeviceIrControls extends ConsumerWidget {
  /// The device entity whose IR commands are managed.
  final DeviceEntity device;

  /// The controller for dashboard operations.
  final DashboardController dashboardController;

  /// Creates a [PlacementDeviceIrControls].
  const PlacementDeviceIrControls({
    super.key,
    required this.device,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (device.type != DeviceType.airConditioner) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(color: Colors.white10),
        const SizedBox(height: 12),
        const Text(
          'IR Remote Codes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'You can copy and save the air conditioner remote buttons to control it directly through the ESP32 sensor.',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
        ),
        const SizedBox(height: 16),
        
        IrRecordRow(
          device: device,
          label: 'Temp Up',
          savedValue: device.irTempUp,
          fieldKey: 'irTempUp',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Temp Down',
          savedValue: device.irTempDown,
          fieldKey: 'irTempDown',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Power',
          savedValue: device.irPower,
          fieldKey: 'irPower',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Auto Mode',
          savedValue: device.irAuto,
          fieldKey: 'irAuto',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Cool Mode',
          savedValue: device.irCool,
          fieldKey: 'irCool',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Heat Mode',
          savedValue: device.irHeat,
          fieldKey: 'irHeat',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Eco Mode',
          savedValue: device.irEco,
          fieldKey: 'irEco',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Dry Mode',
          savedValue: device.irDry,
          fieldKey: 'irDry',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Fan Quiet',
          savedValue: device.irFanQuiet,
          fieldKey: 'irFanQuiet',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Fan Low',
          savedValue: device.irFanLow,
          fieldKey: 'irFanLow',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Fan Med',
          savedValue: device.irFanMed,
          fieldKey: 'irFanMed',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Fan High',
          savedValue: device.irFanHigh,
          fieldKey: 'irFanHigh',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Fan Auto',
          savedValue: device.irFanAuto,
          fieldKey: 'irFanAuto',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Swing Vertical',
          savedValue: device.irSwingV,
          fieldKey: 'irSwingV',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Swing Horizontal',
          savedValue: device.irSwingH,
          fieldKey: 'irSwingH',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Plasmacluster',
          savedValue: device.irPlasmacluster,
          fieldKey: 'irPlasmacluster',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Super Jet',
          savedValue: device.irSuperJet,
          fieldKey: 'irSuperJet',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Coanda',
          savedValue: device.irCoanda,
          fieldKey: 'irCoanda',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'My Area',
          savedValue: device.irMyArea,
          fieldKey: 'irMyArea',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Display',
          savedValue: device.irDisplay,
          fieldKey: 'irDisplay',
          dashboardController: dashboardController,
        ),
        const SizedBox(height: 10),
        IrRecordRow(
          device: device,
          label: 'Clean',
          savedValue: device.irClean,
          fieldKey: 'irClean',
          dashboardController: dashboardController,
        ),
      ],
    );
  }
}
