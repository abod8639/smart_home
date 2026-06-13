import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_marker.dart';
import 'package:smart_home/features/room/presentation/widgets/rooms_list_widget.dart';

/// The left/main panel: room image + rooms list + draggable device markers.
class PlacementImagePanel extends ConsumerWidget {
  final DashboardController dashboardController;
  final RoomPlacementController placementController;
  final GlobalKey imageKey;

  const PlacementImagePanel({
    super.key,
    required this.dashboardController,
    required this.placementController,
    required this.imageKey,
  });

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
    final isMobile = Responsive.isMobile(context);
    return GlassContainer(
      padding: EdgeInsets.all(isMobile ? 10 : 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final showRoomsList = constraints.maxHeight > 180.0;
          
          final imageWidget = Center(
            child: AspectRatio(
              aspectRatio: 19 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  key: imageKey,
                  children: [
                    // Background image (reactive to selected room)
                    Positioned.fill(
                      child: Consumer(builder: (context, ref, _) {
                        final room = dashboardController.activeRoom;
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

                    // Dark overlay
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ),

                    // Device markers
                    Positioned.fill(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Consumer(builder: (context, ref, _) {
                            final activeRoomId =
                                dashboardController.activeRoom?.id ?? '3';
                            final validDevices = ref.watch(dashboardControllerProvider).devices
                                .where((d) =>
                                    d.positionX != null && d.positionY != null)
                                .where((d) =>
                                    d.roomId == activeRoomId ||
                                    (d.roomId == null && activeRoomId == '3'))
                                .toList();

                            return Stack(
                              children: validDevices.map((device) {
                                final posX =
                                    device.positionX! * constraints.maxWidth;
                                final posY =
                                    device.positionY! * constraints.maxHeight;

                                final showAsDot = device.showAsDot;
                                final double mW;
                                final double mH;

                                if (showAsDot) {
                                  mW = 32.0;
                                  mH = 32.0;
                                } else {
                                  final rawW = device.markerWidth ?? 0.18;
                                  final rawH = device.markerHeight ?? 0.15;
                                  final normW = rawW > 1.0
                                      ? (rawW / 600.0).clamp(0.05, 0.8)
                                      : rawW;
                                  final normH = rawH > 1.0
                                      ? (rawH / 400.0).clamp(0.05, 0.8)
                                      : rawH;

                                  mW = normW * constraints.maxWidth;
                                  mH = normH * constraints.maxHeight;
                                }

                                 final isSelected =
                                     ref.watch(roomPlacementControllerProvider) ==
                                     device.id;

                                return Positioned(
                                  left: posX - mW / 2,
                                  top: posY - mH / 2,
                                  child: PlacementDeviceMarker(
                                    key: ValueKey('${device.id}_${device.showAsDot}'),
                                    device: device,
                                    isSelected: isSelected,
                                    dashboardController: dashboardController,
                                    placementController: placementController,
                                    imageKey: imageKey,
                                    parentWidth: constraints.maxWidth,
                                    parentHeight: constraints.maxHeight,
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
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showRoomsList) ...[
                SizedBox(
                  height: isMobile ? 83 : 100,
                  child: const RoomsListWidget(isCompact: true),
                ),
                const SizedBox(height: 6),
              ],
              Expanded(child: imageWidget),
            ],
          );
        },
      ),
    );
  }
}
