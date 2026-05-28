import 'package:flutter/material.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/card_device_marker.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/pulsing_dot_marker.dart';

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

  // ValueNotifiers to update position and size during gestures without rebuilding the whole widget tree
  late final ValueNotifier<Offset> _dragOffsetNotifier;
  late final ValueNotifier<Size> _sizeNotifier;

  @override
  void initState() {
    super.initState();
    final (mW, mH) = _markerSize;
    _sizeNotifier = ValueNotifier<Size>(Size(mW, mH));
    _dragOffsetNotifier = ValueNotifier<Offset>(Offset.zero);
  }

  @override
  void dispose() {
    _sizeNotifier.dispose();
    _dragOffsetNotifier.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PlacementDeviceMarker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.device != oldWidget.device ||
        widget.parentWidth != oldWidget.parentWidth ||
        widget.parentHeight != oldWidget.parentHeight) {
      final (mW, mH) = _markerSize;
      if (!_isResizing) {
        _sizeNotifier.value = Size(mW, mH);
      }
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
    final currentSize = _sizeNotifier.value;
    final newWidth = (currentSize.width + details.delta.dx)
        .clamp(70.0, widget.parentWidth * 0.8);
    final newHeight = (currentSize.height + details.delta.dy)
        .clamp(60.0, widget.parentHeight * 0.8);
    _sizeNotifier.value = Size(newWidth, newHeight);
  }

  void _onResizeEnd(DragEndDetails _) {
    final finalSize = _sizeNotifier.value;
    widget.dashboardController.updateDeviceMarkerSize(
      widget.device.id,
      finalSize.width / widget.parentWidth,
      finalSize.height / widget.parentHeight,
      persist: true,
    );
    if (_isResizing) setState(() => _isResizing = false);
  }

  // ── Drag callbacks ────────────────────────────────────────────────────────

  void _onDragStart(DragStartDetails details) {
    widget.placementController.selectDevice(widget.device.id);
    _dragOffsetNotifier.value = Offset.zero;
    if (!_isDragging) setState(() => _isDragging = true);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final startX = (widget.device.positionX ?? 0.5) * widget.parentWidth;
    final startY = (widget.device.positionY ?? 0.5) * widget.parentHeight;
    final currentOffset = _dragOffsetNotifier.value;
    final newDx = (currentOffset.dx + details.delta.dx)
        .clamp(-startX, widget.parentWidth - startX);
    final newDy = (currentOffset.dy + details.delta.dy)
        .clamp(-startY, widget.parentHeight - startY);
    _dragOffsetNotifier.value = Offset(newDx, newDy);
  }

  void _onDragEnd(DragEndDetails details) {
    final box = widget.imageKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      final dx = _dragOffsetNotifier.value.dx / box.size.width;
      final dy = _dragOffsetNotifier.value.dy / box.size.height;
      final x = ((widget.device.positionX ?? 0.5) + dx).clamp(0.0, 1.0);
      final y = ((widget.device.positionY ?? 0.5) + dy).clamp(0.0, 1.0);
      widget.dashboardController.updateDevicePosition(
        widget.device.id,
        x,
        y,
        persist: true,
      );
    }
    _dragOffsetNotifier.value = Offset.zero;
    if (_isDragging) setState(() => _isDragging = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final animDuration = (_isResizing || _isDragging)
        ? Duration.zero
        : const Duration(milliseconds: 250);

    final Widget markerWidget;

    if (widget.device.showAsDot) {
      markerWidget = PulsingDotMarker(
        device: widget.device,
        isSelected: widget.isSelected,
        onTap: () => widget.placementController.selectDevice(widget.device.id),
        onPanStart: _onDragStart,
        onPanUpdate: _onDragUpdate,
        onPanEnd: _onDragEnd,
      );
    } else {
      markerWidget = ValueListenableBuilder<Size>(
        valueListenable: _sizeNotifier,
        builder: (context, size, child) {
          return CardDeviceMarker(
            device: widget.device,
            isSelected: widget.isSelected,
            mW: size.width,
            mH: size.height,
            animDuration: animDuration,
            isResizing: _isResizing,
            onTap: () => widget.placementController.selectDevice(widget.device.id),
            onPanStart: _onDragStart,
            onPanUpdate: _onDragUpdate,
            onPanEnd: _onDragEnd,
            onResizeStart: _onResizeStart,
            onResizeUpdate: _onResizeUpdate,
            onResizeEnd: _onResizeEnd,
          );
        },
      );
    }

    return ValueListenableBuilder<Offset>(
      valueListenable: _dragOffsetNotifier,
      builder: (context, dragOffset, child) {
        return Transform.translate(
          offset: dragOffset,
          child: child,
        );
      },
      child: markerWidget,
    );
  }
}
