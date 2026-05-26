import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/add_device_dialog.dart';

class DeviceManagementCard extends GetView<DashboardController> {
  const DeviceManagementCard({super.key});

  void _showAddDeviceDialog() {
    Get.dialog(const AddDeviceDialog());
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Device Management',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                onPressed: _showAddDeviceDialog,
                icon: const Icon(Icons.add, color: AppTheme.primaryBlue),
                tooltip: 'Add Device',
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Long press and drag to reorder devices on the dashboard.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Obx(() {
              if (controller.devices.isEmpty) {
                return const Center(
                  child: Text(
                    'No devices added yet.',
                    style: TextStyle(color: AppTheme.textGrey),
                  ),
                );
              }
              
              return ReorderableListView.builder(
                padding: EdgeInsets.zero,
                itemCount: controller.devices.length,
                // ignore: deprecated_member_use
                onReorder: (oldIndex, newIndex) {
                  // Fallback for compatibility, use both or either if needed
                  controller.reorderDevices(oldIndex, newIndex);
                },
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          )
                        ],
                      ),
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final device = controller.devices[index];
                  return Container(
                    key: ValueKey(device.id),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Icon(
                        _getIconForType(device.type),
                        color: Colors.white70,
                      ),
                      title: Text(
                        device.name,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      subtitle: device.linkedDevicesCount != null && device.linkedDevicesCount! > 0
                          ? Text(
                              '\${device.linkedDevicesCount} linked devices',
                              style: const TextStyle(color: AppTheme.textGrey, fontSize: 11),
                            )
                          : null,
                      trailing: const Icon(Icons.drag_handle, color: Colors.white38),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(dynamic type) {
    switch (type.toString().split('.').last) {
      case 'airConditioner':
        return Icons.ac_unit;
      case 'lamp':
        return Icons.lightbulb_outline;
      case 'vacuum':
        return Icons.cleaning_services;
      case 'door':
        return Icons.door_front_door_outlined;
      default:
        return Icons.devices;
    }
  }
}
