import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

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
      cardWidth = (sw * 0.82).clamp(240.0, 340.0);
    } else if (Responsive.isTablet(context)) {
      cardWidth = 340;
    } else {
      cardWidth = 380;
    }
    final scale = (cardWidth / 380).clamp(0.72, 1.0);
    return _AcCardMetrics(cardWidth: cardWidth, scale: scale);
  }

  @override
  Widget build(BuildContext context) {
    final isDeviceOn = device.isOn;
    final m = _metrics(context);
    final acW = 220 * m.scale;
    final acH = 66 * m.scale;
    final ventW = 180 * m.scale;
    final ventH = (4 * m.scale).clamp(2.0, 4.0);
    final breezeW = 180 * m.scale;
    final breezeH = 40 * m.scale;
    final titleSize = (20 * m.scale).clamp(15.0, 20.0);
    final tempSize = (16 * m.scale).clamp(13.0, 18.0);

    return SizedBox(
      width: m.cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.symmetric(
          horizontal: (20 * m.scale).clamp(12.0, 20.0),
          vertical: (1 * m.scale).clamp(6.0, 10.0),
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
                // SizedBox(width: (8 * m.scale).clamp(4.0, 8.0)),
                // Custom Switch matching the screenshot
                GlassSwitch(
                  onToggle: onToggle,
                  isDeviceOn: isDeviceOn,
                  scale: m.scale,
                ),
              ],
            ),

            // SizedBox(height: (20 * m.scale).clamp(12.0, 20.0)),

            // Middle Area: Custom Drawn AC Unit
            Expanded(
              child: Stack(
                children: [
                  // Central AC Unit & Breeze Visualizer
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.all(4 * m.scale),
                          constraints: BoxConstraints(
                            minWidth: 36 * m.scale,
                            minHeight: 36 * m.scale,
                          ),
                          onPressed: onDecreaseTemp,
                          icon: Icon(Icons.horizontal_rule, size: 22 * m.scale),
                          color: Colors.blueAccent,
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: (15 * m.scale).clamp(6.0, 15.0)),
                            // AC Body Shape
                            Container(
                              width: acW,
                              height: acH,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: isDeviceOn
                                      ? [
                                          const Color(0xFF1E293B),
                                          const Color(0xFF0F172A),
                                        ]
                                      : [
                                          const Color(0xFF1E293B),
                                          const Color(0xFF182235),
                                        ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isDeviceOn
                                      ? Colors.white.withValues(alpha: 0.12)
                                      : Colors.white.withValues(alpha: 0.05),
                                  width: 1,
                                ),
                                boxShadow: isDeviceOn
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.25,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  Center(
                                    child: Text(
                                      '${device.temperature}°',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: tempSize,
                                        fontWeight: FontWeight.bold,
                                        shadows: <Shadow>[
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.25,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Air vent / LED slit inside AC body
                                  Positioned(
                                    bottom: 4 * m.scale,
                                    child: Container(
                                      width: ventW,
                                      height: ventH,
                                      decoration: BoxDecoration(
                                        color: isDeviceOn
                                            ? _modeColor(device.mode)
                                            : const Color(0xFF334155),
                                        borderRadius: BorderRadius.circular(
                                          1.5,
                                        ),
                                        boxShadow: isDeviceOn
                                            ? [
                                                BoxShadow(
                                                  color: _modeColor(device.mode)
                                                      .withValues(alpha: 0.8),
                                                  blurRadius: 4,
                                                  spreadRadius: 0.5,
                                                ),
                                              ]
                                            : null,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Dynamic blowing air breeze below AC
                            AnimatedOpacity(
                              duration: const Duration(milliseconds: 300),
                              opacity: isDeviceOn ? 1.0 : 0.0,
                              child: Container(
                                width: breezeW,
                                height: Responsive.isMobile(context) ?  breezeH-16: breezeH,
                                margin: EdgeInsets.only(top: 4 * m.scale),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      _modeColor(device.mode).withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.all(4 * m.scale),
                          constraints: BoxConstraints(
                            minWidth: 36 * m.scale,
                            minHeight: 36 * m.scale,
                          ),
                          onPressed: onIncreaseTemp,
                          icon: Icon(Icons.add, size: 22 * m.scale),
                          color: Colors.red,
                        ),
                      ],
                    ),
                  ),
                ],
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
                    iconColor: _modeColor(device.mode)
                  ),
                ),
                // SizedBox(width: (12 * m.scale).clamp(8.0, 12.0)),
                Expanded(
                  child: _buildBottomStat(
                    icon: Icons.access_time,
                    value: _formatRunningTime(device.coolingTime),
                    scale: m.scale,
                  ),
                ),
              ],
            ),
            // Bottom Area: Mode & Live Running Time Stats
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
    Color? iconColor
  }) {
    final padH = (16 * scale).clamp(10.0, 16.0);
    final padV = (14 * scale).clamp(10.0, 14.0);
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
            Icon(icon, color: 
          iconColor
            , size: iconSize),
            SizedBox(width: (8 * scale).clamp(4.0, 8.0)),
            Flexible(
              child:  Text(
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

class GlassSwitch extends StatelessWidget {
  const GlassSwitch({
    super.key,
    required this.onToggle,
    required this.isDeviceOn,
    this.scale = 1.0,
  });

  final VoidCallback onToggle;
  final bool isDeviceOn;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final w = (52 * scale).clamp(44.0, 52.0);
    final h = (28 * scale).clamp(24.0, 28.0);
    final knob = (20 * scale).clamp(16.0, 20.0);
    final radius = h / 2;

    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: w,
        height: h,
        padding: EdgeInsets.all((4 * scale).clamp(3.0, 4.0)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          color: isDeviceOn
              ? AppTheme.primaryBlue
              : const Color(0xFF334155),
          boxShadow: isDeviceOn
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(
                      81,
                      0,
                      229,
                      255,
                    ).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          alignment: isDeviceOn
              ? Alignment.centerRight
              : Alignment.centerLeft,
          child: Container(
            width: knob,
            height: knob,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
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
