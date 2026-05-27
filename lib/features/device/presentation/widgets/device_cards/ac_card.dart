import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AcCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const AcCard({super.key, required this.device, required this.onToggle});

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
    final breezeW = 220 * m.scale;
    final breezeH = 16 * m.scale;
    final titleSize = (20 * m.scale).clamp(15.0, 20.0);
    final tempSize = (16 * m.scale).clamp(13.0, 18.0);

    return SizedBox(
      width: m.cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.symmetric(
          horizontal: (20 * m.scale).clamp(12.0, 20.0),
          vertical: (10 * m.scale).clamp(6.0, 10.0),
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
                SizedBox(width: (8 * m.scale).clamp(4.0, 8.0)),
                // Custom Switch matching the screenshot
                GlassSwitch(
                  onToggle: onToggle,
                  isDeviceOn: isDeviceOn,
                  scale: m.scale,
                ),
              ],
            ),

            SizedBox(height: (20 * m.scale).clamp(12.0, 20.0)),

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
                          onPressed: () {
                            // TODO: call update device temp API
                          },
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
                                            ? const Color(0xFF00E5FF)
                                            : const Color(0xFF334155),
                                        borderRadius: BorderRadius.circular(
                                          1.5,
                                        ),
                                        boxShadow: isDeviceOn
                                            ? [
                                                BoxShadow(
                                                  color: const Color(
                                                    0xFF00E5FF,
                                                  ).withValues(alpha: 0.8),
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
                                height: breezeH,
                                margin: EdgeInsets.only(top: 4 * m.scale),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFF00E5FF,
                                      ).withValues(alpha: 0.15),
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
                          onPressed: () {
                            // TODO: call update device temp API
                          },
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
                    device.mode == 'Eco mode'
                        ? Icons.eco_outlined
                        : Icons.wb_sunny_outlined,
                    device.mode ?? 'Auto mode',
                    m.scale,
                  ),
                ),
                SizedBox(width: (12 * m.scale).clamp(8.0, 12.0)),
                Expanded(
                  child: _buildBottomStat(
                    Icons.access_time,
                    _formatRunningTime(device.coolingTime),
                    m.scale,
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

  Widget _buildBottomStat(IconData icon, String value, double scale) {
    final padH = (16 * scale).clamp(10.0, 16.0);
    final padV = (14 * scale).clamp(10.0, 14.0);
    final iconSize = (18 * scale).clamp(14.0, 18.0);
    final fontSize = (13 * scale).clamp(11.0, 13.0);

    return Container(
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
          Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: iconSize),
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
