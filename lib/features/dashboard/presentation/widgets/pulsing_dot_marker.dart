import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class PulsingDotMarker extends StatefulWidget {
  final DeviceEntity device;
  final bool isSelected;
  final VoidCallback? onTap;
  final GestureDragStartCallback? onPanStart;
  final GestureDragUpdateCallback? onPanUpdate;
  final GestureDragEndCallback? onPanEnd;

  const PulsingDotMarker({
    super.key,
    required this.device,
    this.isSelected = false,
    this.onTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
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
    IconData iconData;
    switch (widget.device.type) {
      case DeviceType.lamp:
        iconData = isOn ? Icons.lightbulb : Icons.lightbulb_outline;
        break;
      case DeviceType.airConditioner:
        iconData = Icons.ac_unit;
        break;
      case DeviceType.vacuum:
        iconData = Icons.cleaning_services_rounded;
        break;
      case DeviceType.door:
        iconData = widget.device.isLocked ?? true
            ? Icons.lock_rounded
            : Icons.lock_open_rounded;
        break;
      case DeviceType.rgb:
        iconData = Icons.wb_incandescent_rounded;
        break;
    }

    final isDoor = widget.device.type == DeviceType.door;
    final isLocked = widget.device.isLocked ?? true;
    final isRgbOn = widget.device.type == DeviceType.rgb && isOn;

    Color accentColor;
    if (isDoor) {
      accentColor = isLocked ? Colors.redAccent : Colors.greenAccent;
    } else if (isRgbOn) {
      accentColor = Color.fromRGBO(widget.device.rgbR ?? 255, widget.device.rgbG ?? 100, widget.device.rgbB ?? 200, 1.0);
    } else {
      accentColor = isOn ? AppTheme.primaryBlue : Colors.white54;
    }

    final showGlow = isOn || (isDoor && !isLocked);

    return Hero(
      tag: widget.device.id,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          GestureDetector(
            onTap: widget.onTap,
            onPanStart: widget.onPanStart,
            onPanUpdate: widget.onPanUpdate,
            onPanEnd: widget.onPanEnd,
            child: AnimatedBuilder(
              animation: _glowAnimation,
              builder: (context, child) {
                final glow = _glowAnimation.value;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.65),
                    border: Border.all(
                      color: widget.isSelected ? Colors.amber : accentColor,
                      width: widget.isSelected ? 2.0 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.isSelected
                            ? Colors.amber.withValues(alpha: 0.6)
                            : accentColor.withValues(alpha: showGlow ? 0.6 : 0.25),
                        blurRadius: glow + (widget.isSelected ? 4 : 0),
                        spreadRadius: widget.isSelected ? 2 : 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      iconData,
                      color: widget.isSelected
                          ? Colors.amber
                          : (showGlow ? accentColor : Colors.white70),
                      size: 16,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            bottom: -22,
            left: -50,
            right: -50,
            child: IgnorePointer(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: widget.isSelected
                          ? Colors.amber.withValues(alpha: 0.5)
                          : accentColor.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    widget.device.name,
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
      ),
    );
  }
}
