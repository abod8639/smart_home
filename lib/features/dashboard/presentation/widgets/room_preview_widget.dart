import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/pulsing_dot_marker.dart';
import 'package:smart_home/features/room/presentation/widgets/card_device_marker.dart';

class RoomPreviewWidget extends GetView<DashboardController> {
  const RoomPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Obx(() {
          final activeRoom = controller.activeRoom;
          final ImageProvider imageProvider;
          if (activeRoom != null && activeRoom.imagePath != null && activeRoom.imagePath!.isNotEmpty && File(activeRoom.imagePath!).existsSync()) {
            imageProvider = FileImage(File(activeRoom.imagePath!));
          } else {
            imageProvider = AssetImage(_getRoomBackgroundImage(activeRoom?.name));
          }

          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              
              image: DecorationImage(
                image: imageProvider,
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
                Padding(
                  padding: EdgeInsets.all(Responsive.isMobile(context) ? 8.0 : 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Environment Stats
                      Row(
                        children: [
                          _buildStatChip(Icons.water_drop_outlined, controller.humidity.value, Responsive.isMobile(context)),
                          SizedBox(width: Responsive.isMobile(context) ? 6 : 12),
                          _buildStatChip(Icons.air_outlined, controller.airflow.value, Responsive.isMobile(context)),
                          SizedBox(width: Responsive.isMobile(context) ? 6 : 12),
                          _buildStatChip(Icons.thermostat_outlined, controller.temperature.value, Responsive.isMobile(context)),
                          SizedBox(width: Responsive.isMobile(context) ? 6 : 12),
                          _buildStatChip(Icons.wifi_outlined, controller.wifiRssi.value, Responsive.isMobile(context)),
                          SizedBox(width: Responsive.isMobile(context) ? 6 : 12),
                          _buildStatChip(Icons.memory_outlined, controller.heapFree.value, Responsive.isMobile(context)),
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

                            final double mW;
                            final double mH;

                            if (device.showAsDot) {
                              mW = 28.0;
                              mH = 28.0;
                            } else {
                              final rawW = device.markerWidth ?? 0.18;
                              final rawH = device.markerHeight ?? 0.15;
                              final normW = rawW > 1.0 ? (rawW / 600.0).clamp(0.05, 0.8) : rawW;
                              final normH = rawH > 1.0 ? (rawH / 400.0).clamp(0.05, 0.8) : rawH;

                              mW = normW * constraints.maxWidth;
                              mH = normH * constraints.maxHeight;
                            }

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
                                child: device.showAsDot
                                    ? PulsingDotMarker(device: device)
                                    : CardDeviceMarker(
                                        device: device,
                                        mW: mW,
                                        mH: mH,
                                      ),
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

  Widget _buildStatChip(IconData icon, String value, bool isMobile) {
    return GlassContainer(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 16, 
        vertical: isMobile ? 4 : 8,
      ),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: isMobile ? 12 : 16),
          SizedBox(width: isMobile ? 4 : 6),
          Text(
            value, 
            style: TextStyle(
              color: Colors.white, 
              fontSize: isMobile ? 10 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
