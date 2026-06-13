import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class DevicePlacementCard extends ConsumerWidget {
  final GlobalKey _imageKey = GlobalKey();

  DevicePlacementCard({super.key});

  String _backgroundImage(String? roomName) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dashboardControllerProvider.notifier);
    final state = ref.watch(dashboardControllerProvider);

    return GlassContainer(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room Device Placement',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                color: AppTheme.primaryBlue,
                onPressed: () => context.push('/room-placement'),
                icon: const Icon(Icons.edit, color: AppTheme.primaryBlue),
              )
            ],
          ),
          const SizedBox(height: 8),

          
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                key: _imageKey,
                children: [
                  // Room Background
                  Positioned.fill(
                    child: Consumer(builder: (context, ref, _) {
                      final room = controller.activeRoom;
                      if (room != null && room.imagePath != null && room.imagePath!.isNotEmpty) {
                        final file = File(room.imagePath!);
                        if (file.existsSync()) {
                          return Image.file(file, fit: BoxFit.cover);
                        }
                      }
                      final bgImage = _backgroundImage(room?.name);
                      return Image.asset(bgImage, fit: BoxFit.cover);
                    }),
                  ),
                  
                  // Semi-transparent overlay
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),

                  // Dynamic Draggable Markers
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Consumer(builder: (context, ref, _) {
                          final activeRoomId = controller.activeRoom?.id ?? '3';
                          final validDevices = state.devices
                              .where((d) => d.positionX != null && d.positionY != null)
                              .where((d) => d.roomId == activeRoomId || (d.roomId == null && activeRoomId == '3'))
                              .toList();

                          return Stack(
                            children: validDevices.map((device) {
                              final posX = device.positionX! * constraints.maxWidth;
                              final posY = device.positionY! * constraints.maxHeight;

                              return Positioned(
                                left: posX - 20,
                                top: posY - 20,
                                child: GestureDetector(
                                  onLongPressStart: (details) {
                                    // Visual feedback can be added here if needed
                                  },
                                  onLongPressMoveUpdate: (details) {
                                    final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
                                    if (renderBox != null) {
                                      final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
                                      final double x = (localOffset.dx / renderBox.size.width).clamp(0.0, 1.0);
                                      final double y = (localOffset.dy / renderBox.size.height).clamp(0.0, 1.0);
                                      controller.updateDevicePosition(device.id, x, y);
                                    }
                                  },
                                  child: _buildDraggableMarker(device),
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
          ),
        ],
      ),
    );
  }

  Widget _buildDraggableMarker(DeviceEntity device) {
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

    return Tooltip(
      message: device.name,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: device.isOn ? AppTheme.primaryBlue : Colors.white24,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 1,
            )
          ],
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
