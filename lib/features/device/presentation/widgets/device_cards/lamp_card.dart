import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/device_entity.dart';

class LampCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const LampCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(device.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    const Text('3 Device', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                  ],
                ),
                Switch(
                  value: device.isOn,
                  onChanged: (_) => onToggle(),
                  activeColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withOpacity(0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withOpacity(0.1),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Image.asset(
                  'assets/images/smart_lamp.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
                  Expanded(
                    child: Slider(
                      value: device.brightness?.toDouble() ?? 0,
                      min: 0,
                      max: 100,
                      activeColor: Colors.white,
                      inactiveColor: Colors.white.withOpacity(0.2),
                      onChanged: (val) {},
                    ),
                  ),
                  Text('${device.brightness}%', style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
