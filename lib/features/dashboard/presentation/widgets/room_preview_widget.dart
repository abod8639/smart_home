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
    return Expanded(
      child: Container(
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
                  // Live indicator
                  // GlassContainer(
                  //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  //   borderRadius: BorderRadius.circular(20),
                  //   child: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       Container(
                  //         width: 8,
                  //         height: 8,
                  //         decoration: const BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: Colors.redAccent,
                  //         ),
                  //       ),
                  //       const SizedBox(width: 8),
                  //       const Text('Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  //     ],
                  //   ),
                  // ),
                  
                  // Environment Stats
                  Obx(() => Row(
                    children: [
                      _buildStatChip(Icons.water_drop_outlined, controller.humidity.value),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.air_outlined, controller.airflow.value),
                      const SizedBox(width: 12),
                      _buildStatChip(Icons.thermostat_outlined, controller.temperature.value),
                      // const SizedBox(width: 12),
                      // _buildStatChip(Icons.electric_bolt_outlined, controller.powerUsage.value),
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

                        return Positioned(
                          left: posX - 24,
                          top: posY - 24,
                          child: GestureDetector(
                            onTap: () => controller.toggleDevice(device.id),
                            child: _buildInteractiveMarker(device),
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

  Widget _buildInteractiveMarker(DeviceEntity device) {
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
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing / Glowing Dot
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn ? AppTheme.primaryBlue : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isOn 
                    ? AppTheme.primaryBlue.withValues(alpha: 0.6) 
                    : Colors.white.withValues(alpha: 0.4),
                blurRadius: isOn ? 14 : 8,
                spreadRadius: isOn ? 6 : 3,
              )
            ],
          ),
        ),
        const SizedBox(height: 6),
        
        // Small Glass Label
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          borderRadius: BorderRadius.circular(12),
          borderGradient: false,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color: isOn ? AppTheme.primaryBlue : Colors.white70,
                size: 12,
              ),
              const SizedBox(width: 6),
              Text(
                device.name,
                style: TextStyle(
                  color: isOn ? Colors.white : Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
