import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AirSwingCard extends StatelessWidget {
  final DeviceEntity device;
  final DashboardController controller;
  final bool verticalSwing;
  final bool horizontalSwing;
  final ValueChanged<bool> onVerticalSwingChanged;
  final ValueChanged<bool> onHorizontalSwingChanged;

  const AirSwingCard({
    super.key,
    required this.device,
    required this.controller,
    required this.verticalSwing,
    required this.horizontalSwing,
    required this.onVerticalSwingChanged,
    required this.onHorizontalSwingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_calls_rounded, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Air Swing',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSwingToggleButton(
                  icon: Icons.unfold_more_rounded,
                  label: 'Vertical Swing',
                  isSelected: verticalSwing,
                  onTap: () {
                    onVerticalSwingChanged(!verticalSwing);
                    if (device.irSwingV != null) {
                      controller.sendIrCommand(device.irSwingV!);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSwingToggleButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Horizontal Swing',
                  isSelected: horizontalSwing,
                  onTap: () {
                    onHorizontalSwingChanged(!horizontalSwing);
                    if (device.irSwingH != null) {
                      controller.sendIrCommand(device.irSwingH!);
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwingToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : Colors.white10,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.white60,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryBlue : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
