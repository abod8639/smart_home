import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_dialogs.dart';

/// Shows properties and quick-toggle for the currently selected device.
class PlacementDeviceProperties extends StatelessWidget {
  final DeviceEntity device;
  final DashboardController dashboardController;
  final RoomPlacementController placementController;

  const PlacementDeviceProperties({
    super.key,
    required this.device,
    required this.dashboardController,
    required this.placementController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Device Properties',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined,
                      color: AppTheme.primaryBlue, size: 20),
                  onPressed: () => PlacementDeviceDialogs.showEditDevice(
                    context,
                    device,
                    dashboardController,
                  ),
                  tooltip: 'Edit Device',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: () => PlacementDeviceDialogs.showDeleteConfirmation(
                    context,
                    device,
                    dashboardController,
                    placementController,
                  ),
                  tooltip: 'Delete Device',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Properties
        buildPropertyRow('Name', device.name),
        const SizedBox(height: 16),
        buildPropertyRow('Type', device.type.name.capitalizeFirst ?? ''),
        const SizedBox(height: 16),
        buildPropertyRow('Status', device.isOn ? 'ON' : 'OFF'),

        if (device.type == DeviceType.lamp && device.brightness != null) ...[
          const SizedBox(height: 16),
          buildPropertyRow('Brightness', '${device.brightness}%'),
        ],

        if (device.type == DeviceType.airConditioner &&
            device.temperature != null) ...[
          const SizedBox(height: 16),
          buildPropertyRow('Temperature', '${device.temperature}°C'),
          const SizedBox(height: 16),
          buildPropertyRow('Mode', device.mode ?? 'Auto'),
        ],

        if (device.type == DeviceType.vacuum) ...[
          const SizedBox(height: 16),
          buildPropertyRow('Battery', '${device.batteryLevel ?? 0}%'),
        ],

        if (device.type == DeviceType.lamp && device.linkedDevicesCount != null) ...[
          const SizedBox(height: 16),
          buildPropertyRow('Linked Devices', '${device.linkedDevicesCount}'),
        ],

        if (device.type == DeviceType.rgb) ...[
          const SizedBox(height: 16),
          buildPropertyRow(
            'Color',
            'rgb(${device.rgbR ?? 0}, ${device.rgbG ?? 0}, ${device.rgbB ?? 0})',
          ),
          const SizedBox(height: 10),
          // Live colour swatch
          Container(
            height: 32,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Color.fromRGBO(
                device.rgbR ?? 0,
                device.rgbG ?? 0,
                device.rgbB ?? 0,
                1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Color.fromRGBO(
                    device.rgbR ?? 0,
                    device.rgbG ?? 0,
                    device.rgbB ?? 0,
                    0.5,
                  ),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          if (device.brightness != null) ...[
            const SizedBox(height: 16),
            buildPropertyRow('Brightness', '${device.brightness}%'),
          ],
        ],

        const Spacer(),

        // Toggle button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (device.type == DeviceType.door) {
                dashboardController.toggleDoor(device.id);
              } else {
                dashboardController.toggleDevice(device.id);
              }
            },
            child: Text(
              device.type == DeviceType.door
                  ? (device.isLocked ?? true ? 'Unlock Device' : 'Lock Device')
                  : (device.isOn ? 'Turn OFF' : 'Turn ON'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
