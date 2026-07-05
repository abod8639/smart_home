import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_dialogs.dart';
import 'package:smart_home/features/environment/presentation/providers/environment_provider.dart';

/// Shows room statistics, environment data and a quick "Add Device" button.
class PlacementRoomDetails extends ConsumerWidget {
  /// The controller for dashboard operations.
  final DashboardController dashboardController;

  /// The controller for room device placement state.
  final RoomPlacementController placementController;

  /// Creates a [PlacementRoomDetails].
  const PlacementRoomDetails({
    super.key,
    required this.dashboardController,
    required this.placementController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeRoom = dashboardController.activeRoom;
    final isMobile = Responsive.isMobile(context);
    final gap = Responsive.contentGap(context);

    if (activeRoom == null) {
      return const Center(
        child: Text(
          'No active room selected',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    final roomDevices = ref.watch(dashboardControllerProvider).devices
        .where((d) =>
            d.roomId == activeRoom.id ||
            (d.roomId == null && activeRoom.id == '3'))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Room name + badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                activeRoom.name,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isMobile ? 18.0 : 22.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: gap * 0.75),

        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPropertyRow('Total Devices', '${roomDevices.length} device(s)'),
                SizedBox(height: gap),
                SizedBox(
                  height: Responsive.deviceCardsHeight(context) - 40,
                  child: buildDeviceCards(ref, context),
                ),
                SizedBox(height: gap),
                buildPropertyRow('Temperature', ref.watch(environmentControllerProvider).temperature),
                SizedBox(height: gap),
                buildPropertyRow('Humidity', ref.watch(environmentControllerProvider).humidity),
                SizedBox(height: gap),
                buildPropertyRow('Airflow', ref.watch(environmentControllerProvider).airflow),
                SizedBox(height: gap),
                buildPropertyRow('Power Usage', ref.watch(environmentControllerProvider).powerUsage),
              ],
            ),
          ),
        ),

        SizedBox(height: gap),

        // Add device button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(Icons.add_rounded, color: Colors.white, size: isMobile ? 18 : 22),
            label: Text(
              'Add Device to Room',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 13.0 : 15.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => PlacementDeviceDialogs.showAddDevice(
              context,
              ref,
            ),
          ),
        ),
      ],
    );
  }
}
