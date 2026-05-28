import 'package:flutter/material.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class PulsingDotMarker extends StatefulWidget {
  final DeviceEntity device;
  final Color accentColor;
  final IconData iconData;

  const PulsingDotMarker({
    super.key,
    required this.device,
    required this.accentColor,
    required this.iconData,
  });

  @override
  State<PulsingDotMarker> createState() => _PulsingDotMarkerState();
}

class _PulsingDotMarkerState extends State<PulsingDotMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 4.0, end: 14.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOn = widget.device.isOn;
    final isDoor = widget.device.type == DeviceType.door;
    final isLocked = widget.device.isLocked ?? true;
    final showGlow = isOn || (isDoor && !isLocked);

    return Hero(
      tag: widget.device.id,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              final glow = _glowAnimation.value;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.65),
                  border: Border.all(
                    color: widget.accentColor,
                    width: 1.5,
                  ),
                  boxShadow: showGlow
                      ? [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.6),
                            blurRadius: glow,
                            spreadRadius: 1,
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Icon(
                    widget.iconData,
                    color: showGlow ? widget.accentColor : Colors.white70,
                    size: 14,
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: -20,
            left: -45,
            right: -45,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white10.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: widget.accentColor.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    widget.device.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(color: Colors.black, blurRadius: 1),
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
      ),
    );
  }
}
