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

class Esp32PinConfig {
  final int pin;
  final bool isPwm;
  final String label;

  const Esp32PinConfig({
    required this.pin,
    required this.isPwm,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Esp32PinConfig &&
          runtimeType == other.runtimeType &&
          pin == other.pin &&
          isPwm == other.isPwm;

  @override
  int get hashCode => pin.hashCode ^ isPwm.hashCode;
}

/// Dialog helper class for device management dialogs.
class PlacementDeviceDialogs {
  PlacementDeviceDialogs._();

  /// List of ESP32 GPIO pin configuration options.
  static const List<Esp32PinConfig> esp32Pins = [
    // Relays
    Esp32PinConfig(pin: 2, label: 'GPIO 2 (relay_1)', isPwm: false),
    Esp32PinConfig(pin: 18, label: 'GPIO 18 (relay_2)', isPwm: false),
    Esp32PinConfig(pin: 19, label: 'GPIO 19 (relay_3)', isPwm: false),
    Esp32PinConfig(pin: 21, label: 'GPIO 21 (relay_4)', isPwm: false),
    Esp32PinConfig(pin: 5, label: 'GPIO 5 (relay_5)', isPwm: false),
    Esp32PinConfig(pin: 12, label: 'GPIO 12 (relay_6)', isPwm: false),
    Esp32PinConfig(pin: 13, label: 'GPIO 13 (relay_7)', isPwm: false),
    Esp32PinConfig(pin: 14, label: 'GPIO 14 (relay_8)', isPwm: false),
    Esp32PinConfig(pin: 15, label: 'GPIO 15 (relay_9)', isPwm: false),
    Esp32PinConfig(pin: 16, label: 'GPIO 16 (relay_10)', isPwm: false),
    Esp32PinConfig(pin: 17, label: 'GPIO 17 (relay_11)', isPwm: false),
    Esp32PinConfig(pin: 27, label: 'GPIO 27 (relay_12)', isPwm: false),

    // PWMs
    Esp32PinConfig(pin: 22, label: 'GPIO 22 (pwm_lamp)', isPwm: true),
    Esp32PinConfig(pin: 23, label: 'GPIO 23 (pwm_rgb_r)', isPwm: true),
    Esp32PinConfig(pin: 25, label: 'GPIO 25 (pwm_rgb_g)', isPwm: true),
    Esp32PinConfig(pin: 26, label: 'GPIO 26 (pwm_rgb_b)', isPwm: true),
    Esp32PinConfig(pin: 5, label: 'GPIO 5 (pwm_5)', isPwm: true),
    Esp32PinConfig(pin: 12, label: 'GPIO 12 (pwm_6)', isPwm: true),
    Esp32PinConfig(pin: 13, label: 'GPIO 13 (pwm_7)', isPwm: true),
    Esp32PinConfig(pin: 14, label: 'GPIO 14 (pwm_8)', isPwm: true),
    Esp32PinConfig(pin: 15, label: 'GPIO 15 (pwm_9)', isPwm: true),
    Esp32PinConfig(pin: 16, label: 'GPIO 16 (pwm_10)', isPwm: true),
    Esp32PinConfig(pin: 17, label: 'GPIO 17 (pwm_11)', isPwm: true),
    Esp32PinConfig(pin: 27, label: 'GPIO 27 (pwm_12)', isPwm: true),
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
    Esp32PinConfig? selectedPinConfig;

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
                        child: DropdownButton<Esp32PinConfig?>(
                          value: selectedPinConfig,
                          dropdownColor: AppTheme.cardBackground,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              selectedPinConfig = val;
                            });
                          },
                          items: [
                            const DropdownMenuItem<Esp32PinConfig?>(
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
                              final isUsed = usedPins.contains(p.pin);

                              return DropdownMenuItem<Esp32PinConfig?>(
                                value: p,
                                enabled: !isUsed,
                                child: Row(
                                  children: [
                                    Icon(
                                      p.isPwm ? Icons.waves : Icons.bolt,
                                      color: isUsed ? Colors.white24 : (p.isPwm ? Colors.orangeAccent : AppTheme.primaryBlue),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        p.label,
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
                    final selectedPin = selectedPinConfig?.pin;
                    final selectedIsPwm = selectedPinConfig?.isPwm;

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
                          isPwm: selectedIsPwm,
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
                          isPwm: selectedIsPwm,
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
                          isPwm: selectedIsPwm,
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
                          isPwm: selectedIsPwm,
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
                          isPwm: selectedIsPwm,
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
    Esp32PinConfig? selectedPinConfig;
    if (device.pin != null) {
      final deviceIsPwm = device.isPwm ?? (device.pin == 22 || device.pin == 23 || device.pin == 25 || device.pin == 26);
      selectedPinConfig = esp32Pins.firstWhere(
        (p) => p.pin == device.pin && p.isPwm == deviceIsPwm,
        orElse: () => Esp32PinConfig(
          pin: device.pin!,
          isPwm: deviceIsPwm,
          label: 'GPIO ${device.pin} (${deviceIsPwm ? 'pwm' : 'relay'})',
        ),
      );
    }

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
                        child: DropdownButton<Esp32PinConfig?>(
                          value: selectedPinConfig,
                          dropdownColor: AppTheme.cardBackground,
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          onChanged: (val) {
                            setState(() {
                              selectedPinConfig = val;
                            });
                          },
                          items: [
                            const DropdownMenuItem<Esp32PinConfig?>(
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
                              final isUsed = usedPins.contains(p.pin);

                              return DropdownMenuItem<Esp32PinConfig?>(
                                value: p,
                                enabled: !isUsed,
                                child: Row(
                                  children: [
                                    Icon(
                                      p.isPwm ? Icons.waves : Icons.bolt,
                                      color: isUsed ? Colors.white24 : (p.isPwm ? Colors.orangeAccent : AppTheme.primaryBlue),
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        p.label,
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
                    final selectedPin = selectedPinConfig?.pin;
                    final selectedIsPwm = selectedPinConfig?.isPwm;
                    DeviceEntity updated = device;

                    if (device.type == selectedType) {
                      if (device is DoorDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          isPwm: selectedIsPwm,
                          linkedDevicesCount: linkedCount,
                        );
                      } else if (device is AcDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          isPwm: selectedIsPwm,
                        );
                      } else if (device is LampDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          isPwm: selectedIsPwm,
                        );
                      } else if (device is RgbLampDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          isPwm: selectedIsPwm,
                        );
                      } else if (device is VacuumDeviceEntity) {
                        updated = device.copyWith(
                          name: name,
                          showAsDot: showAsDot,
                          pin: selectedPin,
                          isPwm: selectedIsPwm,
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
                            isPwm: selectedIsPwm,
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
                            isPwm: selectedIsPwm,
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
                            isPwm: selectedIsPwm,
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
                            isPwm: selectedIsPwm,
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
                            isPwm: selectedIsPwm,
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
