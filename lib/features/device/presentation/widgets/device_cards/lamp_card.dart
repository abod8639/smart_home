import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/ac_card.dart';

/// Clipper to draw a neat projecting light beam cone
class LightBeamClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width * 0.25, 0); // top left
    path.lineTo(size.width * 0.75, 0); // top right
    path.lineTo(size.width, size.height); // bottom right
    path.lineTo(0, size.height); // bottom left
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

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
    final double glowOpacity = isDeviceOn ? (brightnessVal / 100.0 * 0.5).clamp(0.1, 0.5) : 0.0;
    final double glowSize = isDeviceOn ? (60.0 + (brightnessVal / 100.0 * 60.0)) : 0.0;

    final isMobile = Responsive.isMobile(context);
    final double cardWidth = isMobile ? 210.0 : 260.0;
    final double innerPadding = isMobile ? 10.0 : 14.0;

    return SizedBox(
      width: cardWidth,
      child: GlassContainer(
        padding: EdgeInsets.all(innerPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Title & Switch
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
                      if (device.linkedDevicesCount != null && device.linkedDevicesCount! > 0) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${device.linkedDevicesCount} Devices Connected', 
                          style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                        ),
                      ],
                    ],
                  ),
                ),
                GlassSwitch(onToggle: onToggle, isDeviceOn: isDeviceOn),
                // Switch(
                //   value: isDeviceOn,
                //   onChanged: (_) => onToggle(),
                //   activeThumbColor: AppTheme.primaryBlue,
                //   activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                //   inactiveThumbColor: AppTheme.textGrey,
                //   inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                // ),
              ],
            ),
            
            // Middle Area: Code-Drawn Hanging Pendant Lamp
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Stack(
                    alignment: Alignment.center,
                  
                    children: [
                      // Glow Effect behind the bulb
                      if (isDeviceOn)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: Responsive.isMobile(context) ? glowSize -10  : glowSize,
                          height: Responsive.isMobile(context) ? glowSize -10: glowSize,
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
                      
                      // Pendant Lamp Widget Structure
                      FittedBox(
                        fit: BoxFit.contain,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Cord/wire
                            Container(
                              width: 1.5,
                              height: 12,
                              color: Colors.white.withValues(alpha: 0.25),
                            ),
                            // Lamp Shade (curved dome cap)
                            Container(
                              width: 64,
                              height: 18,
                              decoration: BoxDecoration(
                                color: isDeviceOn ? const Color(0xFF475569) : const Color(0xFF1E293B),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  width: 1,
                                ),
                              ),
                            ),
                            // Metal socket rim
                            Container(
                              width: 66,
                              height: 3,
                              decoration: BoxDecoration(
                                color: isDeviceOn 
                                    ? Colors.amberAccent.withValues(alpha: 0.8) 
                                    : const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(1.5),
                              ),
                            ),
                            // Light Bulb & Light Beam Stack
                            Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                // Projecting Light Beam
                                AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isDeviceOn ? 1.0 : 0.0,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: ClipPath(
                                      clipper: LightBeamClipper(),
                                      child: Container(
                                        width: 130,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.amberAccent.withValues(alpha: glowOpacity),
                                              Colors.transparent,
                                            ],
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Light Bulb Body
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDeviceOn 
                                        ? Colors.amberAccent 
                                        : Colors.white.withValues(alpha: 0.1),
                                    border: Border.all(
                                      color: isDeviceOn ? Colors.amber : Colors.white.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                    boxShadow: isDeviceOn ? [
                                      BoxShadow(
                                        color: Colors.amberAccent.withValues(alpha: glowOpacity),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      )
                                    ] : null,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Bottom Area: Brightness Slider Controls
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: isMobile
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
