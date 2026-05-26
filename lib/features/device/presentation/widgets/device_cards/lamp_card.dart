import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class LampCard extends StatelessWidget {
  final DeviceEntity device;
  final VoidCallback onToggle;

  const LampCard({super.key, required this.device, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DashboardController>();
    final isDeviceOn = device.isOn;
    final brightnessVal = device.brightness ?? 0;

    // Calculate dynamic glow parameters based on brightness
    final double glowOpacity = isDeviceOn ? (brightnessVal / 100.0 * 0.4).clamp(0.1, 0.4) : 0.0;
    final double glowSize = isDeviceOn ? (80.0 + (brightnessVal / 100.0 * 80.0)) : 0.0;

    return Expanded(
      flex: 2,
      child: GlassContainer(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name, 
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '3 Devices Connected', 
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                    ),
                  ],
                ),
                Switch(
                  value: isDeviceOn,
                  onChanged: (_) => onToggle(),
                  activeThumbColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                ),
              ],
            ),
            
            // Middle Area: Lamp Image with Dynamic Light Glow
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow Effect (Only active when device is on)
                  if (isDeviceOn)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: glowSize,
                      height: glowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.amberAccent.withValues(alpha: glowOpacity),
                            Colors.amberAccent.withValues(alpha: glowOpacity * 0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  
                  // Product Image (Semi-transparent when off to signify deactivated state)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDeviceOn ? 1.0 : 0.4,
                    child: Center(
                      child: Image.asset(
                        'assets/images/smart_lamp.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Area: Brightness Slider Controls
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDeviceOn 
                    ? Colors.black.withValues(alpha: 0.4) 
                    : Colors.black.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDeviceOn 
                      ? Colors.white.withValues(alpha: 0.05) 
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline, 
                    color: isDeviceOn ? Colors.amber.shade100 : AppTheme.textGrey, 
                    size: 20,
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isDeviceOn ? Colors.white : AppTheme.textGrey,
                        inactiveTrackColor: Colors.white.withValues(
                          alpha: isDeviceOn ? 0.2 : 0.05,
                        ),
                        thumbColor: isDeviceOn ? Colors.white : AppTheme.textGrey,
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                      ),
                      child: Slider(
                        value: brightnessVal.toDouble(),
                        min: 0,
                        max: 100,
                        onChanged: (val) {
                          controller.updateDeviceBrightness(device.id, val.round());
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '$brightnessVal%', 
                      style: TextStyle(
                        color: isDeviceOn ? Colors.white : AppTheme.textGrey, 
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.end,
                    ),
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
