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
    final isDeviceOn = device.isOn;

    return Expanded(
      flex: 3,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name and Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name, 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('Full house', style: TextStyle(color: AppTheme.textGrey, fontSize: 11)),
                  ],
                ),
                Switch(
                  value: isDeviceOn,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                ),
              ],
            ),
            
            // Middle Area: AC Unit Image with dynamic glow & temperature indicator
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Blue glowing breeze effect behind AC when ON
                  if (isDeviceOn)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppTheme.primaryBlue.withValues(alpha: 0.2),
                            AppTheme.primaryBlue.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),

                  // AC Unit Asset
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDeviceOn ? 1.0 : 0.45,
                    child: Image.asset(
                      'assets/images/ac_unit.png', 
                      height: 140, 
                      fit: BoxFit.contain,
                    ),
                  ),

                  // Temperature Badge Overlay
                  Positioned(
                    left: 0,
                    top: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDeviceOn 
                              ? AppTheme.primaryBlue.withValues(alpha: 0.3) 
                              : Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.thermostat, 
                            color: isDeviceOn ? AppTheme.primaryBlue : AppTheme.textGrey, 
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${device.temperature}°',
                            style: const TextStyle(
                              color: Colors.white, 
                              fontSize: 14, 
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Area: Mode & Live Running Time Stats
            Row(
              children: [
                Expanded(
                  child: _buildBottomStat(
                    Icons.wb_sunny_outlined, 
                    device.mode ?? 'Auto', 
                    'Auto mode',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildBottomStat(
                    Icons.access_time, 
                    _formatRunningTime(device.coolingTime), 
                    'Running time',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format running time from seconds to a readable string (e.g. 35m 12s)
  String _formatRunningTime(int? totalSeconds) {
    if (totalSeconds == null || totalSeconds == 0) return '0s';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  Widget _buildBottomStat(IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                Text(
                  value, 
                  style: const TextStyle(
                    color: Colors.white, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 11,
                  ), 
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
