import 'package:flutter/material.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'glass_container.dart';

/// A card widget containing a slider to adjust the brightness of an RGB lamp.
class RgbBrightnessCard extends StatelessWidget {
  /// The RGB lamp device entity.
  final RgbLampDeviceEntity device;

  /// The dashboard controller instance.
  final DashboardController controller;

  /// Creates a [RgbBrightnessCard].
  const RgbBrightnessCard({
    super.key,
    required this.device,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = device.brightness ?? 50;
    final activeColor = Color.fromRGBO(
      device.rgbR ?? 255,
      device.rgbG ?? 255,
      device.rgbB ?? 255,
      1.0,
    );

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Brightness',
                  style: TextStyle(
                      color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                ),
                Text(
                  '${((brightness / 255) * 100).toInt()}%',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(Icons.brightness_low, color: Colors.white54, size: 22),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      activeTrackColor: device.isOn ? activeColor : Colors.grey.withValues(alpha: 0.5),
                      inactiveTrackColor: Colors.white12,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white.withValues(alpha: 0.2),
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    ),
                    child: Slider(
                      value: brightness.toDouble(),
                      min: 0,
                      max: 255,
                      onChanged: (val) {
                        controller.updateDeviceBrightness(device.id, val.toInt());
                      },
                    ),
                  ),
                ),
                const Icon(Icons.brightness_high, color: Colors.white54, size: 22),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
