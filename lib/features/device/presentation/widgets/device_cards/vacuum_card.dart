import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class VacuumCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const VacuumCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 320,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (device.linkedDevicesCount != null && device.linkedDevicesCount! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${device.linkedDevicesCount} Devices Connected',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch(
                  value: device.isOn,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset(
                    'assets/images/robot_vacuum.png',
                    height: 190,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.cleaning_services_outlined,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 20,
                    child: _buildInfoChip('${device.filterStatus}%', 'Filter Status'),
                  ),
                  Positioned(
                    right: 1,
                    bottom: 20,
                    child: _buildInfoChip('${device.nextCleaning}', 'Next cleaning'),
                  ),
                  // Mock lines connecting chips to vacuum
                  Positioned(
                    left: 80,
                    top: 80,
                    child: Container(width: 40, height: 1, color: Colors.white24),
                  ),
                  Positioned(
                    right: 90,
                    bottom: 60,
                    child: Container(width: 40, height: 1, color: Colors.white24),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildBottomStat(Icons.square_foot_outlined, '${device.areaCleaned}m²', 'Area'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBottomStat(Icons.access_time, '${device.cleaningTime}m', 'Time'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBottomStat(Icons.battery_charging_full, '${device.batteryLevel}%', 'Battery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBottomStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 16),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  label,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 9),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
