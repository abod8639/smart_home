import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/glass_switch.dart';

class RgbCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const RgbCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();

    final r = device.rgbR ?? 255;
    final g = device.rgbG ?? 0;
    final b = device.rgbB ?? 128;
    final currentColor = Color.fromRGBO(r, g, b, 1.0);
    final isOn = device.isOn;

    return SizedBox(
      width: 280,
      child: GlassContainer(
        padding: const EdgeInsets.all(10),
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
                              letterSpacing: 0.5,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOn
                            ? 'rgb($r, $g, $b)'
                            : 'Off',
                        style: TextStyle(
                          color: isOn ? currentColor : AppTheme.textGrey,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
             GlassSwitch(onToggle: onToggle, isDeviceOn: isOn)
              ],
            ),

            // ── Color Preview Orb ───────────────────────────────────────────────
            Expanded(
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOn ? currentColor : Colors.white10,
                    boxShadow: isOn
                        ? [
                            BoxShadow(
                              color: currentColor.withValues(alpha: 0.6),
                              blurRadius: 30,
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: currentColor.withValues(alpha: 0.3),
                              blurRadius: 60,
                              spreadRadius: 12,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    Icons.wb_incandescent_rounded,
                    color: isOn ? Colors.white.withValues(alpha: 0.9) : AppTheme.textGrey,
                    size: 36,
                  ),
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
                  const SizedBox(height: 6),
                  _RgbSliderRow(
                    label: 'G',
                    value: g.toDouble(),
                    color: Colors.greenAccent,
                    onChanged: isOn
                        ? (val) => controller.updateDeviceColor(
                              device.id, r, val.round(), b)
                        : null,
                  ),
                  const SizedBox(height: 6),
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
    return Row(
      children: [
        SizedBox(
          width: 14,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
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
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
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
            style: const TextStyle(
              color: AppTheme.textGrey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
