import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class FanSpeedCard extends ConsumerWidget {
  final DeviceEntity device;
  final DashboardController controller;
  final String currentFanSpeed;
  final ValueChanged<String> onFanSpeedChanged;

  const FanSpeedCard({
    super.key,
    required this.device,
    required this.controller,
    required this.currentFanSpeed,
    required this.onFanSpeedChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final speeds = ['Quiet', 'Low', 'Medium', 'High', 'Auto'];
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wind_power_outlined, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Fan Speed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha:0.04)),
            ),
            child: Row(
              children: speeds.map((speed) {
                final isSelected = currentFanSpeed == speed;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      onFanSpeedChanged(speed);
                      final String? irCode = switch (speed) {
                        'Quiet' => device.irFanQuiet,
                        'Low' => device.irFanLow,
                        'Medium' => device.irFanMed,
                        'High' => device.irFanHigh,
                        'Auto' => device.irFanAuto,
                        _ => null,
                      };
                      if (irCode != null) {
                        controller.sendIrCommand(context, irCode);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fan Speed' ': ' + 'Fan speed not set to $speed')));
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withValues(alpha:0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryBlue.withValues(alpha:0.4), width: 1.2)
                            : null,
                      ),
                      child: Text(
                        speed,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryBlue : Colors.white60,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
