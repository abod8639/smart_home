import 'package:flutter/material.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/glass_switch.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/widgets/ac_visualizer.dart';

class AcCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;
  final VoidCallback onIncreaseTemp;
  final VoidCallback onDecreaseTemp;
  /// Called when the user picks a mode. Receives the selected mode label.
  final void Function(String mode)? onModeChange;

  const AcCard({
    super.key,
    required this.device,
    required this.onToggle,
    required this.onIncreaseTemp,
    required this.onDecreaseTemp,
    this.onModeChange,
  });

  static _AcCardMetrics _metrics(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final double cardWidth;
    if (Responsive.isMobile(context)) {
      cardWidth = (sw * 0.82).clamp(240.0, 320.0);
    } else if (Responsive.isTablet(context)) {
      cardWidth = 320.0;
    } else {
      cardWidth = 340.0;
    }
    final scale = (cardWidth / 340.0).clamp(0.7, 1.0);
    return _AcCardMetrics(cardWidth: cardWidth, scale: scale);
  }

  @override
  Widget build(BuildContext context) {
    final isDeviceOn = device.isOn;
    final m = _metrics(context);
    final titleSize = (20 * m.scale).clamp(14.0, 18.0);

    return SizedBox(
      width: m.cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.symmetric(
          horizontal: (20 * m.scale).clamp(10.0, 18.0),
          vertical: (1 * m.scale).clamp(5.0, 9.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Name, Subtitle & Custom Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: titleSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (device.linkedDevicesCount != null && device.linkedDevicesCount! > 0) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${device.linkedDevicesCount} linked devices',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Custom Switch matching the screenshot
                GlassSwitch(
                  onToggle: onToggle,
                  isDeviceOn: isDeviceOn,
                  scale: m.scale,
                ),
              ],
            ),

            // Middle Area: Custom Drawn AC Unit
            Expanded(
              child: AcVisualizer(
                device: device,
                onDecreaseTemp: onDecreaseTemp,
                onIncreaseTemp: onIncreaseTemp,
                scale: m.scale,
              ),
            ),
            
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: _buildBottomStat(
                    icon: _modeIcon(device.mode),
                    value: device.mode ?? 'Auto mode',
                    scale: m.scale,
                    onTap: () => _showModeSheet(context),
                    iconColor: _modeColor(device.mode),
                  ),
                ),
                Expanded(
                  child: _buildBottomStat(
                    icon: Icons.access_time,
                    value: _formatRunningTime(device.coolingTime),
                    scale: m.scale,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  IconData _modeIcon(String? mode) {
    switch (mode) {
      case 'Eco mode':  return Icons.eco_outlined;
      case 'Heat mode': return Icons.whatshot_outlined;
      case 'Cool mode': return Icons.ac_unit_outlined;
      default:          return Icons.autorenew_outlined; // Auto mode
    }
  }

  /// Returns the accent colour that matches the current AC mode.
  Color _modeColor(String? mode) {
    switch (mode) {
      case 'Cool mode': return const Color(0xFF60A5FA); // blue
      case 'Heat mode': return const Color(0xFFFB923C); // orange
      case 'Eco mode':  return const Color(0xFF4ADE80); // green
      default:          return const Color(0xFF00E5FF); // cyan – Auto
    }
  }

  void _showModeSheet(BuildContext context) {
    const modes = [
      _AcMode('Auto mode',  Icons.autorenew_outlined,  Color(0xFF00E5FF)),
      _AcMode('Cool mode',  Icons.ac_unit_outlined,    Color(0xFF60A5FA)),
      _AcMode('Heat mode',  Icons.whatshot_outlined,   Color(0xFFFB923C)),
      _AcMode('Eco mode',   Icons.eco_outlined,        Color(0xFF4ADE80)),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Select Mode / اختر الوضع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...modes.map((m) {
              final isSelected = (device.mode ?? 'Auto mode') == m.label;
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  onModeChange?.call(m.label);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? m.color.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? m.color.withValues(alpha: 0.6) : Colors.white12,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(m.icon, color: isSelected ? m.color : Colors.white54, size: 22),
                      const SizedBox(width: 12),
                      Text(
                        m.label,
                        style: TextStyle(
                          color: isSelected ? m.color : Colors.white70,
                          fontSize: 14,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Icon(Icons.check_circle, color: m.color, size: 18),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // Format running time from minutes to a readable string (e.g. 35 min or 1h 15m)
  String _formatRunningTime(int? totalMinutes) {
    if (totalMinutes == null || totalMinutes == 0) return '0 min';
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m';
      } else {
        return '${hours}h';
      }
    } else {
      return '$minutes min';
    }
  }

  Widget _buildBottomStat({
    required IconData icon,
    required String value,
    required double scale,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final padH = (16 * scale).clamp(10.0, 16.0);
    final padV = (1 * scale).clamp(3.0, 14.0);
    final iconSize = (18 * scale).clamp(14.0, 18.0);
    final fontSize = (13 * scale).clamp(11.0, 13.0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.04),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: iconSize),
            SizedBox(width: (8 * scale).clamp(4.0, 8.0)),
            Flexible(
              child: Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: fontSize,
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

class _AcCardMetrics {
  final double cardWidth;
  final double scale;

  const _AcCardMetrics({required this.cardWidth, required this.scale});
}

/// Simple data class for AC mode options in the bottom sheet.
class _AcMode {
  final String label;
  final IconData icon;
  final Color color;

  const _AcMode(this.label, this.icon, this.color);
}
