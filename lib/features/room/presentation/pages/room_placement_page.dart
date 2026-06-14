import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_properties.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_image_panel.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_room_details.dart';

/// A page for placing and configuring devices within a room.
class RoomPlacementPage extends ConsumerWidget {
  /// Creates a [RoomPlacementPage].
  const RoomPlacementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardController = ref.read(dashboardControllerProvider.notifier);
    final GlobalKey imageKey = GlobalKey();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Room Device Placement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (context.mounted) context.pop();
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.pagePadding(context)),
        child: Responsive.isMobile(context) || Responsive.isTablet(context)
            ? _buildMobileLayout(context, ref, dashboardController, imageKey)
            : _buildWideLayout(context, ref, dashboardController, imageKey),
      ),
    );
  }

  // ── Layouts ─────────────────────────────────────────────────────────────────

  Widget _buildMobileLayout(
    BuildContext context,
    WidgetRef ref,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width / (MediaQuery.of(context).size.height);
        final double imagePanelHeight = (screenWidth * 452).clamp(300, 552);
        final placementController = ref.read(roomPlacementControllerProvider.notifier);

        return Column(
          children: [
            SizedBox(
              height: imagePanelHeight,
              child: PlacementImagePanel(
                dashboardController: dashboardController,
                placementController: placementController,
                imageKey: imageKey,
              ),
            ),
            SizedBox(height: Responsive.contentGap(context)),
            Expanded(
              child: GlassContainer(
                padding: EdgeInsets.all(Responsive.isMobile(context) ? 12 : 16),
                child: Consumer(
                  builder: (context, ref, _) => _buildSidePanel(context, ref, dashboardController),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    final isTablet = Responsive.isTablet(context);
    final sidePanelWidth = isTablet ? 320.0 : 385.0;
    final placementController = ref.read(roomPlacementControllerProvider.notifier);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: PlacementImagePanel(
            dashboardController: dashboardController,
            placementController: placementController,
            imageKey: imageKey,
          ),
        ),
        SizedBox(width: Responsive.contentGap(context)),
        SizedBox(
          width: sidePanelWidth,
          child: GlassContainer(
            padding: EdgeInsets.all(isTablet ? 16 : 24),
            child: Consumer(
              builder: (context, ref, _) => _buildSidePanel(context, ref, dashboardController),
            ),
          ),
        ),
      ],
    );
  }

  // ── Side-panel selector ──────────────────────────────────────────────────────

  Widget _buildSidePanel(
    BuildContext context,
    WidgetRef ref,
    DashboardController dashboardController,
  ) {
    final selectedId = ref.watch(roomPlacementControllerProvider);
    final placementController = ref.read(roomPlacementControllerProvider.notifier);

    // No selection → show room details
    if (selectedId == null) {
      return PlacementRoomDetails(
        dashboardController: dashboardController,
        placementController: placementController,
      );
    }

    final dashboardState = ref.watch(dashboardControllerProvider);
    final device = dashboardState.devices.firstWhereOrNull(
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
        placementController: placementController,
      );
    }

    // Show the selected device's properties
    return PlacementDeviceProperties(
      device: device,
      dashboardController: dashboardController,
      placementController: placementController,
    );
  }
  
}
