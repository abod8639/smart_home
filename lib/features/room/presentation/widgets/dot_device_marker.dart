import 'package:flutter/material.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class DotDeviceMarker extends StatelessWidget {
  final DeviceEntity device;
  final bool isSelected;
  final Color accentColor;
  final IconData icon;
  final Animation<double> glowAnimation;
  final Duration animDuration;
  final VoidCallback onTap;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;

  const DotDeviceMarker({
    super.key,
    required this.device,
    required this.isSelected,
    required this.accentColor,
    required this.icon,
    required this.glowAnimation,
    required this.animDuration,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        // ── Pulsing Glowing Dot ─────────────────────────────────────────────
        GestureDetector(
          onTap: onTap,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          child: AnimatedBuilder(
            animation: glowAnimation,
            builder: (context, child) {
              final glow = glowAnimation.value;
              return AnimatedContainer(
                duration: animDuration,
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.65),
                  border: Border.all(
                    color: isSelected ? Colors.amber : accentColor,
                    width: isSelected ? 2.0 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? Colors.amber.withValues(alpha: 0.6)
                          : accentColor.withValues(alpha: device.isOn ? 0.6 : 0.25),
                      blurRadius: glow + (isSelected ? 4 : 0),
                      spreadRadius: isSelected ? 2 : 0,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    icon,
                    color: isSelected
                        ? Colors.amber
                        : (device.isOn ? accentColor : Colors.white70),
                    size: 16,
                  ),
                ),
              );
            },
          ),
        ),

        // ── Device Name Tag ────────────────────────────────────────────────
        Positioned(
          bottom: -22,
          left: -50,
          right: -50,
          child: IgnorePointer(
            child: Center(
              child: AnimatedContainer(
                duration: animDuration,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected
                        ? Colors.amber.withValues(alpha: 0.5)
                        : accentColor.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  device.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 2),
                    ],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
