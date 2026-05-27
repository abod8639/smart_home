import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:uuid/uuid.dart';

// ─── Shared helpers ───────────────────────────────────────────────────────────

/// Returns the icon that represents [type] in dialogs and lists.
IconData iconForDeviceType(DeviceType type) {
  switch (type) {
    case DeviceType.lamp:
      return Icons.lightbulb_outline;
    case DeviceType.airConditioner:
      return Icons.ac_unit;
    case DeviceType.vacuum:
      return Icons.cleaning_services_outlined;
    case DeviceType.door:
      return Icons.sensor_door_outlined;
    case DeviceType.rgb:
      return Icons.wb_incandescent_rounded;
  }
}

/// A two-line label/value row used in the properties and room-details panels.
Widget buildPropertyRow(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

// ─── Dialogs ──────────────────────────────────────────────────────────────────

class PlacementDeviceDialogs {
  PlacementDeviceDialogs._();

  // ── Add Device ─────────────────────────────────────────────────────────────

  static void showAddDevice(
    BuildContext context,
    DashboardController dashboardController,
    RoomPlacementController placementController,
  ) {
    final nameController = TextEditingController();
    final linkedCountController = TextEditingController(text: '0');
    var selectedType = DeviceType.lamp.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue, size: 22),
            SizedBox(width: 8),
            Text(
              'Add New Device',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  hintText: 'e.g. Bedroom Lamp',
                  hintStyle: TextStyle(color: Colors.white24),
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Device Type',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DeviceType>(
                      value: selectedType.value,
                      dropdownColor: AppTheme.cardBackground,
                      isExpanded: true,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (val) {
                        if (val != null) selectedType.value = val;
                      },
                      items: DeviceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(iconForDeviceType(type),
                                  color: AppTheme.primaryBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(type.name.capitalizeFirst ?? ''),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: linkedCountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Linked Devices Count',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) {
                Get.snackbar(
                  'Validation',
                  'Device name cannot be empty',
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  margin: const EdgeInsets.all(16),
                );
                return;
              }
              final newDevice = DeviceEntity(
                id: const Uuid().v4(),
                name: name,
                type: selectedType.value,
                linkedDevicesCount: int.tryParse(linkedCountController.text) ?? 0,
                positionX: 0.5,
                positionY: 0.5,
              );
              dashboardController.addDevice(newDevice);
              placementController.selectDevice(newDevice.id);
              Get.back();
            },
            child: const Text(
              'Add',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Delete Device ───────────────────────────────────────────────────────────

  static void showDeleteConfirmation(
    BuildContext context,
    DeviceEntity device,
    DashboardController dashboardController,
    RoomPlacementController placementController,
  ) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Delete Device',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete ${device.name}?',
          style: const TextStyle(color: AppTheme.textGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () {
              dashboardController.deleteDevice(device.id);
              placementController.selectDevice(null);
              Get.back();
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ── Edit Device ─────────────────────────────────────────────────────────────

  static void showEditDevice(
    BuildContext context,
    DeviceEntity device,
    DashboardController dashboardController,
  ) {
    final nameController = TextEditingController(text: device.name);
    final linkedCountController = TextEditingController(
      text: (device.linkedDevicesCount ?? 0).toString(),
    );
    var selectedType = device.type.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text(
          'Edit Device',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Device Name',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Device Type',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 8),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DeviceType>(
                      value: selectedType.value,
                      dropdownColor: AppTheme.cardBackground,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      onChanged: (val) {
                        if (val != null) selectedType.value = val;
                      },
                      items: DeviceType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Row(
                            children: [
                              Icon(iconForDeviceType(type),
                                  color: AppTheme.primaryBlue, size: 18),
                              const SizedBox(width: 8),
                              Text(type.name.capitalizeFirst ?? ''),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: linkedCountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Linked Devices Count',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryBlue),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final updated = device.copyWith(
                name: name,
                type: selectedType.value,
                linkedDevicesCount: int.tryParse(linkedCountController.text) ?? 0,
              );
              dashboardController.updateDevice(updated);
              Get.back();
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
