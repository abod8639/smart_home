import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class RoomPreviewWidget extends GetView<DashboardController> {
  const RoomPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: AssetImage('assets/images/living_room.png'),
          fit: BoxFit.fill,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Stack(
        children: [
          // Top overlay gradient for text visibility
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
          
          // Top Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Environment Stats
                Obx(() => Row(
                  children: [
                    _buildStatChip(Icons.water_drop_outlined, controller.humidity.value),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.air_outlined, controller.airflow.value),
                    const SizedBox(width: 12),
                    _buildStatChip(Icons.thermostat_outlined, controller.temperature.value),
                  ],
                )),
              ],
            ),
          ),

          // Dynamic Device Markers (Simulated AR Overlay)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Obx(() {
                  final validDevices = controller.devices
                      .where((d) => d.positionX != null && d.positionY != null)
                      .toList();

                  return Stack(
                    children: validDevices.map((device) {
                      final posX = device.positionX! * constraints.maxWidth;
                      final posY = device.positionY! * constraints.maxHeight;
                      final mW = device.markerWidth ?? 110.0;
                      final mH = device.markerHeight ?? 70.0;

                      return Positioned(
                        left: posX - mW / 2,
                        top: posY - mH / 2,
                        child: GestureDetector(
                          onTap: () {
                            if (device.type == DeviceType.door) {
                              controller.toggleDoor(device.id);
                            } else {
                              controller.toggleDevice(device.id);
                            }
                          },
                          child: _buildInteractiveMarker(device, mW, mH),
                        ),
                      );
                    }).toList(),
                  );
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInteractiveMarker(DeviceEntity device, double width, double height) {
    final isOn = device.isOn;
    IconData iconData;
    switch (device.type) {
      case DeviceType.lamp:
        iconData = Icons.lightbulb_outline;
        break;
      case DeviceType.airConditioner:
        iconData = Icons.ac_unit;
        break;
      case DeviceType.vacuum:
        iconData = Icons.cleaning_services_outlined;
        break;
      case DeviceType.door:
        iconData = device.isLocked ?? true ? Icons.lock_outline : Icons.lock_open_outlined;
        break;
      case DeviceType.rgb:
        iconData = Icons.wb_incandescent_rounded;
        break;
    }

    final isDoor = device.type == DeviceType.door;
    final isLocked = device.isLocked ?? true;
    final isRgbOn = device.type == DeviceType.rgb && isOn;

    Color markerColor;
    Color borderColor;
    Color glowColor;
    bool showGlow = isOn || (isDoor && !isLocked);

    if (isDoor) {
      markerColor = isLocked
          ? Colors.redAccent.withValues(alpha: 0.2)
          : Colors.greenAccent.withValues(alpha: 0.2);
      borderColor = isLocked
          ? Colors.redAccent.withValues(alpha: 0.6)
          : Colors.greenAccent.withValues(alpha: 0.6);
      glowColor = isLocked
          ? Colors.redAccent.withValues(alpha: 0.3)
          : Colors.greenAccent.withValues(alpha: 0.3);
    } else if (isRgbOn) {
      final r = device.rgbR ?? 255;
      final g = device.rgbG ?? 0;
      final b = device.rgbB ?? 128;
      markerColor = Color.fromRGBO(r, g, b, 0.45);
      borderColor = Color.fromRGBO(r, g, b, 0.8);
      glowColor = Color.fromRGBO(r, g, b, 0.4);
    } else {
      markerColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.45)
          : Colors.black.withValues(alpha: 0.15);
      borderColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.8)
          : Colors.white.withValues(alpha: 0.25);
      glowColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.4)
          : Colors.transparent;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: markerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: isOn || (isDoor && !isLocked) ? 2.0 : 1.0,
        ),
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: glowColor,
                  blurRadius: 12,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  iconData,
                  color: isOn || (isDoor && !isLocked) ? Colors.white : Colors.white70,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  device.name,
                  style: TextStyle(
                    color: isOn || (isDoor && !isLocked) ? Colors.white : Colors.white70,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
