import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/dashboard_main_view.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_dialogs.dart';

/// Shows room statistics, environment data and a quick "Add Device" button.
class PlacementRoomDetails extends StatelessWidget {
  final DashboardController dashboardController;
  final RoomPlacementController placementController;

  const PlacementRoomDetails({
    super.key,
    required this.dashboardController,
    required this.placementController,
  });

  @override
  Widget build(BuildContext context) {
    final activeRoom = dashboardController.activeRoom;

    if (activeRoom == null) {
      return const Center(
        child: Text(
          'No active room selected',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    final roomDevices = dashboardController.devices
        .where((d) =>
            d.roomId == activeRoom.id ||
            (d.roomId == null && activeRoom.id == '3'))
        .toList();


   
if (!Responsive.isTablet(context))

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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPropertyRow('Total Devices', '${roomDevices.length} device(s)'),
                const SizedBox(height: 12),
                SizedBox(height: 180, child: buildDeviceCards()),
                const SizedBox(height: 16),
                buildPropertyRow('Temperature', dashboardController.temperature.value),
                const SizedBox(height: 16),
                buildPropertyRow('Humidity', dashboardController.humidity.value),
                const SizedBox(height: 16),
                buildPropertyRow('Airflow', dashboardController.airflow.value),
                const SizedBox(height: 16),
                buildPropertyRow('Power Usage', dashboardController.powerUsage.value),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Add device button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Device to Room',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => PlacementDeviceDialogs.showAddDevice(
              context,
              dashboardController,
              placementController,
            ),
          ),
        ),
      ],
    );
   
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Scrollable content area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildPropertyRow('Total Devices', '${roomDevices.length} device(s)'),
                const SizedBox(height: 12),
                SizedBox(height: 180, child: buildDeviceCards()),
                const SizedBox(height: 16),
                buildPropertyRow('Temperature', dashboardController.temperature.value),
                const SizedBox(height: 16),
                buildPropertyRow('Humidity', dashboardController.humidity.value),
                const SizedBox(height: 16),
                buildPropertyRow('Airflow', dashboardController.airflow.value),
                const SizedBox(height: 16),
                buildPropertyRow('Power Usage', dashboardController.powerUsage.value),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Add device button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Device to Room',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => PlacementDeviceDialogs.showAddDevice(
              context,
              dashboardController,
              placementController,
            ),
          ),
        ),
      ],
    );
  }
}
