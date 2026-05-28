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

  static const List<Map<String, dynamic>> esp32Pins = [
    {'pin': 2, 'label': 'GPIO 2 (relay_1)', 'isPwm': false},
    {'pin': 18, 'label': 'GPIO 18 (relay_2)', 'isPwm': false},
    {'pin': 19, 'label': 'GPIO 19 (relay_3)', 'isPwm': false},
    {'pin': 21, 'label': 'GPIO 21 (relay_4)', 'isPwm': false},
    {'pin': 22, 'label': 'GPIO 22 (pwm_lamp)', 'isPwm': true},
    {'pin': 23, 'label': 'GPIO 23 (pwm_rgb_r)', 'isPwm': true},
    {'pin': 25, 'label': 'GPIO 25 (pwm_rgb_g)', 'isPwm': true},
    {'pin': 26, 'label': 'GPIO 26 (pwm_rgb_b)', 'isPwm': true},
  ];

  // ── Add Device ─────────────────────────────────────────────────────────────

  static void showAddDevice(
    BuildContext context,
    DashboardController dashboardController,
    RoomPlacementController placementController,
  ) {
    final nameController = TextEditingController();
    final linkedCountController = TextEditingController(text: '0');
    var selectedType = DeviceType.lamp.obs;
    var showAsDot = false.obs;
    var selectedPin = Rx<int?>(null);

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
              const Text(
                'ESP32 Pin / طرف ESP32',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'الطرف (GPIO) المتحكم في تشغيل وإطفاء الجهاز',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Obx(
                () {
                  final usedPins = dashboardController.devices
                      .map((d) => d.pin)
                      .whereType<int>()
                      .toSet();

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedPin.value,
                        dropdownColor: AppTheme.cardBackground,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (val) {
                          selectedPin.value = val;
                        },
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(Icons.link_off, color: AppTheme.textGrey, size: 18),
                                SizedBox(width: 8),
                                Text('None / Not Connected (غير متصل)', style: TextStyle(color: AppTheme.textGrey)),
                              ],
                            ),
                          ),
                          ...esp32Pins.map((p) {
                            final pinVal = p['pin'] as int;
                            final isPwm = p['isPwm'] as bool;
                            final isUsed = usedPins.contains(pinVal);

                            return DropdownMenuItem<int?>(
                              value: pinVal,
                              enabled: !isUsed,
                              child: Row(
                                children: [
                                  Icon(
                                    isPwm ? Icons.waves : Icons.bolt,
                                    color: isUsed ? Colors.white24 : (isPwm ? Colors.orangeAccent : AppTheme.primaryBlue),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p['label'] as String,
                                      style: TextStyle(
                                        color: isUsed ? Colors.white24 : Colors.white,
                                        decoration: isUsed ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                  if (isUsed)
                                    const Text(
                                      'In Use (مستعمل)',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 11),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
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
              const SizedBox(height: 20),
              Obx(
                () => SwitchListTile(
                  title: const Text(
                    'Show as Glowing Dot',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Compact glowing marker instead of card',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                  ),
                  value: showAsDot.value,
                  activeColor: AppTheme.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => showAsDot.value = val,
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
                showAsDot: showAsDot.value,
                pin: selectedPin.value,
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
    var showAsDot = device.showAsDot.obs;
    var selectedPin = Rx<int?>(device.pin);

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
              const Text(
                'ESP32 Pin / طرف ESP32',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
              ),
              const SizedBox(height: 4),
              const Text(
                'الطرف (GPIO) المتحكم في تشغيل وإطفاء الجهاز',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
              ),
              const SizedBox(height: 8),
              Obx(
                () {
                  final usedPins = dashboardController.devices
                      .where((d) => d.id != device.id)
                      .map((d) => d.pin)
                      .whereType<int>()
                      .toSet();

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int?>(
                        value: selectedPin.value,
                        dropdownColor: AppTheme.cardBackground,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        onChanged: (val) {
                          selectedPin.value = val;
                        },
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Row(
                              children: [
                                Icon(Icons.link_off, color: AppTheme.textGrey, size: 18),
                                SizedBox(width: 8),
                                Text('None / Not Connected (غير متصل)', style: TextStyle(color: AppTheme.textGrey)),
                              ],
                            ),
                          ),
                          ...esp32Pins.map((p) {
                            final pinVal = p['pin'] as int;
                            final isPwm = p['isPwm'] as bool;
                            final isUsed = usedPins.contains(pinVal);

                            return DropdownMenuItem<int?>(
                              value: pinVal,
                              enabled: !isUsed,
                              child: Row(
                                children: [
                                  Icon(
                                    isPwm ? Icons.waves : Icons.bolt,
                                    color: isUsed ? Colors.white24 : (isPwm ? Colors.orangeAccent : AppTheme.primaryBlue),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      p['label'] as String,
                                      style: TextStyle(
                                        color: isUsed ? Colors.white24 : Colors.white,
                                        decoration: isUsed ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                  ),
                                  if (isUsed)
                                    const Text(
                                      'In Use (مستعمل)',
                                      style: TextStyle(color: Colors.redAccent, fontSize: 11),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                },
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
              const SizedBox(height: 20),
              Obx(
                () => SwitchListTile(
                  title: const Text(
                    'Show as Glowing Dot',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: const Text(
                    'Compact glowing marker instead of card',
                    style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                  ),
                  value: showAsDot.value,
                  activeColor: AppTheme.primaryBlue,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => showAsDot.value = val,
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
                showAsDot: showAsDot.value,
                pin: selectedPin.value,
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
