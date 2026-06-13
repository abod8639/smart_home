import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/shadow_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class WeatherUpdateWidget extends ConsumerWidget {
  const WeatherUpdateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Compute dynamic scale factor based on screen height and width relative to baseline
    final screenSize = MediaQuery.of(context).size;
    final double scaleX = screenSize.width / 375.0;
    final double scaleY = screenSize.height / 812.0;
    final double scale = ((scaleX + scaleY) / 2.0).clamp(0.35, 0.8);

    final cardWidth = Responsive.isDesktop(context) ? 320.0 * scale : null;
    final state = ref.watch(dashboardControllerProvider);

    return ShadowContainer(
      width: cardWidth,
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 10 * scale),
      child: Builder(builder: (context) {
        if (state.isWeatherLoading) {
          return _buildLoadingState(scale);
        }

        final location = state.weatherLocation;
        final date = state.weatherDate;
        final temp = state.weatherTemp;
        final condition = state.weatherCondition;
        final code = state.weatherCode;
        final dayFlag = state.isDay;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2. Middle Row (Location, Date, Temp, Condition, and Moon Image)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          location,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          date,
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12 * scale,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 16 * scale),
                        Text(
                          temp,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36 * scale,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          condition,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13 * scale,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Right Vector Icon with Glow
                  Center(
                    child: SizedBox(
                      width: 120 * scale,
                      height: 120 * scale,
                      child: CustomPaint(
                        painter: dayFlag == 1
                            ? SunPainter()
                            : MoonPainter(
                                glowColor: _getWeatherGlowColor(code, dayFlag),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  // Weather Shimmer Loading Placeholder
  Widget _buildLoadingState(double scale) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 32 * scale,
            height: 32 * scale,
            child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
              strokeWidth: 3 * scale,
            ),
          ),
          SizedBox(height: 20 * scale),
          Text(
            'Syncing Live Weather...',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13 * scale,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            'Locating smart hub coordinates',
            style: TextStyle(
              color: Colors.white24, 
              fontSize: 11 * scale,
            ),
          ),
        ],
      ),
    );
  }

  // Get dynamic shadow glow color for the moon element based on condition
  Color _getWeatherGlowColor(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    if (code >= 95) return Colors.purpleAccent.withValues(alpha: 0.12);
    if (code >= 80) return AppTheme.primaryBlue.withValues(alpha: 0.12);
    if (code >= 71) return Colors.lightBlueAccent.withValues(alpha: 0.15);
    if (code >= 51) return AppTheme.primaryBlue.withValues(alpha: 0.1);
    if (code >= 45) return Colors.grey.withValues(alpha: 0.1);
    if (code >= 1) return Colors.white.withValues(alpha: 0.08);
    return isNight
        ? Colors.white.withValues(alpha: 0.1)
        : Colors.amberAccent.withValues(alpha: 0.12);
  }
}

class SunPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Proportional calculations
    final glowRadius = size.width / 2 - (size.width * 0.033);
    final sunRadius = size.width / 2 - (size.width * 0.10);
    final blurSigma = size.width * 0.125;

    // Draw outer glow
    final glowPaint = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(center, glowRadius, glowPaint);

    // Draw sun body
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Colors.amberAccent, Colors.orangeAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(center, sunRadius, sunPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class MoonPainter extends CustomPainter {
  final Color glowColor;
  MoonPainter({required this.glowColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Proportional calculations
    final glowRadius = size.width / 2 - (size.width * 0.033);
    final moonRadius = size.width / 2 - (size.width * 0.10);
    final blurSigma = size.width * 0.125;

    // Draw outer glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurSigma);
    canvas.drawCircle(center, glowRadius, glowPaint);

    // Draw moon body
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

    // Draw crater details proportionally
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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
