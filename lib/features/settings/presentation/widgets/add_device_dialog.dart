import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'dart:math';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _nameController = TextEditingController();
  final _linkedCountController = TextEditingController(text: '0');
  DeviceType _selectedType = DeviceType.lamp;

  @override
  void dispose() {
    _nameController.dispose();
    _linkedCountController.dispose();
    super.dispose();
  }

  void _saveDevice() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final linkedCount = int.tryParse(_linkedCountController.text) ?? 0;
    
    // Generate a random ID
    final id = '\${_selectedType.name}_\${Random().nextInt(10000)}';

    final newDevice = DeviceEntity(
      id: id,
      name: name,
      type: _selectedType,
      isOn: false,
      linkedDevicesCount: linkedCount,
      // Provide some default values based on type
      brightness: _selectedType == DeviceType.lamp ? 50 : null,
      temperature: _selectedType == DeviceType.airConditioner ? 24 : null,
      mode: _selectedType == DeviceType.airConditioner ? 'Auto mode' : null,
      coolingTime: _selectedType == DeviceType.airConditioner ? 0 : null,
    );

    final dashboardController = Get.find<DashboardController>();
    dashboardController.addDevice(newDevice);

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add New Device',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Device Name
            const Text('Device Name', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'e.g. Balcony Lamp',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Device Type
            const Text('Device Type', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<DeviceType>(
                  value: _selectedType,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1E293B),
                  style: const TextStyle(color: Colors.white),
                  items: DeviceType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.capitalizeFirst ?? type.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedType = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Linked Devices
            const Text('Linked Devices', style: TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            const SizedBox(height: 8),
            TextField(
              controller: _linkedCountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _saveDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Device', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
