import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class MatterCommissioningDialog extends StatefulWidget {
  const MatterCommissioningDialog({super.key});

  @override
  State<MatterCommissioningDialog> createState() => _MatterCommissioningDialogState();
}

class _MatterCommissioningDialogState extends State<MatterCommissioningDialog> {
  int _currentStep = 0; // 0 = Input Form, 1 = Connecting Animation, 2 = Success Screen
  int _pairingStepIndex = 0;
  String _deviceName = '';
  DeviceType _selectedType = DeviceType.rgb;
  final _nameController = TextEditingController();
  final _codeController = TextEditingController(text: '1234-567-8901');

  final List<String> _pairingSteps = [
    'Scanning for nearby Matter devices over Bluetooth...',
    'Establishing secure session with device (PASE)...',
    'Provisioning Thread credentials to node...',
    'Registering device on local Google Home fabric...',
    'Verifying device state and certificates...',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCommissioning() async {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter a name for the device.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    setState(() {
      _deviceName = _nameController.text.trim();
      _currentStep = 1;
      _pairingStepIndex = 0;
    });

    // Simulate pairing steps
    for (int i = 0; i < _pairingSteps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() {
        _pairingStepIndex = i + 1;
      });
    }

    // Add device to controller
    final dashboardController = Get.find<DashboardController>();
    final newId = 'matter_${DateTime.now().millisecondsSinceEpoch}';
    
    // Create new device entity with default stats
    final DeviceEntity newDevice;
    switch (_selectedType) {
      case DeviceType.rgb:
        newDevice = DeviceEntity(
          id: newId,
          name: _deviceName,
          type: DeviceType.rgb,
          isOn: true,
          rgbR: 255,
          rgbG: 191,
          rgbB: 0,
          brightness: 100,
          positionX: 0.5,
          positionY: 0.5,
          markerWidth: 100,
          markerHeight: 60,
        );
        break;
      case DeviceType.airConditioner:
        newDevice = DeviceEntity(
          id: newId,
          name: _deviceName,
          type: DeviceType.airConditioner,
          isOn: false,
          temperature: 24,
          mode: 'Auto mode',
          coolingTime: 0,
          positionX: 0.5,
          positionY: 0.5,
          markerWidth: 100,
          markerHeight: 60,
        );
        break;
      case DeviceType.lamp:
        newDevice = DeviceEntity(
          id: newId,
          name: _deviceName,
          type: DeviceType.lamp,
          isOn: true,
          brightness: 80,
          positionX: 0.5,
          positionY: 0.5,
          markerWidth: 100,
          markerHeight: 60,
        );
        break;
      case DeviceType.vacuum:
        newDevice = DeviceEntity(
          id: newId,
          name: _deviceName,
          type: DeviceType.vacuum,
          isOn: false,
          batteryLevel: 100,
          areaCleaned: 0,
          cleaningTime: 0,
          filterStatus: 100,
          nextCleaning: '12:00 PM',
          positionX: 0.5,
          positionY: 0.5,
          markerWidth: 100,
          markerHeight: 60,
        );
        break;
      case DeviceType.door:
        newDevice = DeviceEntity(
          id: newId,
          name: _deviceName,
          type: DeviceType.door,
          isOn: false,
          isLocked: true,
          positionX: 0.5,
          positionY: 0.5,
          markerWidth: 100,
          markerHeight: 60,
        );
        break;
    }

    dashboardController.addDevice(newDevice);

    if (!mounted) return;
    setState(() {
      _currentStep = 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: GlassContainer(
        width: 420,
        padding: const EdgeInsets.all(28),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentStep) {
      case 0:
        return _buildInputForm();
      case 1:
        return _buildPairingProcess();
      case 2:
        return _buildSuccessScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInputForm() {
    return Column(
      key: const ValueKey('input_form'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title block
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.qr_code_scanner_outlined, color: AppTheme.accentCyan),
                SizedBox(width: 10),
                Text(
                  'Google Home Matter Setup',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white60),
              onPressed: () => Navigator.pop(context),
            )
          ],
        ),
        const SizedBox(height: 20),

        // Matter logo card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.accentCyan.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.grid_3x3_outlined, color: AppTheme.accentCyan, size: 24),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Matter Certified Device',
                      style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Connect directly using Thread or Local Wi-Fi fabrics.',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Device Type Selector
        const Text(
          'Device Type',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<DeviceType>(
              value: _selectedType,
              dropdownColor: AppTheme.cardBackground,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
              style: const TextStyle(color: Colors.white, fontSize: 13),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedType = val);
                }
              },
              items: const [
                DropdownMenuItem(value: DeviceType.rgb, child: Text('RGB Light Strip')),
                DropdownMenuItem(value: DeviceType.airConditioner, child: Text('Air Conditioner')),
                DropdownMenuItem(value: DeviceType.lamp, child: Text('Smart Lamp')),
                DropdownMenuItem(value: DeviceType.vacuum, child: Text('Robot Vacuum')),
                DropdownMenuItem(value: DeviceType.door, child: Text('Smart Lock')),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Device Name Input
        const Text(
          'Device Name',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'e.g. Living Room Lamp',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.accentCyan),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Matter Passcode Input
        const Text(
          'Matter Setup Code',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 11, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeController,
          style: const TextStyle(color: Colors.white, fontSize: 13, letterSpacing: 1.5),
          decoration: InputDecoration(
            hintText: 'XXXX-XXX-XXXX',
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.2)),
            filled: true,
            fillColor: Colors.black.withValues(alpha: 0.2),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.accentCyan),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Actions Row
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accentCyan, AppTheme.primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ElevatedButton(
                  onPressed: _startCommissioning,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Start Commissioning',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPairingProcess() {
    return Column(
      key: const ValueKey('pairing_process'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 12),
        // Loading Spinner
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                strokeWidth: 4,
                value: _pairingStepIndex / _pairingSteps.length,
              ),
            ),
            Icon(
              _selectedType == DeviceType.rgb
                  ? Icons.lightbulb_outline
                  : (_selectedType == DeviceType.airConditioner
                      ? Icons.ac_unit_outlined
                      : (_selectedType == DeviceType.lamp
                          ? Icons.light_mode_outlined
                          : (_selectedType == DeviceType.vacuum
                              ? Icons.cleaning_services_outlined
                              : Icons.lock_outline))),
              color: AppTheme.accentCyan,
              size: 34,
            ),
          ],
        ),
        const SizedBox(height: 28),
        const Text(
          'Commissioning Device...',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Matter Node: ${_codeController.text}',
          style: const TextStyle(color: AppTheme.textGrey, fontSize: 12),
        ),
        const SizedBox(height: 24),

        // Steps sequence UI
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: List.generate(_pairingSteps.length, (index) {
              final isCompleted = _pairingStepIndex > index;
              final isCurrent = _pairingStepIndex == index;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    if (isCompleted)
                      const Icon(Icons.check_circle, color: Colors.greenAccent, size: 16)
                    else if (isCurrent)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
                        ),
                      )
                    else
                      const Icon(Icons.circle_outlined, color: Colors.white24, size: 16),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _pairingSteps[index],
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.greenAccent.withValues(alpha: 0.8)
                              : (isCurrent ? Colors.white : Colors.white30),
                          fontSize: 11,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessScreen() {
    return Column(
      key: const ValueKey('success_screen'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 16),
        // Success check circle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.2), width: 2),
          ),
          child: const Icon(
            Icons.done_all,
            color: Colors.greenAccent,
            size: 48,
          ),
        ),
        const SizedBox(height: 28),
        Text(
          '$_deviceName Paired Successfully!',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'The device has been successfully registered on the Google Home Matter fabric and added to your dashboard local configuration.',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 12, height: 1.45),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 28),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
          ),
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'Go to Dashboard',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}
