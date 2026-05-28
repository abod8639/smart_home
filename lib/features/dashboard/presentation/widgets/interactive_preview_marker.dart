import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class InteractivePreviewMarker extends StatelessWidget {
  final DeviceEntity device;
  final double width;
  final double height;

  const InteractivePreviewMarker({
    super.key,
    required this.device,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = device.isOn;
    IconData iconData;
    switch (device.type) {
      case DeviceType.lamp:
        iconData = Icons.lightbulb_outline;
        break;
      case DeviceType.airConditioner:
        iconData = Icons.ac_unit;
        break;
      case DeviceType.vacuum:
        iconData = Icons.cleaning_services_rounded;
        break;
      case DeviceType.door:
        iconData = device.isLocked ?? true ? Icons.lock_outline : Icons.lock_open_outlined;
        break;
      case DeviceType.rgb:
        iconData = Icons.wb_incandescent_rounded;
        break;
    }

    final isDoor = device.type == DeviceType.door;
    final isLocked = device.isLocked ?? true;
    final isRgbOn = device.type == DeviceType.rgb && isOn;

    Color markerColor;
    Color borderColor;
    Color glowColor;
    bool showGlow = isOn || (isDoor && !isLocked);

    if (isDoor) {
      markerColor = isLocked
          ? Colors.redAccent.withValues(alpha: 0.2)
          : Colors.greenAccent.withValues(alpha: 0.2);
      borderColor = isLocked
          ? Colors.redAccent.withValues(alpha: 0.6)
          : Colors.greenAccent.withValues(alpha: 0.6);
      glowColor = isLocked
          ? Colors.redAccent.withValues(alpha: 0.3)
          : Colors.greenAccent.withValues(alpha: 0.3);
    } else if (isRgbOn) {
      final r = device.rgbR ?? 255;
      final g = device.rgbG ?? 0;
      final b = device.rgbB ?? 128;
      markerColor = Color.fromRGBO(r, g, b, 0.45);
      borderColor = Color.fromRGBO(r, g, b, 0.8);
      glowColor = Color.fromRGBO(r, g, b, 0.4);
    } else {
      markerColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05);
      borderColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.15);
      glowColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.transparent;
    }

    return Hero(
      tag: device.id,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: markerColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isOn || (isDoor && !isLocked) ? 2.0 : 1.0,
          ),
          boxShadow: showGlow
              ? [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(6.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    iconData,
                    color: isOn || (isDoor && !isLocked) ? AppTheme.primaryBlue : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.name,
                    style: TextStyle(
                      shadows: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          spreadRadius: 10,
                        )
                      ],
                      color: isOn || (isDoor && !isLocked) ? AppTheme.primaryBlue : Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
