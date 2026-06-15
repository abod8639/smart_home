import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

// Split components imports
import 'package:smart_home/features/dashboard/presentation/widgets/color_wheel_picker.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/rgb_brightness_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/rgb_color_presets_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/rgb_scenes_card.dart';

/// A page representing the RGB lamp controls (color, brightness, power, scenes).
class RgbPage extends ConsumerWidget {
  /// The device entity representing the RGB lamp.
  final DeviceEntity device;

  /// Creates an [RgbPage].
  const RgbPage({super.key, required this.device});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dashboardControllerProvider);
    final controller = ref.read(dashboardControllerProvider.notifier);

    final currentDevice = state.devices.firstWhere(
        (d) => d.id == device.id,
        orElse: () => device) as RgbLampDeviceEntity;
    
    final color = Color.fromRGBO(
        currentDevice.rgbR ?? 255,
        currentDevice.rgbG ?? 255,
        currentDevice.rgbB ?? 255,
        currentDevice.isOn ? 0.35 : 0.0);

    return Scaffold(
      backgroundColor: const Color(0xFF13131A), // Deep dark premium background
      body: Stack(
        children: [
          // Background Gradient (Dynamic based on current color)
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.7),
                radius: 1.3,
                colors: [color, Colors.transparent],
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
                      child: Column(
                        children: [
                          _buildLampPreview(currentDevice, controller),
                          const SizedBox(height: 35),
                          _buildPowerButton(currentDevice, controller),
                          const SizedBox(height: 35),
                          RgbBrightnessCard(device: currentDevice, controller: controller),
                          const SizedBox(height: 25),
                          RgbColorPresetsCard(device: currentDevice, controller: controller),
                          const SizedBox(height: 25),
                          const RgbScenesCard(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 22),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Text(
            device.name,
            style: const TextStyle(
                color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white, size: 26),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildLampPreview(RgbLampDeviceEntity currentDevice, DashboardController controller) {
    final c = Color.fromRGBO(
        currentDevice.rgbR ?? 255,
        currentDevice.rgbG ?? 255,
        currentDevice.rgbB ?? 255,
        1.0);

    return ColorWheelPicker(
      currentColor: c,
      onColorChanged: (newColor) {
        controller.updateDeviceColor(
            device.id, (newColor.r * 255).toInt(), (newColor.g * 255).toInt(), (newColor.b * 255).toInt());
      },
    );
  }

  Widget _buildPowerButton(RgbLampDeviceEntity currentDevice, DashboardController controller) {
    final isOn = currentDevice.isOn;

    return GestureDetector(
      onTap: () => controller.toggleDevice(device.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 85,
        height: 85,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isOn ? Colors.white : Colors.white.withValues(alpha: 0.08),
          boxShadow: isOn
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.4),
                    blurRadius: 25,
                    spreadRadius: 5,
                  )
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            Icons.power_settings_new,
            size: 42,
            color: isOn ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
