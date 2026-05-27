import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';

class RoomPreviewWidget extends GetView<DashboardController> {
  const RoomPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Obx(() {
          final activeRoom = controller.activeRoom;
          final bgImage = _getRoomBackgroundImage(activeRoom?.name);

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(bgImage),
                fit: BoxFit.cover,
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
                    borderRadius: BorderRadius.circular(12),
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
                if (!Responsive.isMobile(context))
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Environment Stats
                        Row(
                          children: [
                            _buildStatChip(Icons.water_drop_outlined, controller.humidity.value),
                            const SizedBox(width: 12),
                            _buildStatChip(Icons.air_outlined, controller.airflow.value),
                            const SizedBox(width: 12),
                            _buildStatChip(Icons.thermostat_outlined, controller.temperature.value),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Dynamic Device Markers (Simulated AR Overlay)
                Positioned.fill(
                  child: Obx(() {
                    // Reading controller.devices here ensures GetX tracks it
                    // as a reactive dependency — so markers rebuild on toggle.
                    final activeRoomId = controller.activeRoom?.id ?? '3';
                    final validDevices = controller.devices
                        .where((d) => d.positionX != null && d.positionY != null)
                        .where((d) => d.roomId == activeRoomId || (d.roomId == null && activeRoomId == '3'))
                        .toList();

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: validDevices.map((device) {
                            final posX = device.positionX! * constraints.maxWidth;
                            final posY = device.positionY! * constraints.maxHeight;

                            final rawW = device.markerWidth ?? 0.18;
                            final rawH = device.markerHeight ?? 0.15;
                            final normW = rawW > 1.0 ? (rawW / 600.0).clamp(0.05, 0.8) : rawW;
                            final normH = rawH > 1.0 ? (rawH / 400.0).clamp(0.05, 0.8) : rawH;

                            final mW = normW * constraints.maxWidth;
                            final mH = normH * constraints.maxHeight;

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
                      },
                    );
                  }),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getRoomBackgroundImage(String? roomName) {
    if (roomName == null) return 'assets/images/living_room.png';
    switch (roomName.toLowerCase()) {
      case 'kitchen':
        return 'assets/images/kitchen.png';
      case 'bedroom':
        return 'assets/images/bedroom.png';
      case 'bathroom':
        return 'assets/images/bathroom.png';
      case 'living room':
      default:
        return 'assets/images/living_room.png';
    }
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
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.black.withValues(alpha: 0.05);
      borderColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.15);
      glowColor = isOn
          ? AppTheme.primaryBlue.withValues(alpha: 0.05)
          : Colors.transparent;
    }

    return Hero(
      tag: device.id,
      child: AnimatedContainer(
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
                    color: isOn || (isDoor && !isLocked) ? AppTheme.primaryBlue : Colors.white70,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.name,
                    style: TextStyle(
                      shadows: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          spreadRadius: 10,
                        )
                      ],
                      color: isOn || (isDoor && !isLocked) ? AppTheme.primaryBlue: Colors.white70,
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
      ),
    );
  }
}
