import 'package:flutter/material.dart';

/// Reusable vector-rendered celestial indicator widget depicting either a glowing sun
/// or a detailed, cratered glowing moon with smooth radial gradients.
class CelestialIndicator extends StatelessWidget {
  /// Whether to display the day (sun) or night (moon) indicator.
  final bool isDay;

  /// Optional custom glow color for night mode or specific weather conditions.
  final Color? glowColor;

  /// Width and height of the painted celestial body. Defaults to 120.0.
  final double size;

  const CelestialIndicator({
    super.key,
    required this.isDay,
    this.glowColor,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: CustomPaint(
          painter: isDay
              ? SunPainter()
              : MoonPainter(
                  glowColor: glowColor ?? Colors.white.withValues(alpha: 0.1),
                ),
        ),
      ),
    );
  }
}

/// Custom painter rendering a glowing vector sun with radial gradient and blurred aura.
class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glowRadius = size.width / 2 - (size.width * 0.033);
    final sunRadius = size.width / 2 - (size.width * 0.10);
    final blurSigma = size.width * 0.125;

    // Outer aura glow
    final glowPaint = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(center, glowRadius, glowPaint);

    // Sun core body
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Colors.amberAccent, Colors.orangeAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(center, sunRadius, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Custom painter rendering a detailed vector moon with surface craters and dynamic aura.
class MoonPainter extends CustomPainter {
  final Color glowColor;

  MoonPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final glowRadius = size.width / 2 - (size.width * 0.033);
    final moonRadius = size.width / 2 - (size.width * 0.10);
    final blurSigma = size.width * 0.125;

    // Outer aura glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(center, glowRadius, glowPaint);

    // Moon body
    final moonPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white,
          Colors.white.withValues(alpha: 0.95),
          const Color(0xFFE2E8F0),
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawCircle(center, moonRadius, moonPaint);

    // Crater details
    final craterPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.4),
      size.width * (6 / 120),
      craterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.5),
      size.width * (8 / 120),
      craterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.65),
      size.width * (5 / 120),
      craterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant MoonPainter oldDelegate) =>
      oldDelegate.glowColor != glowColor;
}
