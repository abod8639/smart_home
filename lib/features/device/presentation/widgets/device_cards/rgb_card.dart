import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/glass_switch.dart';

class RgbCard extends ConsumerWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const RgbCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider.notifier);

    final r = device.rgbR ?? 255;
    final g = device.rgbG ?? 0;
    final b = device.rgbB ?? 128;
    final currentColor = Color.fromRGBO(r, g, b, 1.0);
    final isOn = device.isOn;

    final isMobile = Responsive.isMobile(context);
    final double cardWidth = isMobile ? 240.0 : 260.0;
    final double padding = isMobile ? 10.0 : 14.0;

    return SizedBox(
      width: cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row ────────────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        device.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: isMobile ? 14 : 16,
                              letterSpacing: 0.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isOn
                            ? 'rgb($r, $g, $b)'
                            : 'Off',
                        style: TextStyle(
                          color: isOn ? currentColor : AppTheme.textGrey,
                          fontSize: isMobile ? 10 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                GlassSwitch(onToggle: onToggle, isDeviceOn: isOn, scale: isMobile ? 0.85 : 1.0)
              ],
            ),

            // ── Color Preview Orb ───────────────────────────────────────────────
            Expanded(
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final orbSize = (constraints.maxHeight * 0.85).clamp(44.0, 76.0);
                    final iconSize = orbSize * 0.45;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: orbSize,
                      height: orbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isOn ? currentColor : Colors.white10,
                        boxShadow: isOn
                            ? [
                                BoxShadow(
                                  color: currentColor.withValues(alpha: 0.6),
                                  blurRadius: orbSize * 0.35,
                                  spreadRadius: orbSize * 0.08,
                                ),
                                BoxShadow(
                                  color: currentColor.withValues(alpha: 0.3),
                                  blurRadius: orbSize * 0.75,
                                  spreadRadius: orbSize * 0.15,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.wb_incandescent_rounded,
                        color: isOn ? Colors.white.withValues(alpha: 0.9) : AppTheme.textGrey,
                        size: iconSize,
                      ),
                    );
                  }
                ),
              ),
            ),

            // ── RGB Sliders ─────────────────────────────────────────────────────
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: isOn ? 1.0 : 0.35,
              child: Column(
                children: [
                  _RgbSliderRow(
                    label: 'R',
                    value: r.toDouble(),
                    color: Colors.redAccent,
                    onChanged: isOn
                        ? (val) => controller.updateDeviceColor(
                              device.id, val.round(), g, b)
                        : null,
                  ),
                  SizedBox(height: isMobile ? 3 : 5),
                  _RgbSliderRow(
                    label: 'G',
                    value: g.toDouble(),
                    color: Colors.greenAccent,
                    onChanged: isOn
                        ? (val) => controller.updateDeviceColor(
                              device.id, r, val.round(), b)
                        : null,
                  ),
                  SizedBox(height: isMobile ? 3 : 5),
                  _RgbSliderRow(
                    label: 'B',
                    value: b.toDouble(),
                    color: Colors.blueAccent,
                    onChanged: isOn
                        ? (val) => controller.updateDeviceColor(
                              device.id, r, g, val.round())
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Private Slider Row ────────────────────────────────────────────────────────

class _RgbSliderRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final ValueChanged<double>? onChanged;

  const _RgbSliderRow({
    required this.label,
    required this.value,
    required this.color,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double labelFontSize = isMobile ? 10.0 : 11.0;
    final double valueFontSize = isMobile ? 9.0 : 10.0;

    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: labelFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: color,
              trackHeight: isMobile ? 2 : 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: isMobile ? 4 : 6),
              overlayShape: RoundSliderOverlayShape(overlayRadius: isMobile ? 8 : 12),
            ),
            child: Slider(
              value: value,
              min: 0,
              max: 255,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 28,
          child: Text(
            value.round().toString(),
            style: TextStyle(
              color: AppTheme.textGrey,
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
