import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/core/widgets/app_network_image.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/glass_switch.dart';

/// A control card widget for managing and viewing status of a robotic vacuum.
class VacuumCard extends StatelessWidget {
  /// The vacuum device entity representation.
  final DeviceEntity device;
  /// Callback executed when toggling the power state.
  final VoidCallback onToggle;

  /// Creates a constant [VacuumCard] instance.
  const VacuumCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double cardWidth = isMobile ? 260.0 : 300.0;
    final double innerPadding = isMobile ? 12.0 : 18.0;

    // Cast device to VacuumDeviceEntity safely (if it has fields)
    final vacuumDevice = device is VacuumDeviceEntity ? (device as VacuumDeviceEntity) : null;
    final batteryLevel = vacuumDevice?.batteryLevel ?? 0;
    final areaCleaned = vacuumDevice?.areaCleaned ?? 0;
    final cleaningTime = vacuumDevice?.cleaningTime ?? 0;
    final filterStatus = vacuumDevice?.filterStatus ?? 0;
    final nextCleaning = vacuumDevice?.nextCleaning ?? '--';

    return SizedBox(
      width: cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.all(innerPadding),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (device.linkedDevicesCount != null && device.linkedDevicesCount! > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${device.linkedDevicesCount} Devices Connected',
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassSwitch(
                  onToggle: onToggle,
                  isDeviceOn: device.isOn,
                  scale: isMobile ? 0.85 : 1.0,
                ),
              ],
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final h = constraints.maxHeight;
                  final w = constraints.maxWidth;
                  final chipScale = (h / 125.0).clamp(0.65, 1.0);
                  
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      AppNetworkImage(
                        imageUrl: 'https://raw.githubusercontent.com/abod8639/media/main/smart_home/robot_vacuum.png',
                        height: h * 0.9,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, error, stackTrace) => Icon(
                          Icons.cleaning_services_outlined,
                          size: (h * 0.5).clamp(40.0, 80.0),
                          color: Colors.white24,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: (h * 0.1).clamp(0.0, 20.0),
                        child: Transform.scale(
                          scale: chipScale,
                          alignment: Alignment.topLeft,
                          child: _buildInfoChip('$filterStatus%', 'Filter Status'),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: (h * 0.1).clamp(0.0, 20.0),
                        child: Transform.scale(
                          scale: chipScale,
                          alignment: Alignment.bottomRight,
                          child: _buildInfoChip('$nextCleaning', 'Next cleaning'),
                        ),
                      ),
                      // Mock lines connecting chips to vacuum
                      Positioned(
                        left: w * 0.28,
                        top: h * 0.45,
                        child: Container(
                          width: w * 0.12, 
                          height: 1, 
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                      Positioned(
                        right: w * 0.28,
                        bottom: h * 0.38,
                        child: Container(
                          width: w * 0.12, 
                          height: 1, 
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildBottomStat(
                    Icons.square_foot_outlined, 
                    '${areaCleaned}m²', 
                    'Area',
                    isMobile,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildBottomStat(
                    Icons.access_time, 
                    '${cleaningTime}m', 
                    'Time',
                    isMobile,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildBottomStat(
                    Icons.battery_charging_full, 
                    '$batteryLevel%', 
                    'Battery',
                    isMobile,
                  ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value, 
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold, 
              fontSize: 12,
            ),
          ),
          Text(
            label, 
            style: const TextStyle(
              color: AppTheme.textGrey, 
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStat(IconData icon, String value, String label, bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 6, 
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textGrey, size: 14),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                  style: const TextStyle(
                    color: AppTheme.textGrey, 
                    fontSize: 8,
                  ),
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
