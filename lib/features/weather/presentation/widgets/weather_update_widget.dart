import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/shadow_container.dart';
import 'package:smart_home/core/widgets/celestial_indicator.dart';
import 'package:smart_home/features/weather/presentation/controllers/weather_controller.dart';

/// Reusable weather update card displaying live meteorological telemetry,
/// location, temperature, condition, and glowing celestial graphics.
class WeatherUpdateWidget extends ConsumerWidget {
  const WeatherUpdateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final double scaleX = screenSize.width / 375.0;
    final double scaleY = screenSize.height / 812.0;
    final double scale = ((scaleX + scaleY) / 2.0).clamp(0.35, 0.8);

    final cardWidth = Responsive.isDesktop(context) ? 320.0 * scale : null;
    final weatherState = ref.watch(weatherControllerProvider);

    return ShadowContainer(
      width: cardWidth,
      borderRadius: AppRadii.xxl,
      boxShadow: AppShadows.card,
      padding: EdgeInsets.symmetric(horizontal: 24 * scale, vertical: 10 * scale),
      child: Builder(builder: (context) {
        if (weatherState.isWeatherLoading) {
          return _buildLoadingState(scale);
        }

        final location = weatherState.weatherLocation;
        final date = weatherState.weatherDate;
        final temp = weatherState.weatherTemp;
        final condition = weatherState.weatherCondition;
        final code = weatherState.weatherCode;
        final dayFlag = weatherState.isDay;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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

                  // Right Vector Celestial Graphic with glow
                  CelestialIndicator(
                    isDay: dayFlag == 1,
                    glowColor: _getWeatherGlowColor(code, dayFlag),
                    size: 120 * scale,
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

  // Dynamic shadow glow color for the celestial element based on weather condition
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
