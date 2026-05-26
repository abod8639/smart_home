import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/device_entity.dart';

class AcCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const AcCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
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
                    const Text('Full house', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
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
              child: Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Simulated glowing ring
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: SweepGradient(
                            colors: [
                              AppTheme.primaryBlue,
                              AppTheme.primaryPurple,
                              AppTheme.primaryBlue,
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cardBackground,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${device.temperature}°',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const Text(
                              'Temperature',
                              style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryPurple,
                          ),
                          child: const Icon(Icons.settings, color: Colors.white, size: 12),
                        ),
                      ),
                      Positioned(
                        bottom: 5,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryBlue,
                          ),
                          child: const Icon(Icons.ac_unit, color: Colors.white, size: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(child: _buildBottomStat(Icons.wb_sunny_outlined, device.mode ?? '', 'Auto mood')),
                const SizedBox(width: 12),
                Expanded(child: _buildBottomStat(Icons.access_time, '${device.coolingTime} min', 'Cooling time')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12), overflow: TextOverflow.ellipsis),
                Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 9), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
