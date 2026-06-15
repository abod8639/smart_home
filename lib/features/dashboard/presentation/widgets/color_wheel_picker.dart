import 'dart:math';
import 'package:flutter/material.dart';

/// A custom circular color picker widget that displays a rainbow wheel
/// and provides callback events when the user selects a color.
class ColorWheelPicker extends StatelessWidget {
  /// The currently selected color.
  final Color currentColor;

  /// Callback invoked when the user selects or drags to a new color.
  final ValueChanged<Color> onColorChanged;

  /// Creates a [ColorWheelPicker].
  const ColorWheelPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  void _updateColor(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    double angle = atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * pi;
    }

    double hue = (angle / (2 * pi)) * 360;
    final color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    const size = Size(240, 240);
    return GestureDetector(
      onPanDown: (details) => _updateColor(details.localPosition, size),
      onPanUpdate: (details) => _updateColor(details.localPosition, size),
      child: CustomPaint(
        size: size,
        painter: ColorWheelPainter(
          currentColor: currentColor,
          strokeWidth: 26,
        ),
      ),
    );
  }
}

/// Custom painter responsible for rendering the rainbow color wheel and indicators.
class ColorWheelPainter extends CustomPainter {
  /// The active color used for center fill and indicators.
  final Color currentColor;

  /// The width of the rainbow wheel stroke.
  final double strokeWidth;

  /// Creates a [ColorWheelPainter].
  ColorWheelPainter({
    required this.currentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final wheelRadius = outerRadius - strokeWidth / 2 - 8; // leave space for outer indicator arc

    // 1. Draw Rainbow Wheel
    final rect = Rect.fromCircle(center: center, radius: wheelRadius);
    final wheelPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFF0000), // Red (0)
          Color(0xFFFFFF00), // Yellow (60)
          Color(0xFF00FF00), // Green (120)
          Color(0xFF00FFFF), // Cyan (180)
          Color(0xFF0000FF), // Blue (240)
          Color(0xFFFF00FF), // Magenta (300)
          Color(0xFFFF0000), // Red (360)
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, 2 * pi, false, wheelPaint);

    // 2. Draw Center Solid Circle (Current Color) with Glow
    final centerColorPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;
    
    // Glow effect
    final glowPaint = Paint()
      ..color = currentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    
    canvas.drawCircle(center, 40, glowPaint);
    canvas.drawCircle(center, 30, centerColorPaint);

    // 3. Draw Handle (Indicator Dot) on the ring
    final hsv = HSVColor.fromColor(currentColor);
    final angle = (hsv.hue / 360.0) * 2 * pi;
    final handleOffset = Offset(
      center.dx + wheelRadius * cos(angle),
      center.dy + wheelRadius * sin(angle),
    );

    // Handle background (white)
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleOffset, 12, handlePaint);

    // Handle border / center (current color)
    final handleInnerPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleOffset, 8, handleInnerPaint);

    // 4. Draw thin outer arc
    final outerArcPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    final outerArcRect = Rect.fromCircle(center: center, radius: wheelRadius + strokeWidth / 2 + 5);
    const startAngle = -pi / 2; // 12 o'clock
    double sweepAngle = angle - startAngle;
    if (sweepAngle < 0) {
      sweepAngle += 2 * pi;
    }
    canvas.drawArc(outerArcRect, startAngle, sweepAngle, false, outerArcPaint);
  }

  @override
  bool shouldRepaint(covariant ColorWheelPainter oldDelegate) {
    return oldDelegate.currentColor != currentColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
