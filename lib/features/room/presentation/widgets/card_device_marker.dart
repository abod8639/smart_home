import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

/// Represents a visual card-based marker for a device.
class CardDeviceMarker extends StatelessWidget {
  /// The device entity represented by this marker.
  final DeviceEntity device;

  /// The width of the marker card.
  final double mW;

  /// The height of the marker card.
  final double mH;

  /// Whether this marker is currently selected.
  final bool isSelected;

  /// Whether this marker is currently being resized by user gestures.
  final bool isResizing;

  /// Transition animation duration.
  final Duration animDuration;

  /// Callback when the marker is tapped.
  final VoidCallback? onTap;

  /// Callback when a drag starts on this marker.
  final GestureDragStartCallback? onPanStart;

  /// Callback when a drag updates on this marker.
  final GestureDragUpdateCallback? onPanUpdate;

  /// Callback when a drag ends on this marker.
  final GestureDragEndCallback? onPanEnd;

  /// Callback when a resize gesture starts.
  final GestureDragStartCallback? onResizeStart;

  /// Callback when a resize gesture updates.
  final GestureDragUpdateCallback? onResizeUpdate;

  /// Callback when a resize gesture ends.
  final GestureDragEndCallback? onResizeEnd;

  /// Creates a [CardDeviceMarker].
  const CardDeviceMarker({
    super.key,
    required this.device,
    required this.mW,
    required this.mH,
    this.isSelected = false,
    this.isResizing = false,
    this.animDuration = const Duration(milliseconds: 250),
    this.onTap,
    this.onPanStart,
    this.onPanUpdate,
    this.onPanEnd,
    this.onResizeStart,
    this.onResizeUpdate,
    this.onResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final isOn = device.isOn;
    IconData iconData;
    switch (device.type) {
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
        iconData = device.isLocked ?? true
            ? Icons.lock_rounded
            : Icons.lock_open_rounded;
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

    final isAcOn = device.type == DeviceType.airConditioner && isOn;
    Color activeColor = AppTheme.primaryBlue;

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
      activeColor = Color.fromARGB(255, r, g, b);
    } else if (isAcOn) {
      final acColor = _modeColor(device.mode);
      markerColor = acColor.withValues(alpha: 0.01);
      borderColor = acColor.withValues(alpha: 0.3);
      glowColor = acColor.withValues(alpha: 0.08);
      activeColor = acColor;
    } else {
      markerColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05);
      borderColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.25)
          : Colors.white.withValues(alpha: 0.15);
      glowColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.18)
          : Colors.transparent;
    }

    final iconSize = (mH * 0.28).clamp(14.0, 26.0);
    final labelSize = (mH * 0.11).clamp(7.5, 11.0);

    return Hero(
      tag: device.id,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Draggable body ───────────────────────────────────────────────────
          GestureDetector(
            onTap: onTap,
            onPanStart: onPanStart,
            onPanUpdate: onPanUpdate,
            onPanEnd: onPanEnd,
            child: AnimatedContainer(
              duration: animDuration,
              curve: Curves.easeInOut,
              width: mW,
              height: mH,
              decoration: BoxDecoration(
                color:   markerColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.amber : borderColor,
                  width: isSelected ? 2.5 : (isOn || (isDoor && !isLocked) ? 2.0 : 1.0),
                ),
                boxShadow: showGlow || isSelected
                    ? [
                        BoxShadow(
                          color: isSelected
                              ? Colors.amber.withValues(alpha: 0.45)
                              : glowColor,
                          blurRadius: isSelected ? 18 : 12,
                          spreadRadius: isSelected ? 3 : 2,
                        ),
                      ]
                    : [],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
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
                            color: isOn || (isDoor && !isLocked) ? activeColor : Colors.white70,
                            size: iconSize,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            device.name,
                            style: TextStyle(
                              shadows: const [
                                BoxShadow(
                                  blurStyle: BlurStyle.outer,
                                  color: Colors.black,
                                  blurRadius: 10,
                                  spreadRadius: 10,
                                
                                )
                              ],
                              color: isOn || (isDoor && !isLocked) ? activeColor : Colors.white70,
                              fontSize: labelSize,
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
            ),
          ),

          // ── Resize grip (only shown if resize callbacks are provided) ────────
          if (onResizeStart != null && onResizeUpdate != null && onResizeEnd != null)
            Positioned(
              right: -14,
              bottom: -14,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: onResizeStart,
                onPanUpdate: onResizeUpdate,
                onPanEnd: onResizeEnd,
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: isResizing ? 28 : 24,
                      height: isResizing ? 28 : 24,
                      decoration: BoxDecoration(
                        color: isResizing
                            ? Colors.amber
                            : isSelected
                                ? Colors.amber
                                : Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.35),
                            blurRadius: isResizing ? 8 : 4,
                            spreadRadius: isResizing ? 1 : 0,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.open_in_full_rounded,
                        size: 14,
                        color: isResizing || isSelected
                            ? Colors.black87
                            : AppTheme.backgroundDark,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _modeColor(String? mode) {
    switch (mode) {
      case 'Cool mode': return const Color(0xFF60A5FA); // blue
      case 'Heat mode': return const Color(0xFFFB923C); // orange
      case 'Eco mode':  return const Color(0xFF4ADE80); // green
      default:          return const Color(0xFF00E5FF); // cyan – Auto
    }
  }
}
