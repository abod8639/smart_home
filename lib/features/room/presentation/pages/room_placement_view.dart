import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_properties.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_image_panel.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_room_details.dart';

class RoomPlacementView extends GetView<RoomPlacementController> {
  const RoomPlacementView({super.key});

  @override
  Widget build(BuildContext context) {
    final dashboardController = Get.find<DashboardController>();
    final GlobalKey imageKey = GlobalKey();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Room Device Placement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.pagePadding(context)),
        child: Responsive.isMobile(context)
            ? _buildMobileLayout(context, dashboardController, imageKey)
            : _buildWideLayout(context, dashboardController, imageKey),
      ),
    );
  }

  // ── Layouts ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(
    BuildContext context,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: PlacementImagePanel(
            dashboardController: dashboardController,
            placementController: controller,
            imageKey: imageKey,
          ),
        ),
        // SizedBox(height: Responsive.contentGap(context)),
        Expanded(
          flex: 2,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Obx(
              () => _buildSidePanel(context, dashboardController),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: Responsive.isTablet(context) ? 2 : 3,
          child: PlacementImagePanel(
            dashboardController: dashboardController,
            placementController: controller,
            imageKey: imageKey,
          ),
        ),
        SizedBox(width: Responsive.contentGap(context)),
        Expanded(
          flex: 1,
          child: GlassContainer(
            padding: EdgeInsets.all(Responsive.isTablet(context) ? 16 : 24),
            child: Obx(
              () => _buildSidePanel(context, dashboardController),
            ),
          ),
        ),
      ],
    );
  }

  // ── Side-panel selector ──────────────────────────────────────────────────────

  Widget _buildSidePanel(
    BuildContext context,
    DashboardController dashboardController,
  ) {
    final selectedId = controller.selectedDeviceId.value;

    // No selection → show room details
    if (selectedId == null) {
      return PlacementRoomDetails(
        dashboardController: dashboardController,
        placementController: controller,
      );
    }

    final device = dashboardController.devices.firstWhereOrNull(
      (d) => d.id == selectedId,
    );

    // Device not found
    if (device == null) {
      return const Center(
        child: Text('Device not found', style: TextStyle(color: AppTheme.textGrey)),
      );
    }

    // Device belongs to a different room → show room details
    final activeRoomId = dashboardController.activeRoom?.id ?? '3';
    final deviceRoomId = device.roomId ?? '3';
    if (deviceRoomId != activeRoomId) {
      return PlacementRoomDetails(
        dashboardController: dashboardController,
        placementController: controller,
      );
    }

    // Show the selected device's properties
    return PlacementDeviceProperties(
      device: device,
      dashboardController: dashboardController,
      placementController: controller,
    );
  }
}
