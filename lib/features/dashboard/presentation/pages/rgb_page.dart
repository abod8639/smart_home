import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/rgb_lamp_device_entity.dart';

class RgbPage extends GetView<DashboardController> {
  final DeviceEntity device;

  const RgbPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF13131A), // Deep dark premium background
      body: Stack(
        children: [
          // Background Gradient (Dynamic based on current color)
          Obx(() {
            final currentDevice = controller.devices.firstWhere(
                (d) => d.id == device.id,
                orElse: () => device) as RgbLampDeviceEntity;
            
            final color = Color.fromRGBO(
                currentDevice.rgbR ?? 255,
                currentDevice.rgbG ?? 255,
                currentDevice.rgbB ?? 255,
                currentDevice.isOn ? 0.35 : 0.0);

            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.7),
                  radius: 1.3,
                  colors: [color, Colors.transparent],
                ),
              ),
            );
          }),
          
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
                          _buildLampPreview(),
                          const SizedBox(height: 35),
                          _buildPowerButton(),
                          const SizedBox(height: 35),
                          _buildBrightnessSlider(),
                          const SizedBox(height: 25),
                          _buildColorPresets(),
                          const SizedBox(height: 25),
                          _buildModes(),
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
            onPressed: () => Get.back(),
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

  Widget _buildLampPreview() {
    return Obx(() {
      final currentDevice = controller.devices.firstWhere(
          (d) => d.id == device.id,
          orElse: () => device) as RgbLampDeviceEntity;
      
      final c = Color.fromRGBO(
          currentDevice.rgbR ?? 255,
          currentDevice.rgbG ?? 255,
          currentDevice.rgbB ?? 255,
          1.0);

      return Container(
        height: 180,
        width: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: currentDevice.isOn
              ? [
                  BoxShadow(
                    color: c.withOpacity(0.5),
                    blurRadius: 50,
                    spreadRadius: 10,
                  )
                ]
              : [],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.lightbulb_outline,
              key: ValueKey<bool>(currentDevice.isOn),
              size: 110,
              color: currentDevice.isOn ? c : Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildPowerButton() {
    return Obx(() {
      final currentDevice = controller.devices.firstWhere(
          (d) => d.id == device.id,
          orElse: () => device) as RgbLampDeviceEntity;
      final isOn = currentDevice.isOn;

      return GestureDetector(
        onTap: () => controller.toggleDevice(device.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 85,
          height: 85,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOn ? Colors.white : Colors.white.withOpacity(0.08),
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
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
    });
  }

  Widget _buildBrightnessSlider() {
    return Obx(() {
      final currentDevice = controller.devices.firstWhere(
          (d) => d.id == device.id,
          orElse: () => device) as RgbLampDeviceEntity;
      final brightness = currentDevice.brightness ?? 50;
      final c = Color.fromRGBO(
          currentDevice.rgbR ?? 255,
          currentDevice.rgbG ?? 255,
          currentDevice.rgbB ?? 255,
          1.0);

      return _GlassContainer(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Brightness',
                    style: TextStyle(
                        color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    '${((brightness / 255) * 100).toInt()}%',
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  const Icon(Icons.brightness_low, color: Colors.white54, size: 22),
                  Expanded(
                    child: SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 6,
                        activeTrackColor: currentDevice.isOn ? c : Colors.grey.withOpacity(0.5),
                        inactiveTrackColor: Colors.white12,
                        thumbColor: Colors.white,
                        overlayColor: Colors.white.withOpacity(0.2),
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                      ),
                      child: Slider(
                        value: brightness.toDouble(),
                        min: 0,
                        max: 255,
                        onChanged: (val) {
                          controller.updateDeviceBrightness(device.id, val.toInt());
                        },
                      ),
                    ),
                  ),
                  const Icon(Icons.brightness_high, color: Colors.white54, size: 22),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildColorPresets() {
    final List<Color> presets = [
      Colors.redAccent,
      Colors.orange,
      Colors.yellow,
      Colors.greenAccent,
      Colors.blueAccent,
      Colors.purpleAccent,
      Colors.pinkAccent,
      Colors.white,
    ];

    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Colors',
              style: TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 18,
              runSpacing: 18,
              alignment: WrapAlignment.center,
              children: presets.map((color) {
                return Obx(() {
                  final currentDevice = controller.devices.firstWhere(
                      (d) => d.id == device.id,
                      orElse: () => device) as RgbLampDeviceEntity;
                  final isSelected = currentDevice.rgbR == color.red &&
                      currentDevice.rgbG == color.green &&
                      currentDevice.rgbB == color.blue;

                  return GestureDetector(
                    onTap: () {
                      controller.updateDeviceColor(
                          device.id, color.red, color.green, color.blue);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 3)
                            : Border.all(color: Colors.transparent, width: 3),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.6),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                    ),
                  );
                });
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModes() {
    final modes = ['Solid', 'Breathe', 'Flash', 'Music'];
    return _GlassContainer(
      child: Padding(
        padding: const EdgeInsets.all(22.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scenes',
              style: TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: modes.map((mode) {
                  final isSelected = mode == 'Solid'; // Mocked selected state
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.02),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? Colors.white54 : Colors.white12,
                        ),
                      ),
                      child: Text(
                        mode,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;
  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );
  }
}
