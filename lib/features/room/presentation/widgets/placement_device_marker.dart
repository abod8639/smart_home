import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';

/// A draggable, resizable device card placed on the room floor-plan image.
class PlacementDeviceMarker extends StatefulWidget {
  final DeviceEntity device;
  final bool isSelected;
  final DashboardController dashboardController;
  final RoomPlacementController placementController;
  final GlobalKey imageKey;
  final double parentWidth;
  final double parentHeight;

  const PlacementDeviceMarker({
    super.key,
    required this.device,
    required this.isSelected,
    required this.dashboardController,
    required this.placementController,
    required this.imageKey,
    required this.parentWidth,
    required this.parentHeight,
  });

  @override
  State<PlacementDeviceMarker> createState() => _PlacementDeviceMarkerState();
}

class _PlacementDeviceMarkerState extends State<PlacementDeviceMarker> {
  /// Disables AnimatedContainer transitions during active drag/resize.
  bool _isResizing = false;
  bool _isDragging = false;

  // ── Helpers ───────────────────────────────────────────────────────────────

  IconData get _icon {
    switch (widget.device.type) {
      case DeviceType.lamp:
        return widget.device.isOn ? Icons.lightbulb : Icons.lightbulb_outline;
      case DeviceType.airConditioner:
        return Icons.ac_unit;
      case DeviceType.vacuum:
        return Icons.cleaning_services_rounded;
      case DeviceType.door:
        return widget.device.isLocked ?? true
            ? Icons.lock_rounded
            : Icons.lock_open_rounded;
      case DeviceType.rgb:
        return Icons.wb_incandescent_rounded;
    }
  }

  Color get _accentColor {
    final d = widget.device;
    final isDoor = d.type == DeviceType.door;
    final isRgbOn = d.type == DeviceType.rgb && d.isOn;
    if (isDoor) {
      return (d.isLocked ?? true) ? Colors.redAccent : Colors.greenAccent;
    }
    if (isRgbOn) {
      return Color.fromRGBO(d.rgbR ?? 255, d.rgbG ?? 100, d.rgbB ?? 200, 1.0);
    }
    final isActive = isDoor ? !(d.isLocked ?? true) : d.isOn;
    return isActive ? AppTheme.primaryBlue : Colors.white54;
  }

  String get _statusLabel {
    final d = widget.device;
    if (d.type == DeviceType.door) {
      return (d.isLocked ?? true) ? 'LOCKED' : 'OPEN';
    }
    return d.isOn ? 'ON' : 'OFF';
  }

  (double mW, double mH) get _markerSize {
    final d = widget.device;
    final rawW = d.markerWidth ?? 0.18;
    final rawH = d.markerHeight ?? 0.15;
    final normW = rawW > 1.0 ? (rawW / 600.0).clamp(0.05, 0.8) : rawW;
    final normH = rawH > 1.0 ? (rawH / 400.0).clamp(0.05, 0.8) : rawH;
    return (normW * widget.parentWidth, normH * widget.parentHeight);
  }

  // ── Resize callbacks ──────────────────────────────────────────────────────

  void _onResizeStart(DragStartDetails _) {
    if (!_isResizing) setState(() => _isResizing = true);
  }

  void _onResizeUpdate(DragUpdateDetails details) {
    final (mW, mH) = _markerSize;
    final newW = (mW + details.delta.dx).clamp(70.0, widget.parentWidth * 0.8);
    final newH = (mH + details.delta.dy).clamp(60.0, widget.parentHeight * 0.8);
    widget.dashboardController.updateDeviceMarkerSize(
      widget.device.id,
      newW / widget.parentWidth,
      newH / widget.parentHeight,
      persist: false,
    );
  }

  void _onResizeEnd(DragEndDetails _) {
    widget.dashboardController.persistDevices();
    if (_isResizing) setState(() => _isResizing = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final accent = _accentColor;
    final (mW, mH) = _markerSize;
    final iconSize = (mH * 0.28).clamp(14.0, 26.0);
    final labelSize = (mH * 0.11).clamp(7.5, 11.0);
    final statusSize = (mH * 0.085).clamp(6.5, 9.0);

    // Zero duration during any active interaction → immediate pixel-perfect
    // response. Smooth animation is reserved for state changes (on/off, selection).
    final animDuration = (_isResizing || _isDragging)
        ? Duration.zero
        : const Duration(milliseconds: 250);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Draggable body ───────────────────────────────────────────────────
        GestureDetector(
          onTap: () => widget.placementController.selectDevice(widget.device.id),
          onPanStart: (_) {
            widget.placementController.selectDevice(widget.device.id);
            if (!_isDragging) setState(() => _isDragging = true);
          },
          onPanUpdate: (details) {
            // Delta-based: moves the marker by how much the finger moved,
            // so it never jumps regardless of touch-point on the marker.
            final box = widget.imageKey.currentContext?.findRenderObject()
                as RenderBox?;
            if (box != null) {
              final dx = details.delta.dx / box.size.width;
              final dy = details.delta.dy / box.size.height;
              final x = ((widget.device.positionX ?? 0.5) + dx).clamp(0.0, 1.0);
              final y = ((widget.device.positionY ?? 0.5) + dy).clamp(0.0, 1.0);
              widget.dashboardController
                  .updateDevicePosition(widget.device.id, x, y, persist: false);
            }
          },
          onPanEnd: (_) {
            widget.dashboardController.persistDevices();
            if (_isDragging) setState(() => _isDragging = false);
          },
          child: AnimatedContainer(
            duration: animDuration,
            curve: Curves.easeOut,
            width: mW,
            height: mH,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.62),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: widget.isSelected
                    ? Colors.amber
                    : accent.withValues(alpha: 0.55),
                width: widget.isSelected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? Colors.amber.withValues(alpha: 0.45)
                      : accent.withValues(alpha: 0.28),
                  blurRadius: widget.isSelected ? 18 : 8,
                  spreadRadius: widget.isSelected ? 3 : 0,
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
                        colors: [accent, accent.withValues(alpha: 0.3)],
                      ),
                    ),
                  ),
                  // Body content
                  Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon badge
                          Container(
                            width: iconSize + 2,
                            height: iconSize + 2,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: accent.withValues(alpha: 0.35),
                                width: 1.0,
                              ),
                            ),
                            child: Icon(_icon, color: accent, size: iconSize),
                          ),
                          const SizedBox(height: 4),
                          // Name
                          Text(
                            widget.device.name,
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: accent.withValues(alpha: 0.45),
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
                                    color: accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  _statusLabel,
                                  style: TextStyle(
                                    color: accent,
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
            onTap: () {
           
            },
            behavior: HitTestBehavior.opaque,
            onPanStart: _onResizeStart,
            onPanUpdate: _onResizeUpdate,
            onPanEnd: _onResizeEnd,
            child: SizedBox(
              width: 50,
              height: 50,
              child: Align(
                alignment: Alignment.bottomRight,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _isResizing ? 28 : 24,
                  height: _isResizing ? 28 : 24,
                  decoration: BoxDecoration(
                    color: _isResizing
                        ? Colors.amber
                        : widget.isSelected
                            ? Colors.amber
                            : Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: _isResizing ? 8 : 4,
                        spreadRadius: _isResizing ? 1 : 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.open_in_full_rounded,
                    size: 14,
                    color: _isResizing || widget.isSelected
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
