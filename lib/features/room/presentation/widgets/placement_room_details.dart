import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/app_button.dart';
import 'package:smart_home/core/widgets/app_property_row.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/features/environment/presentation/controllers/environment_controller.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_dialogs.dart';
import 'package:smart_home/features/room/presentation/widgets/room_management_dialogs.dart';

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
        // Room name + Edit/Delete buttons
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined,
                      color: AppTheme.primaryBlue, size: isMobile ? 18 : 20),
                  onPressed: () => RoomManagementDialogs.showEditRoomDialog(
                    context,
                    ref,
                    activeRoom,
                  ),
                  tooltip: 'Edit Room Name',
                ),
                if (activeRoom.name.toLowerCase() != 'living room')
                  IconButton(
                    icon: Icon(Icons.delete_outline,
                        color: Colors.redAccent, size: isMobile ? 18 : 20),
                    onPressed: () => RoomManagementDialogs.showDeleteConfirmation(
                      context,
                      ref,
                      activeRoom,
                    ),
                    tooltip: 'Delete Room',
                  ),
              ],
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
                AppPropertyRow(label: 'Total Devices', value: '${roomDevices.length} device(s)'),
                SizedBox(height: gap),
                SizedBox(
                  height: Responsive.deviceCardsHeight(context) - 40,
                  child: buildDeviceCards(ref, context),
                ),
                SizedBox(height: gap),
                AppPropertyRow(label: 'Temperature', value: ref.watch(environmentControllerProvider).temperature),
                SizedBox(height: gap),
                AppPropertyRow(label: 'Humidity', value: ref.watch(environmentControllerProvider).humidity),
                SizedBox(height: gap),
                AppPropertyRow(label: 'Airflow', value: ref.watch(environmentControllerProvider).airflow),
                SizedBox(height: gap),
                AppPropertyRow(label: 'Power Usage', value: ref.watch(environmentControllerProvider).powerUsage),
              ],
            ),
          ),
        ),

        SizedBox(height: gap),

        // Add device button
        AppButton(
          text: 'Add Device to Room',
          icon: Icon(Icons.add_rounded, color: Colors.white, size: isMobile ? 18 : 22),
          onPressed: () => PlacementDeviceDialogs.showAddDevice(
            context,
            ref,
          ),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          borderRadius: AppRadii.md,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 12 : 16),
          height: isMobile ? 46 : 52,
        ),
      ],
    );
  }
}
