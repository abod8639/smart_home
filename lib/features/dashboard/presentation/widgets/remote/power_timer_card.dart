import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

/// A card widget representing the Power toggle and Sleep Timer configuration for an AC.
class PowerTimerCard extends StatelessWidget {
  /// The device entity whose power state is managed.
  final DeviceEntity device;

  /// The dashboard controller instance.
  final DashboardController controller;

  /// The active sleep timer duration remaining, if any.
  final Duration? timeLeft;

  /// Callback when the sleep timer card is tapped.
  final VoidCallback onTimerTap;

  /// Creates a [PowerTimerCard].
  const PowerTimerCard({
    super.key,
    required this.device,
    required this.controller,
    required this.timeLeft,
    required this.onTimerTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDeviceOn = device.isOn;
    return Row(
      children: [
        // Power Card
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleDevice(device.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDeviceOn
                      ? [
                          const Color(0xFFEF4444).withValues(alpha: 0.18),
                          const Color(0xFFEF4444).withValues(alpha: 0.08),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDeviceOn
                      ? const Color(0xFFEF4444).withValues(alpha: 0.5)
                      : Colors.white10,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    color: isDeviceOn ? const Color(0xFFEF4444) : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDeviceOn ? 'ON' : 'OFF',
                    style: TextStyle(
                      color: isDeviceOn ? const Color(0xFFEF4444) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Sleep Timer Card
        Expanded(
          child: GestureDetector(
            onTap: onTimerTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: timeLeft != null
                      ? [
                          AppTheme.primaryBlue.withValues(alpha: 0.18),
                          AppTheme.primaryBlue.withValues(alpha: 0.08),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: timeLeft != null
                      ? AppTheme.primaryBlue.withValues(alpha: 0.5)
                      : Colors.white10,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: timeLeft != null ? AppTheme.primaryBlue : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeLeft != null ? _formatDuration(timeLeft!) : 'Sleep Timer',
                    style: TextStyle(
                      color: timeLeft != null ? AppTheme.primaryBlue : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m left';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins > 0) {
        return '${hours}h ${mins}m';
      }
      return '${hours}h left';
    }
  }
}
