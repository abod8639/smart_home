import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AcCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const AcCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: GlassContainer(
        // padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            image:  DecorationImage(
              alignment: Alignment.center,
              fit: BoxFit.fitWidth,
              scale: 0.9,
              
              image: AssetImage(
                
                'assets/images/ac_unit.png'))
          ),
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

                    Positioned(
                      left: 0,
                      top: 20,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.thermostat, color: AppTheme.primaryBlue, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${device.temperature}°',
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
      ),
    );
  }

  Widget _buildBottomStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
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
