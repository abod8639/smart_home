import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_radii.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/stat_badge.dart';
import '../controllers/environment_controller.dart';

/// Reusable horizontal telemetry row displaying ambient environment metrics
/// (humidity, airflow, temperature, wifi signal, free heap) using unified tokens.
class EnvironmentStatsRow extends ConsumerWidget {
  /// Whether to use compact mobile layout sizing.
  final bool? isMobile;

  const EnvironmentStatsRow({
    super.key,
    this.isMobile,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final envState = ref.watch(environmentControllerProvider);
    final mobile = isMobile ?? Responsive.isMobile(context);
    final gap = mobile ? 6.0 : 12.0;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildChip(
            icon: Icons.water_drop_outlined,
            value: envState.humidity,
            isMobile: mobile,
          ),
          SizedBox(width: gap),
          _buildChip(
            icon: Icons.air_outlined,
            value: envState.airflow,
            isMobile: mobile,
          ),
          SizedBox(width: gap),
          _buildChip(
            icon: Icons.thermostat_outlined,
            value: envState.temperature,
            isMobile: mobile,
          ),
          SizedBox(width: gap),
          _buildChip(
            icon: Icons.wifi_outlined,
            value: envState.wifiRssi,
            isMobile: mobile,
          ),
          SizedBox(width: gap),
          _buildChip(
            icon: Icons.memory_outlined,
            value: envState.heapFree,
            isMobile: mobile,
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String value,
    required bool isMobile,
  }) {
    return StatBadge(
      icon: icon,
      value: value,
      borderRadius: AppRadii.xl,
      backgroundColor: Colors.white.withValues(alpha: 0.08),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.12),
        width: 1.0,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16,
        vertical: isMobile ? 4 : 8,
      ),
      iconSize: isMobile ? 12 : 16,
      valueFontSize: isMobile ? 10 : 13,
    );
  }
}
