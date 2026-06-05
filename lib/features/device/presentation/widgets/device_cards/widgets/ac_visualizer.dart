import 'package:flutter/material.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class AcVisualizer extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onDecreaseTemp;
  final VoidCallback onIncreaseTemp;
  final double scale;

  const AcVisualizer({
    super.key,
    required this.device,
    required this.onDecreaseTemp,
    required this.onIncreaseTemp,
    required this.scale,
  });

  Color _modeColor(String? mode) {
    switch (mode) {
      case 'Cool mode': return const Color(0xFF60A5FA); // blue
      case 'Heat mode': return const Color(0xFFFB923C); // orange
      case 'Eco mode':  return const Color(0xFF4ADE80); // green
      default:          return const Color(0xFF00E5FF); // cyan – Auto
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDeviceOn = device.isOn;
    final acW = 210 * scale;
    final acH = 59 * scale;
    final ventW = 180 * scale;
    final ventH = (4 * scale).clamp(2.0, 4.0);
    final breezeW = 180 * scale;
    final breezeH = 40 * scale;
    final tempSize = (16 * scale).clamp(13.0, 18.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.all(4 * scale),
          constraints: BoxConstraints(
            minWidth: 36 * scale,
            minHeight: 36 * scale,
          ),
          onPressed: onDecreaseTemp,
          icon: Icon(Icons.horizontal_rule, size: 22 * scale),
          color: Colors.blueAccent,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SizedBox(height: (15 * scale).clamp(6.0, 15.0)),
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
                    bottom: 4 * scale,
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
                height: Responsive.isMobile(context) ? breezeH - 16 : breezeH,
                margin: EdgeInsets.only(top: 4 * scale),
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
          padding: EdgeInsets.all(4 * scale),
          constraints: BoxConstraints(
            minWidth: 36 * scale,
            minHeight: 36 * scale,
          ),
          onPressed: onIncreaseTemp,
          icon: Icon(Icons.add, size: 22 * scale),
          color: Colors.red,
        ),
      ],
    );
  }
}
