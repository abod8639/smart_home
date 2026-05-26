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
    return Expanded(
      flex: 4,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    const Text('3 Device', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  ],
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (_) => onToggle(),
                  activeColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.asset('assets/images/robot_vacuum.png', height: 120),
                  Positioned(
                    left: 20,
                    top: 40,
                    child: _buildInfoChip('${device.filterStatus}%', 'Filter Status'),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 40,
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
                _buildBottomStat(Icons.square_foot_outlined, '${device.areaCleaned}m²', 'Area cleaned'),
                _buildBottomStat(Icons.access_time, '${device.cleaningTime} min', 'Cleaning time'),
                _buildBottomStat(Icons.battery_charging_full, '${device.batteryLevel}%', 'battery level'),
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
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}
