import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

/// Dialog helper class for device management dialogs.
class PlacementDeviceDialogs {
  PlacementDeviceDialogs._();

  /// List of ESP32 GPIO pin configuration options.
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

  /// Displays a dialog to add a new device to the active room.
  static void showAddDevice(
    BuildContext context,
    WidgetRef ref,
  ) {
    final nameController = TextEditingController();
    final linkedCountController = TextEditingController(text: '0');
    DeviceType selectedType = DeviceType.lamp;
    bool showAsDot = false;
    int? selectedPin;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dashboardState = ref.watch(dashboardControllerProvider);
            final dashboardController = ref.read(dashboardControllerProvider.notifier);
            final placementController = ref.read(roomPlacementControllerProvider.notifier);

            final usedPins = dashboardState.devices
                .map((d) => d.pin)
                .whereType<int>()
                .toSet();

            return AlertDialog(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DeviceType>(
                          value: selectedType,
                          dropdownColor: AppTheme.cardBackground,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedType = val;
                              });
                            }
                          },
                          items: DeviceType.values.map((type) {
                            final typeName = type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(iconForDeviceType(type),
                                      color: AppTheme.primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Text(typeName),
                                ],
                              ),
                            );
                          }).toList(),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedPin,
                          dropdownColor: AppTheme.cardBackground,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              selectedPin = val;
                            });
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
                    SwitchListTile(
                      title: const Text(
                        'Show as Glowing Dot',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Compact glowing marker instead of card',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                      ),
                      value: showAsDot,
                      activeThumbColor: AppTheme.primaryBlue,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          showAsDot = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Validation: Device name cannot be empty')));
                      return;
                    }
                    final linkedCount = int.tryParse(linkedCountController.text) ?? 0;
                    final id = const Uuid().v4();

                    DeviceEntity newDevice;
                    switch (selectedType) {
                      case DeviceType.airConditioner:
                        newDevice = AcDeviceEntity(
                          id: id,
                          name: name,
                          positionX: 0.5,
                          positionY: 0.5,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          temperature: 24,
                          mode: 'Auto mode',
                          coolingTime: 0,
                          acIrCodes: const AcIrCodes(),
                        );
                        break;
                      case DeviceType.lamp:
                        newDevice = LampDeviceEntity(
                          id: id,
                          name: name,
                          positionX: 0.5,
                          positionY: 0.5,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          brightness: 50,
                        );
                        break;
                      case DeviceType.rgb:
                        newDevice = RgbLampDeviceEntity(
                          id: id,
                          name: name,
                          positionX: 0.5,
                          positionY: 0.5,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          brightness: 50,
                          rgbR: 255,
                          rgbG: 255,
                          rgbB: 255,
                        );
                        break;
                      case DeviceType.door:
                        newDevice = DoorDeviceEntity(
                          id: id,
                          name: name,
                          positionX: 0.5,
                          positionY: 0.5,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          isLocked: true,
                          linkedDevicesCount: linkedCount,
                        );
                        break;
                      case DeviceType.vacuum:
                        newDevice = VacuumDeviceEntity(
                          id: id,
                          name: name,
                          positionX: 0.5,
                          positionY: 0.5,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          batteryLevel: 100,
                          areaCleaned: 0,
                          cleaningTime: 0,
                          filterStatus: 100,
                        );
                        break;
                    }
                    dashboardController.addDevice(newDevice);
                    placementController.selectDevice(newDevice.id);
                    if (context.mounted) context.pop();
                  },
                  child: const Text(
                    'Add',
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── Delete Device ───────────────────────────────────────────────────────────

  /// Displays a confirmation dialog before deleting a device.
  static void showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    DeviceEntity device,
  ) {
    final dashboardController = ref.read(dashboardControllerProvider.notifier);
    final placementController = ref.read(roomPlacementControllerProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () {
              if (context.mounted) context.pop();
            },
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () {
              dashboardController.deleteDevice(device.id);
              placementController.selectDevice(null);
              if (context.mounted) context.pop();
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

  /// Displays a dialog to edit the properties of an existing device.
  static void showEditDevice(
    BuildContext context,
    WidgetRef ref,
    DeviceEntity device,
  ) {
    final nameController = TextEditingController(text: device.name);
    final linkedCountController = TextEditingController(
      text: (device.linkedDevicesCount ?? 0).toString(),
    );
    DeviceType selectedType = device.type;
    bool showAsDot = device.showAsDot;
    int? selectedPin = device.pin;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            final dashboardState = ref.watch(dashboardControllerProvider);
            final dashboardController = ref.read(dashboardControllerProvider.notifier);

            final usedPins = dashboardState.devices
                .where((d) => d.id != device.id)
                .map((d) => d.pin)
                .whereType<int>()
                .toSet();

            return AlertDialog(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<DeviceType>(
                          value: selectedType,
                          dropdownColor: AppTheme.cardBackground,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                selectedType = val;
                              });
                            }
                          },
                          items: DeviceType.values.map((type) {
                            final typeName = type.name.substring(0, 1).toUpperCase() + type.name.substring(1);
                            return DropdownMenuItem(
                              value: type,
                              child: Row(
                                children: [
                                  Icon(iconForDeviceType(type),
                                      color: AppTheme.primaryBlue, size: 18),
                                  const SizedBox(width: 8),
                                  Text(typeName),
                                ],
                              ),
                            );
                          }).toList(),
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int?>(
                          value: selectedPin,
                          dropdownColor: AppTheme.cardBackground,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              selectedPin = val;
                            });
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
                    SwitchListTile(
                      title: const Text(
                        'Show as Glowing Dot',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Compact glowing marker instead of card',
                        style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
                      ),
                      value: showAsDot,
                      activeThumbColor: AppTheme.primaryBlue,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) {
                        setState(() {
                          showAsDot = val;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (context.mounted) context.pop();
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                ),
                TextButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;
                    final linkedCount = int.tryParse(linkedCountController.text) ?? 0;
                    DeviceEntity updated = device;

                    if (device.type == selectedType) {
                      if (device is DoorDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          linkedDevicesCount: linkedCount,
                        );
                      } else if (device is AcDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                        );
                      } else if (device is LampDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                        );
                      } else if (device is RgbLampDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                        );
                      } else if (device is VacuumDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                        );
                      } else {
                        updated = device;
                      }
                    } else {
                      switch (selectedType) {
                        case DeviceType.airConditioner:
                          updated = AcDeviceEntity(
                            id: device.id,
                            name: name,
                            isOn: device.isOn,
                            roomId: device.roomId,
                            positionX: device.positionX,
                            positionY: device.positionY,
                            markerWidth: device.markerWidth,
                            markerHeight: device.markerHeight,
                            matterNodeId: device.matterNodeId,
                            matterEndpointId: device.matterEndpointId,
                            showAsDot: showAsDot,
                            pin: selectedPin,
                            temperature: 24,
                            mode: 'Auto mode',
                            coolingTime: 0,
                            acIrCodes: const AcIrCodes(),
                          );
                          break;
                        case DeviceType.lamp:
                          updated = LampDeviceEntity(
                            id: device.id,
                            name: name,
                            isOn: device.isOn,
                            roomId: device.roomId,
                            positionX: device.positionX,
                            positionY: device.positionY,
                            markerWidth: device.markerWidth,
                            markerHeight: device.markerHeight,
                            matterNodeId: device.matterNodeId,
                            matterEndpointId: device.matterEndpointId,
                            showAsDot: showAsDot,
                            pin: selectedPin,
                            brightness: 50,
                          );
                          break;
                        case DeviceType.rgb:
                          updated = RgbLampDeviceEntity(
                            id: device.id,
                            name: name,
                            isOn: device.isOn,
                            roomId: device.roomId,
                            positionX: device.positionX,
                            positionY: device.positionY,
                            markerWidth: device.markerWidth,
                            markerHeight: device.markerHeight,
                            matterNodeId: device.matterNodeId,
                            matterEndpointId: device.matterEndpointId,
                            showAsDot: showAsDot,
                            pin: selectedPin,
                            brightness: 50,
                            rgbR: 255,
                            rgbG: 255,
                            rgbB: 255,
                          );
                          break;
                        case DeviceType.door:
                          updated = DoorDeviceEntity(
                            id: device.id,
                            name: name,
                            isOn: device.isOn,
                            roomId: device.roomId,
                            positionX: device.positionX,
                            positionY: device.positionY,
                            markerWidth: device.markerWidth,
                            markerHeight: device.markerHeight,
                            matterNodeId: device.matterNodeId,
                            matterEndpointId: device.matterEndpointId,
                            showAsDot: showAsDot,
                            pin: selectedPin,
                            isLocked: true,
                            linkedDevicesCount: linkedCount,
                          );
                          break;
                        case DeviceType.vacuum:
                          updated = VacuumDeviceEntity(
                            id: device.id,
                            name: name,
                            isOn: device.isOn,
                            roomId: device.roomId,
                            positionX: device.positionX,
                            positionY: device.positionY,
                            markerWidth: device.markerWidth,
                            markerHeight: device.markerHeight,
                            matterNodeId: device.matterNodeId,
                            matterEndpointId: device.matterEndpointId,
                            showAsDot: showAsDot,
                            pin: selectedPin,
                            batteryLevel: 100,
                            areaCleaned: 0,
                            cleaningTime: 0,
                            filterStatus: 100,
                          );
                          break;
                      }
                    }
                    dashboardController.updateDevice(updated);
                    if (context.mounted) context.pop();
                  },
                  child: const Text(
                    'Save',
                    style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
