import 'package:flutter/material.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'glass_container.dart';

/// A card widget displaying a set of preset colors that can be selected for the RGB lamp.
class RgbColorPresetsCard extends StatelessWidget {
  /// The RGB lamp device entity.
  final RgbLampDeviceEntity device;

  /// The dashboard controller instance.
  final DashboardController controller;

  /// Creates a [RgbColorPresetsCard].
  const RgbColorPresetsCard({
    super.key,
    required this.device,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final List<Color> presets = [
      Colors.redAccent,
      Colors.orange,
      Colors.yellow,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.white,
    ];

    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Colors',
              style: TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: presets.map((color) {
                final isSelected = device.rgbR == (color.r * 255).toInt() &&
                    device.rgbG == (color.g * 255).toInt() &&
                    device.rgbB == (color.b * 255).toInt();

                return GestureDetector(
                  onTap: () {
                    controller.updateDeviceColor(
                      device.id,
                      (color.r * 255).toInt(),
                      (color.g * 255).toInt(),
                      (color.b * 255).toInt(),
                    );
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: isSelected
                          ? Border.all(color: Colors.white, width: 3)
                          : Border.all(color: Colors.transparent, width: 3),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
