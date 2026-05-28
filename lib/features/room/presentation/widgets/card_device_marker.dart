import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class CardDeviceMarker extends StatelessWidget {
  final DeviceEntity device;
  final bool isSelected;
  final Color accentColor;
  final IconData icon;
  final String statusLabel;
  final double mW;
  final double mH;
  final Duration animDuration;
  final bool isResizing;
  final VoidCallback onTap;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final GestureDragStartCallback onResizeStart;
  final GestureDragUpdateCallback onResizeUpdate;
  final GestureDragEndCallback onResizeEnd;

  const CardDeviceMarker({
    super.key,
    required this.device,
    required this.isSelected,
    required this.accentColor,
    required this.icon,
    required this.statusLabel,
    required this.mW,
    required this.mH,
    required this.animDuration,
    required this.isResizing,
    required this.onTap,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onResizeStart,
    required this.onResizeUpdate,
    required this.onResizeEnd,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = (mH * 0.28).clamp(14.0, 26.0);
    final labelSize = (mH * 0.11).clamp(7.5, 11.0);
    final statusSize = (mH * 0.085).clamp(6.5, 9.0);

    return Stack(
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
            curve: Curves.easeOut,
            width: mW,
            height: mH,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? Colors.amber : accentColor.withValues(alpha: 0.55),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.amber.withValues(alpha: 0.45)
                      : accentColor.withValues(alpha: 0.28),
                  blurRadius: isSelected ? 18 : 8,
                  spreadRadius: isSelected ? 3 : 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(13),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Coloured top stripe
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [accentColor, accentColor.withValues(alpha: 0.3)],
                      ),
                    ),
                  ),
                  // Body content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon badge
                          Container(
                            width: iconSize + 2,
                            height: iconSize + 2,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.35),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(icon, color: accentColor, size: iconSize),
                          ),
                          const SizedBox(height: 4),
                          // Name
                          Text(
                            device.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: labelSize,
                              fontWeight: FontWeight.w600,
                              shadows: const [
                                Shadow(color: Colors.black87, blurRadius: 4)
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          // Status pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: accentColor.withValues(alpha: 0.45),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: statusSize,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Resize grip ──────────────────────────────────────────────────────
        // Larger transparent hit area (44×44) around the visible 24×24 icon
        // so the user can grab it easily even on small markers.
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
    );
  }
}
