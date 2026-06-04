import 'dart:math';
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

      return ColorWheelPicker(
        currentColor: c,
        onColorChanged: (newColor) {
          controller.updateDeviceColor(
              device.id, newColor.red, newColor.green, newColor.blue);
        },
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

class ColorWheelPicker extends StatelessWidget {
  final Color currentColor;
  final Function(Color) onColorChanged;

  const ColorWheelPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  void _updateColor(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;

    double angle = atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * pi;
    }

    double hue = (angle / (2 * pi)) * 360;
    final color = HSVColor.fromAHSV(1.0, hue, 1.0, 1.0).toColor();
    onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    const size = Size(240, 240);
    return GestureDetector(
      onPanDown: (details) => _updateColor(details.localPosition, size),
      onPanUpdate: (details) => _updateColor(details.localPosition, size),
      child: CustomPaint(
        size: size,
        painter: ColorWheelPainter(
          currentColor: currentColor,
          strokeWidth: 26,
        ),
      ),
    );
  }
}

class ColorWheelPainter extends CustomPainter {
  final Color currentColor;
  final double strokeWidth;

  ColorWheelPainter({
    required this.currentColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final wheelRadius = outerRadius - strokeWidth / 2 - 8; // leave space for outer indicator arc

    // 1. Draw Rainbow Wheel
    final rect = Rect.fromCircle(center: center, radius: wheelRadius);
    final wheelPaint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFF0000), // Red (0)
          Color(0xFFFFFF00), // Yellow (60)
          Color(0xFF00FF00), // Green (120)
          Color(0xFF00FFFF), // Cyan (180)
          Color(0xFF0000FF), // Blue (240)
          Color(0xFFFF00FF), // Magenta (300)
          Color(0xFFFF0000), // Red (360)
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, 2 * pi, false, wheelPaint);

    // 2. Draw Center Solid Circle (Current Color) with Glow
    final centerColorPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;
    
    // Glow effect
    final glowPaint = Paint()
      ..color = currentColor.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    
    canvas.drawCircle(center, 40, glowPaint);
    canvas.drawCircle(center, 30, centerColorPaint);

    // 3. Draw Handle (Indicator Dot) on the ring
    final hsv = HSVColor.fromColor(currentColor);
    final angle = (hsv.hue / 360.0) * 2 * pi;
    final handleOffset = Offset(
      center.dx + wheelRadius * cos(angle),
      center.dy + wheelRadius * sin(angle),
    );

    // Handle background (white)
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleOffset, 12, handlePaint);

    // Handle border / center (current color)
    final handleInnerPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(handleOffset, 8, handleInnerPaint);

    // 4. Draw thin outer arc
    final outerArcPaint = Paint()
      ..color = currentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    
    final outerArcRect = Rect.fromCircle(center: center, radius: wheelRadius + strokeWidth / 2 + 5);
    const startAngle = -pi / 2; // 12 o'clock
    double sweepAngle = angle - startAngle;
    if (sweepAngle < 0) {
      sweepAngle += 2 * pi;
    }
    canvas.drawArc(outerArcRect, startAngle, sweepAngle, false, outerArcPaint);
  }

  @override
  bool shouldRepaint(covariant ColorWheelPainter oldDelegate) {
    return oldDelegate.currentColor != currentColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
