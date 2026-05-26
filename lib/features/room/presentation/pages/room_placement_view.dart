import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';

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
        padding: const EdgeInsets.all(24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Side: Interactive Room Image
            Expanded(
              flex: 3,
              child: GlassContainer(
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
                            // Room Background
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/living_room.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Semi-transparent overlay
                            Positioned.fill(
                              child: Container(
                                color: Colors.black.withValues(alpha: 0.2),
                              ),
                            ),
                            // Dynamic Draggable Markers
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

                                        return Positioned(
                                          left: posX - 24,
                                          top: posY - 24,
                                          child: GestureDetector(
                                            onTap: () {
                                              controller.selectDevice(device.id);
                                            },
                                            onLongPressMoveUpdate: (details) {
                                              controller.selectDevice(device.id);
                                              final RenderBox? renderBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
                                              if (renderBox != null) {
                                                final Offset localOffset = renderBox.globalToLocal(details.globalPosition);
                                                final double x = (localOffset.dx / renderBox.size.width).clamp(0.0, 1.0);
                                                final double y = (localOffset.dy / renderBox.size.height).clamp(0.0, 1.0);
                                                dashboardController.updateDevicePosition(device.id, x, y);
                                              }
                                            },
                                            child: _buildDraggableMarker(device, isSelected),
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
              ),
            ),
            const SizedBox(width: 24),
            // Right Side: Device Properties Panel
            Expanded(
              flex: 1,
              child: GlassContainer(
                padding: const EdgeInsets.all(24),
                child: Obx(() {
                  final selectedId = controller.selectedDeviceId.value;
                  if (selectedId == null) {
                    return const Center(
                      child: Text(
                        'Select a device to view properties',
                        style: TextStyle(color: AppTheme.textGrey),
                        textAlign: TextAlign.center,
                      ),
                    );
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
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableMarker(DeviceEntity device, bool isSelected) {
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
    }

    return Tooltip(
      message: device.name,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: device.isOn ? AppTheme.primaryBlue : Colors.white24,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? Colors.amber.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
              blurRadius: isSelected ? 12 : 6,
              spreadRadius: isSelected ? 2 : 1,
            )
          ],
        ),
        child: Icon(
          iconData,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildDevicePropertiesPanel(BuildContext context, DeviceEntity device, DashboardController dashboardController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Properties',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
