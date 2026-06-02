import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

class TemperatureDial extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final Color activeColor;

  const TemperatureDial({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  State<TemperatureDial> createState() => _TemperatureDialState();
}

class _TemperatureDialState extends State<TemperatureDial> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(TemperatureDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _updateTouch(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    double angle = math.atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    // Shift start angle from 135 deg (0.75 * pi) to 0
    double relativeAngle = angle - 0.75 * math.pi;
    if (relativeAngle < 0) {
      relativeAngle += 2 * math.pi;
    }

    double progressPercent;
    if (relativeAngle > 1.5 * math.pi) {
      final gapMiddle = 1.75 * math.pi;
      if (relativeAngle < gapMiddle) {
        progressPercent = 1.0;
      } else {
        progressPercent = 0.0;
      }
    } else {
      progressPercent = relativeAngle / (1.5 * math.pi);
    }

    final newTemp = (widget.minValue + progressPercent * (widget.maxValue - widget.minValue)).round().clamp(widget.minValue, widget.maxValue);
    if (newTemp != _currentValue) {
      setState(() {
        _currentValue = newTemp;
      });
      widget.onChanged(newTemp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (details) => _updateTouch(details.localPosition, size),
          onPanUpdate: (details) => _updateTouch(details.localPosition, size),
          child: CustomPaint(
            size: size,
            painter: TemperaturePainter(
              value: _currentValue,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
              activeColor: widget.activeColor,
            ),
          ),
        );
      },
    );
  }
}

class TemperaturePainter extends CustomPainter {
  final int value;
  final int minValue;
  final int maxValue;
  final Color activeColor;

  TemperaturePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 14.0;
    final radius = size.width / 2 - strokeWidth;

    // Background track
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.75 * math.pi,
      1.5 * math.pi,
      false,
      backgroundPaint,
    );

    // Active track
    final progressPercent = (value - minValue) / (maxValue - minValue);
    final sweepAngle = 1.5 * math.pi * progressPercent;

    if (sweepAngle > 0) {
      // Glow
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0.75 * math.pi,
        sweepAngle,
        false,
        glowPaint,
      );

      // Active line
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0.75 * math.pi,
        sweepAngle,
        false,
        activePaint,
      );
    }

    // Thumb (Handle) - represented as a pill rotated along the arc tangent
    final thumbAngle = 0.75 * math.pi + sweepAngle;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    canvas.save();
    canvas.translate(thumbX, thumbY);
    canvas.rotate(thumbAngle + math.pi / 2);

    // Draw thumb shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 26),
        const Radius.circular(8),
      ),
      shadowPaint,
    );

    // Draw white thumb capsule
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 12, height: 24),
        const Radius.circular(6),
      ),
      thumbPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TemperaturePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.activeColor != activeColor;
  }
}
