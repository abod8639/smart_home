import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/shadow_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class WeatherUpdateWidget extends GetView<DashboardController> {
  const WeatherUpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cardWidth = Responsive.isDesktop(context) ? 280.0 : null;

    return ShadowContainer(
      width: cardWidth,
      padding: const EdgeInsets.all(24.0),
      // decoration: BoxDecoration(
      //   color: AppTheme.cardBackground.withValues(alpha: 0.3),
      //   borderRadius: BorderRadius.circular(32),
      //   boxShadow: [
      //     BoxShadow(
      //       blurStyle: BlurStyle.outer,
      //       color: Colors.white.withValues(alpha: 0.08),
      //       blurRadius: 20,
      //       spreadRadius: 2,

      //     )
      //   ],
      // ),
      child: Obx(() {
        if (controller.isWeatherLoading.value) {
          return _buildLoadingState();
        }

        final location = controller.weatherLocation.value;
        final date = controller.weatherDate.value;
        final temp = controller.weatherTemp.value;
        final condition = controller.weatherCondition.value;
        final suggestion = controller.weatherSuggestion.value;
        final code = controller.weatherCode.value;
        final dayFlag = controller.isDay.value;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Header Row (Dynamic Weather Icon and Title)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getWeatherHeaderIcon(code, dayFlag),
                      color: _getWeatherHeaderColor(code, dayFlag),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Weather Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

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
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          date,
                          style: const TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          temp,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
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
                      width: 100,
                      height: 100,
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
              const SizedBox(height: 20),

              // 3. AI Suggestion Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amberAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'AI Suggestion :',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      suggestion,
                      style: const TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: 11,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Weather Shimmer Loading Placeholder
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Syncing Live Weather...',
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Locating smart hub coordinates',
            style: TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // Get dynamic header icon based on code and day/night status
  IconData _getWeatherHeaderIcon(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    if (code >= 95) return Icons.thunderstorm_outlined;
    if (code >= 80) return Icons.water_drop_outlined;
    if (code >= 71) return Icons.ac_unit_outlined;
    if (code >= 51) return Icons.umbrella_outlined;
    if (code >= 45) return Icons.filter_drama_outlined;
    if (code >= 1) return Icons.cloud_outlined;
    return isNight ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined;
  }

  // Get dynamic weather icon color
  Color _getWeatherHeaderColor(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    if (code >= 95) return Colors.purpleAccent;
    if (code >= 80) return AppTheme.primaryBlue;
    if (code >= 71) return Colors.lightBlueAccent;
    if (code >= 51) return AppTheme.primaryBlue;
    if (code >= 45) return Colors.grey;
    if (code >= 1) return Colors.white70;
    return isNight ? Colors.white : Colors.amberAccent;
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
    // Draw outer glow
    final glowPaint = Paint()
      ..color = Colors.amberAccent.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, size.width / 2 - 4, glowPaint);

    // Draw sun body
    final sunPaint = Paint()
      ..shader = const RadialGradient(
        colors: [Colors.white, Colors.amberAccent, Colors.orangeAccent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(center, size.width / 2 - 12, sunPaint);
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
    // Draw outer glow
    final glowPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, size.width / 2 - 4, glowPaint);

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

    canvas.drawCircle(center, size.width / 2 - 12, moonPaint);

    // Draw some crater details
    final craterPaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.4),
      6,
      craterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.6, size.height * 0.5),
      8,
      craterPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.45, size.height * 0.65),
      5,
      craterPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
