import 'package:flutter/material.dart';
import 'package:smart_home/core/widgets/glass_container.dart';

/// A card widget displaying a list of available light scene modes for the RGB lamp.
class RgbScenesCard extends StatelessWidget {
  /// Creates an [RgbScenesCard].
  const RgbScenesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final modes = ['Solid', 'Breathe', 'Flash', 'Music'];
    return GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scenes',
              style: TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: modes.map((mode) {
                  final isSelected = mode == 'Solid'; // Mocked selected state
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white54 : Colors.white12,
                        ),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
