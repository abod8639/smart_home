import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:uuid/uuid.dart';

class RoomPlacementView extends GetView<RoomPlacementController> {
  const RoomPlacementView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure DashboardController is available
    final dashboardController = Get.find<DashboardController>();
    final GlobalKey imageKey = GlobalKey();

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Room Device Placement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(Responsive.pagePadding(context)),
        child: Responsive.isMobile(context)
            ? _buildMobileLayout(context, dashboardController, imageKey)
            : _buildWideLayout(context, dashboardController, imageKey),
      ),
    );
  }

  Widget _buildMobileLayout(
    BuildContext context,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    return Column(
      children: [
        Expanded(flex: 3, child: _buildRoomImagePanel(context, dashboardController, imageKey)),
        SizedBox(height: Responsive.contentGap(context)),
        Expanded(
          flex: 2,
          child: GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Obx(() => _buildSidePanel(context, dashboardController)),
          ),
        ),
      ],
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: Responsive.isTablet(context) ? 2 : 3,
          child: _buildRoomImagePanel(context, dashboardController, imageKey),
        ),
        SizedBox(width: Responsive.contentGap(context)),
        Expanded(
          flex: 1,
          child: GlassContainer(
            padding: EdgeInsets.all(Responsive.isTablet(context) ? 16 : 24),
            child: Obx(() => _buildSidePanel(context, dashboardController)),
          ),
        ),
      ],
    );
  }

  Widget _buildRoomImagePanel(
    BuildContext context,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Living Room',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                key: imageKey,
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/living_room.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.2),
                    ),
                  ),
                  Positioned.fill(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Obx(() {
                          final validDevices = dashboardController.devices
                              .where((d) => d.positionX != null && d.positionY != null)
                              .toList();

                          return Stack(
                            children: validDevices.map((device) {
                              final posX = device.positionX! * constraints.maxWidth;
                              final posY = device.positionY! * constraints.maxHeight;
                              final isSelected = controller.selectedDeviceId.value == device.id;
                              final mW = device.markerWidth ?? 110.0;
                              final mH = device.markerHeight ?? 70.0;

                              return Positioned(
                                left: posX - mW / 2,
                                top: posY - mH / 2,
                                child: _buildDraggableMarker(
                                  device,
                                  isSelected,
                                  dashboardController,
                                  imageKey,
                                ),
                              );
                            }).toList(),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidePanel(BuildContext context, DashboardController dashboardController) {
    final selectedId = controller.selectedDeviceId.value;
    if (selectedId == null) {
      return _buildAddDevicePanel(context, dashboardController);
    }

    final device = dashboardController.devices.firstWhereOrNull((d) => d.id == selectedId);
    if (device == null) {
      return const Center(
        child: Text(
          'Device not found',
          style: TextStyle(color: AppTheme.textGrey),
        ),
      );
    }

    return _buildDevicePropertiesPanel(context, device, dashboardController);
  }

  Widget _buildDraggableMarker(
    DeviceEntity device,
    bool isSelected,
    DashboardController dashboardController,
    GlobalKey imageKey,
  ) {
    IconData iconData;
    switch (device.type) {
      case DeviceType.lamp:
        iconData = Icons.lightbulb_outline;
        break;
      case DeviceType.airConditioner:
        iconData = Icons.ac_unit;
        break;
      case DeviceType.vacuum:
        iconData = Icons.cleaning_services_outlined;
        break;
      case DeviceType.door:
        iconData = device.isLocked ?? true ? Icons.lock_outline : Icons.lock_open_outlined;
        break;
      case DeviceType.rgb:
        iconData = Icons.wb_incandescent_rounded;
        break;
    }

    final isRgbOn = device.type == DeviceType.rgb && device.isOn;
    final markerColor = isRgbOn
        ? Color.fromRGBO(device.rgbR ?? 255, device.rgbG ?? 0, device.rgbB ?? 128, 0.82)
        : device.isOn
            ? AppTheme.primaryBlue.withValues(alpha: 0.82)
            : Colors.white.withValues(alpha: 0.10);

    final borderColor = isSelected ? Colors.amber : Colors.white.withValues(alpha: 0.55);
    final glowColor = isRgbOn
        ? Color.fromRGBO(device.rgbR ?? 255, device.rgbG ?? 0, device.rgbB ?? 128, 0.45)
        : isSelected
            ? Colors.amber.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.25);

    final mW = device.markerWidth ?? 110.0;
    final mH = device.markerHeight ?? 70.0;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ── Main marker body ────────────────────────────────────────────────
        GestureDetector(
          onTap: () => controller.selectDevice(device.id),
          onLongPressMoveUpdate: (details) {
            controller.selectDevice(device.id);
            final RenderBox? renderBox =
                imageKey.currentContext?.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final Offset local = renderBox.globalToLocal(details.globalPosition);
              final double x = (local.dx / renderBox.size.width).clamp(0.0, 1.0);
              final double y = (local.dy / renderBox.size.height).clamp(0.0, 1.0);
              dashboardController.updateDevicePosition(device.id, x, y);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: mW,
            height: mH,
            decoration: BoxDecoration(
              color: markerColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected ? 2.5 : 1.5),
              boxShadow: [
                BoxShadow(color: glowColor, blurRadius: isSelected ? 14 : 6, spreadRadius: isSelected ? 2 : 0),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconData, color: Colors.white, size: 22),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text(
                    device.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Resize grip (bottom-right corner) ──────────────────────────────
        Positioned(
          right: -8,
          bottom: -8,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onPanUpdate: (details) {
              dashboardController.updateDeviceMarkerSize(
                device.id,
                mW + details.delta.dx,
                mH + details.delta.dy,
              );
            },
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected ? Colors.amber : Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 4),
                ],
              ),
              child: Icon(
                Icons.open_in_full_rounded,
                size: 12,
                color: isSelected ? Colors.black87 : AppTheme.backgroundDark,
              ),
            ),
          ),
        ),
      ],
    );
  }




  Widget _buildDevicePropertiesPanel(BuildContext context, DeviceEntity device, DashboardController dashboardController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                  icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue, size: 20),
                  onPressed: () => _showEditDeviceDialog(context, device, dashboardController),
                  tooltip: 'Edit Device',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                  onPressed: () => _showDeleteConfirmation(context, device, dashboardController),
                  tooltip: 'Delete Device',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildPropertyRow('Name', device.name),
        const SizedBox(height: 16),
        _buildPropertyRow('Type', device.type.name.capitalizeFirst ?? ''),
        const SizedBox(height: 16),
        _buildPropertyRow('Status', device.isOn ? 'ON' : 'OFF'),
        if (device.type == DeviceType.lamp && device.brightness != null) ...[
          const SizedBox(height: 16),
          _buildPropertyRow('Brightness', '${device.brightness}%'),
        ],
        if (device.type == DeviceType.airConditioner && device.temperature != null) ...[
          const SizedBox(height: 16),
          _buildPropertyRow('Temperature', '${device.temperature}°C'),
          const SizedBox(height: 16),
          _buildPropertyRow('Mode', device.mode ?? 'Auto'),
        ],
        if (device.type == DeviceType.vacuum) ...[
          const SizedBox(height: 16),
          _buildPropertyRow('Battery', '${device.batteryLevel ?? 0}%'),
        ],
        if (device.type == DeviceType.lamp && device.linkedDevicesCount != null) ...[
          const SizedBox(height: 16),
          _buildPropertyRow('Linked Devices', '${device.linkedDevicesCount}'),
        ],
        if (device.type == DeviceType.rgb) ...[
          const SizedBox(height: 16),
          _buildPropertyRow(
            'Color',
            'rgb(${device.rgbR ?? 0}, ${device.rgbG ?? 0}, ${device.rgbB ?? 0})',
          ),
          const SizedBox(height: 10),
          // Live color swatch
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
                )
              ],
            ),
          ),
          if (device.brightness != null) ...[
            const SizedBox(height: 16),
            _buildPropertyRow('Brightness', '${device.brightness}%'),
          ],
        ],

        const Spacer(),
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
              // Toggle device state
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
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  // ── Add Device Panel ────────────────────────────────────────────────────────

  Widget _buildAddDevicePanel(BuildContext context, DashboardController dashboardController) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryBlue.withValues(alpha: 0.15),
            border: Border.all(color: AppTheme.primaryBlue.withValues(alpha: 0.4), width: 2),
          ),
          child: const Icon(
            Icons.add_rounded,
            color: AppTheme.primaryBlue,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Add New Device',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Place a new smart device\nin your room',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: const Text(
              'Add Device',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => _showAddDeviceDialog(context, dashboardController),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  IconData _iconForType(DeviceType type) {
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

  // ── Add Device Dialog ─────────────────────────────────────────────────────────

  void _showAddDeviceDialog(BuildContext context, DashboardController dashboardController) {
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
            Text('Add New Device', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Device Type', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              const SizedBox(height: 8),
              Obx(() => Container(
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
                                Icon(_iconForType(type), color: AppTheme.primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Text(type.name.capitalizeFirst ?? ''),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: linkedCountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Linked Devices Count',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
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
                // Placed at center by default; user can drag it
                positionX: 0.5,
                positionY: 0.5,
              );
              dashboardController.addDevice(newDevice);
              controller.selectDevice(newDevice.id); // auto-select so properties appear
              Get.back();
            },
            child: const Text('Add', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, DeviceEntity device, DashboardController dashboardController) {

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Delete Device', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete ${device.name}?', style: const TextStyle(color: AppTheme.textGrey)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
          ),
          TextButton(
            onPressed: () {
              dashboardController.deleteDevice(device.id);
              controller.selectDevice(null); // Deselect
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showEditDeviceDialog(BuildContext context, DeviceEntity device, DashboardController dashboardController) {
    final nameController = TextEditingController(text: device.name);
    final linkedCountController = TextEditingController(text: (device.linkedDevicesCount ?? 0).toString());
    var selectedType = device.type.obs;

    Get.dialog(
      AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: const Text('Edit Device', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Device Type', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
              const SizedBox(height: 8),
              Obx(() => Container(
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
                            child: Text(type.name.capitalizeFirst ?? ''),
                          );
                        }).toList(),
                      ),
                    ),
                  )),
              const SizedBox(height: 20),
              TextField(
                controller: linkedCountController,
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Linked Devices Count',
                  labelStyle: TextStyle(color: AppTheme.textGrey),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppTheme.primaryBlue)),
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

              final updatedDevice = device.copyWith(
                name: name,
                type: selectedType.value,
                linkedDevicesCount: int.tryParse(linkedCountController.text) ?? 0,
              );

              dashboardController.updateDevice(updatedDevice);
              Get.back();
            },
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textGrey,
            fontSize: 12,
          ),
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
}
