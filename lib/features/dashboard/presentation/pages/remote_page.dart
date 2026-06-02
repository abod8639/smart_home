import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/widgets/ac_visualizer.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_ir_controls.dart';
import 'package:smart_home/core/utils/responsive.dart';

class RemotePage extends StatefulWidget {
  final DeviceEntity device;
  const RemotePage({super.key, required this.device});

  @override
  State<RemotePage> createState() => _RemotePageState();
}

class _RemotePageState extends State<RemotePage> {
  // Local state for options not stored in DeviceEntity
  String _fanSpeed = 'Auto';
  bool _verticalSwing = false;
  bool _horizontalSwing = false;

  // Sharp Remote specific advanced toggles
  bool _isPlasmaclusterOn = false;
  bool _isSuperJetOn = false;
  bool _isCoandaOn = false;
  bool _isMyAreaOn = false;
  bool _isDisplayOn = true;

  // Sleep Timer variables
  Timer? _sleepTimer;
  Timer? _countdownTimer;
  Duration? _timeLeft;

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _setSleepTimer(Duration duration) {
    _cancelSleepTimer();
    _timeLeft = duration;

    _sleepTimer = Timer(duration, () {
      final controller = Get.find<DashboardController>();
      final freshDevice = controller.devices.firstWhereOrNull((d) => d.id == widget.device.id);
      if (freshDevice != null && freshDevice.isOn) {
        controller.toggleDevice(freshDevice.id);
      }
      _cancelSleepTimer();
      Get.snackbar(
        'Sleep Timer / مؤقت النوم',
        'تم إيقاف تشغيل مكيف الهواء تلقائياً.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft == null || _timeLeft!.inSeconds <= 1) {
          _cancelSleepTimer();
        } else {
          _timeLeft = Duration(seconds: _timeLeft!.inSeconds - 1);
        }
      });
    });

    setState(() {});
  }

  void _cancelSleepTimer() {
    _sleepTimer?.cancel();
    _countdownTimer?.cancel();
    _sleepTimer = null;
    _countdownTimer = null;
    _timeLeft = null;
    if (mounted) {
      setState(() {});
    }
  }

  Color _modeColor(String? mode) {
    switch (mode) {
      case 'Cool mode': return const Color(0xFF60A5FA); // blue
      case 'Heat mode': return const Color(0xFFFB923C); // orange
      case 'Eco mode':  return const Color(0xFF4ADE80); // green
      case 'Dry mode':  return const Color(0xFF2DD4BF); // teal
      default:          return const Color(0xFF00E5FF); // cyan – Auto
    }
  }

  void _showSleepTimerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: Colors.white10, width: 1),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Text(
              'Sleep Timer / مؤقت النوم',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set when to automatically turn off the air conditioner.',
              style: TextStyle(color: AppTheme.textGrey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            _buildTimerOption(context, 'Turn Off Timer / إيقاف المؤقت', const Duration(seconds: 0)),
            _buildTimerOption(context, '30 Minutes / ٣٠ دقيقة', const Duration(minutes: 30)),
            _buildTimerOption(context, '1 Hour / ساعة واحدة', const Duration(hours: 1)),
            _buildTimerOption(context, '2 Hours / ساعتين', const Duration(hours: 2)),
            _buildTimerOption(context, '4 Hours / ٤ ساعات', const Duration(hours: 4)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerOption(BuildContext context, String label, Duration duration) {
    final isCurrent = (duration.inSeconds == 0 && _timeLeft == null) ||
        (_timeLeft != null && _timeLeft!.inMinutes == duration.inMinutes);

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        if (duration.inSeconds == 0) {
          _cancelSleepTimer();
        } else {
          _setSleepTimer(duration);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isCurrent ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? AppTheme.primaryBlue.withOpacity(0.5) : Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Icon(
              duration.inSeconds == 0 ? Icons.timer_off_outlined : Icons.timer_outlined,
              color: isCurrent ? AppTheme.primaryBlue : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isCurrent ? AppTheme.primaryBlue : Colors.white,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isCurrent)
              const Icon(Icons.check_circle, color: AppTheme.primaryBlue, size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.find<DashboardController>();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Obx(() {
          final device = controller.devices.firstWhere(
            (d) => d.id == widget.device.id,
            orElse: () => widget.device,
          );
          return Text(
            device.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          );
        }),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              color: Colors.black.withOpacity(0.1),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F121D),
              Color(0xFF07090F),
            ],
          ),
        ),
        child: Obx(() {
          // Reactively fetch the latest device state
          final device = controller.devices.firstWhere(
            (d) => d.id == widget.device.id,
            orElse: () => widget.device,
          );
          final temp = device.temperature ?? 24;
          final isDeviceOn = device.isOn;
          final currentModeColor = _modeColor(device.mode);

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 1. Top Section: Beautiful AC Breeze Glow visualizer
                    _buildTopVisualizer(device),
                    const SizedBox(height: 10),

                    // 2. Middle Section: Radial Dial Flanked by Increment/Decrement Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decrement (-) Button
                        _buildRoundActionButton(
                          icon: Icons.remove,
                          onPressed: () {
                            if (temp > 16) {
                              controller.updateAcTemperature(device.id, temp - 1);
                            }
                          },
                        ),
                        const SizedBox(width: 15),

                        // Custom Temperature dial
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 210,
                              height: 210,
                              child: TemperatureDial(
                                value: temp,
                                minValue: 16,
                                maxValue: 30,
                                activeColor: isDeviceOn ? currentModeColor : AppTheme.textGrey.withOpacity(0.3),
                                onChanged: (newTemp) {
                                  if (isDeviceOn) {
                                    controller.updateAcTemperature(device.id, newTemp);
                                  }
                                },
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Temperature',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isDeviceOn ? '$temp°C' : '--°C',
                                  style: TextStyle(
                                    color: isDeviceOn ? Colors.white : AppTheme.textGrey,
                                    fontSize: 42,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (isDeviceOn) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    device.mode ?? 'Auto mode',
                                    style: TextStyle(
                                      color: currentModeColor.withOpacity(0.85),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(width: 15),

                        // Increment (+) Button
                        _buildRoundActionButton(
                          icon: Icons.add,
                          onPressed: () {
                            if (temp < 30) {
                              controller.updateAcTemperature(device.id, temp + 1);
                            }
                          },
                        ),
                      ],
                    ),

                    // Dial limits labels
                    SizedBox(
                      width: 200,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('16°', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
                          Text('30°', style: TextStyle(color: Colors.white.withOpacity(0.25), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Power and Sleep Timer Selector Row
                    _buildPowerTimerCard(device, controller),
                    const SizedBox(height: 16),

                    // 4. Mode Selection Grid
                    _buildModeSelectionCard(device, controller),
                    const SizedBox(height: 16),

                    // 5. Fan Speed Controls
                    _buildFanSpeedCard(),
                    const SizedBox(height: 16),

                    // 6. Air Swing Toggles
                    _buildSwingCard(),
                    const SizedBox(height: 16),

                    // Extra: Advanced Features (Sharp remote specifically)
                    _buildAdvancedFeaturesCard(),
                    const SizedBox(height: 16),

                    // 7. IR Remote Custom Buttons Learning
                    CollapsibleCard(
                      title: 'IR Learning',
                      subtitle: 'IR learning via IR Sensor',
                      icon: Icons.settings_remote_rounded,
                      child: PlacementDeviceIrControls(
                        device: device,
                        dashboardController: controller,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTopVisualizer(DeviceEntity device) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Column(
        children: [
          AcVisualizer(
            device: device,
            onDecreaseTemp: () {},
            onIncreaseTemp: () {},
            scale: 1.25,
          ),
        ],
      ),
    );
  }

  Widget _buildRoundActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.white70),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildPowerTimerCard(DeviceEntity device, DashboardController controller) {
    final isDeviceOn = device.isOn;
    return Row(
      children: [
        // Power Card
        Expanded(
          child: GestureDetector(
            onTap: () => controller.toggleDevice(device.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDeviceOn
                      ? [
                          const Color(0xFFEF4444).withOpacity(0.18),
                          const Color(0xFFEF4444).withOpacity(0.08),
                        ]
                      : [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDeviceOn
                      ? const Color(0xFFEF4444).withOpacity(0.5)
                      : Colors.white10,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.power_settings_new_rounded,
                    color: isDeviceOn ? const Color(0xFFEF4444) : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDeviceOn ? 'ON / تشغيل' : 'OFF / إيقاف',
                    style: TextStyle(
                      color: isDeviceOn ? const Color(0xFFEF4444) : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Sleep Timer Card
        Expanded(
          child: GestureDetector(
            onTap: () => _showSleepTimerSheet(context),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _timeLeft != null
                      ? [
                          AppTheme.primaryBlue.withOpacity(0.18),
                          AppTheme.primaryBlue.withOpacity(0.08),
                        ]
                      : [
                          Colors.white.withOpacity(0.05),
                          Colors.white.withOpacity(0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _timeLeft != null
                      ? AppTheme.primaryBlue.withOpacity(0.5)
                      : Colors.white10,
                  width: 1.2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: _timeLeft != null ? AppTheme.primaryBlue : Colors.white60,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _timeLeft != null ? _formatDuration(_timeLeft!) : 'Sleep Timer / مؤقت',
                    style: TextStyle(
                      color: _timeLeft != null ? AppTheme.primaryBlue : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    if (minutes < 60) {
      return '${minutes}m left';
    } else {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      if (mins > 0) {
        return '${hours}h ${mins}m';
      }
      return '${hours}h left';
    }
  }

  Widget _buildModeSelectionCard(DeviceEntity device, DashboardController controller) {
    final currentMode = device.mode ?? 'Auto mode';

    final modes = [
      _AcModeData('Auto mode', Icons.autorenew_outlined, const Color(0xFF00E5FF)),
      _AcModeData('Cool mode', Icons.ac_unit_outlined, const Color(0xFF60A5FA)),
      _AcModeData('Heat mode', Icons.whatshot_outlined, const Color(0xFFFB923C)),
      _AcModeData('Dry mode', Icons.water_drop_outlined, const Color(0xFF2DD4BF)),
      _AcModeData('Eco mode', Icons.eco_outlined, const Color(0xFF4ADE80)),
    ];

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'AC Mode / وضع التشغيل',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: modes.map((m) {
                final isSelected = currentMode == m.label;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => controller.setAcMode(device.id, m.label),
                    child: AnimatedContainer(
                      width: 72,
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? m.color.withOpacity(0.12)
                            : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? m.color.withOpacity(0.5)
                              : Colors.white10,
                          width: 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: m.color.withOpacity(0.2),
                                  blurRadius: 8,
                                  spreadRadius: -2,
                                )
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            m.icon,
                            color: isSelected ? m.color : Colors.white60,
                            size: 22,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            m.label.split(' ')[0],
                            style: TextStyle(
                              color: isSelected ? m.color : Colors.white60,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFanSpeedCard() {
    final speeds = ['Quiet', 'Low', 'Medium', 'High', 'Auto'];
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.wind_power_outlined, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Fan Speed / سرعة المروحة',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.04)),
            ),
            child: Row(
              children: speeds.map((speed) {
                final isSelected = _fanSpeed == speed;
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _fanSpeed = speed;
                      });
                      Get.snackbar(
                        'Fan Speed / سرعة المروحة',
                        'تم ضبط سرعة المروحة على $speed',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF1E293B),
                        colorText: Colors.white,
                        duration: const Duration(seconds: 1),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.primaryBlue.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: isSelected
                            ? Border.all(color: AppTheme.primaryBlue.withOpacity(0.4), width: 1.2)
                            : null,
                      ),
                      child: Text(
                        speed,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryBlue : Colors.white60,
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwingCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.swap_calls_rounded, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Air Swing / اتجاه الهواء',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSwingToggleButton(
                  icon: Icons.unfold_more_rounded,
                  label: 'Vertical Swing / عمودي',
                  isSelected: _verticalSwing,
                  onTap: () {
                    setState(() {
                      _verticalSwing = !_verticalSwing;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSwingToggleButton(
                  icon: Icons.swap_horiz_rounded,
                  label: 'Horizontal Swing / أفقي',
                  isSelected: _horizontalSwing,
                  onTap: () {
                    setState(() {
                      _horizontalSwing = !_horizontalSwing;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwingToggleButton({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryBlue.withOpacity(0.12)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryBlue.withOpacity(0.5)
                : Colors.white10,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryBlue : Colors.white60,
              size: 18,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? AppTheme.primaryBlue : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAdvancedFeaturesCard() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: AppTheme.primaryBlue, size: 18),
              SizedBox(width: 8),
              Text(
                'Advanced Features / ميزات إضافية',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              _buildFeatureToggle(
                icon: Icons.bubble_chart,
                label: 'Plasmacluster',
                isSelected: _isPlasmaclusterOn,
                onTap: () => setState(() {
                  _isPlasmaclusterOn = !_isPlasmaclusterOn;
                  _showFeatureToast('Plasmacluster', _isPlasmaclusterOn);
                }),
              ),
              _buildFeatureToggle(
                icon: Icons.speed_rounded,
                label: 'Super Jet',
                isSelected: _isSuperJetOn,
                activeColor: const Color(0xFF60A5FA),
                onTap: () => setState(() {
                  _isSuperJetOn = !_isSuperJetOn;
                  _showFeatureToast('Super Jet', _isSuperJetOn);
                }),
              ),
              _buildFeatureToggle(
                icon: Icons.air,
                label: 'Coanda',
                isSelected: _isCoandaOn,
                onTap: () => setState(() {
                  _isCoandaOn = !_isCoandaOn;
                  _showFeatureToast('Coanda', _isCoandaOn);
                }),
              ),
              _buildFeatureToggle(
                icon: Icons.person_pin_circle_rounded,
                label: 'My Area',
                isSelected: _isMyAreaOn,
                onTap: () => setState(() {
                  _isMyAreaOn = !_isMyAreaOn;
                  _showFeatureToast('My Area', _isMyAreaOn);
                }),
              ),
              _buildFeatureToggle(
                icon: Icons.light_mode_outlined,
                label: 'Display',
                isSelected: _isDisplayOn,
                onTap: () => setState(() {
                  _isDisplayOn = !_isDisplayOn;
                  _showFeatureToast('AC Display', _isDisplayOn);
                }),
              ),
              // Action Button (not toggle)
              GestureDetector(
                onTap: () {
                  Get.snackbar(
                    'Clean / تنظيف ذاتي',
                    'تم تفعيل وضع التنظيف الذاتي للمكيف.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF1E293B),
                    colorText: Colors.white,
                    duration: const Duration(seconds: 2),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white10, width: 1.2),
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.cleaning_services_rounded, color: Colors.white60, size: 22),
                      SizedBox(height: 6),
                      Text(
                        'Clean',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureToggle({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? activeColor,
  }) {
    final color = activeColor ?? AppTheme.primaryBlue;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.5) : Colors.white10,
            width: 1.2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 8, spreadRadius: -2)]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white60,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white60,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showFeatureToast(String featureName, bool isOn) {
    final status = isOn ? 'تفعيل' : 'إيقاف';
    Get.snackbar(
      '$featureName / ${featureName}',
      'تم $status خاصية $featureName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Radial Dial Widget
// ─────────────────────────────────────────────────────────────────────────────

class TemperatureDial extends StatefulWidget {
  final int value;
  final int minValue;
  final int maxValue;
  final ValueChanged<int> onChanged;
  final Color activeColor;

  const TemperatureDial({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  State<TemperatureDial> createState() => _TemperatureDialState();
}

class _TemperatureDialState extends State<TemperatureDial> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(TemperatureDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _updateTouch(Offset localPos, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPos.dx - center.dx;
    final dy = localPos.dy - center.dy;

    double angle = math.atan2(dy, dx);
    if (angle < 0) {
      angle += 2 * math.pi;
    }

    // Shift start angle from 135 deg (0.75 * pi) to 0
    double relativeAngle = angle - 0.75 * math.pi;
    if (relativeAngle < 0) {
      relativeAngle += 2 * math.pi;
    }

    double progressPercent;
    if (relativeAngle > 1.5 * math.pi) {
      final gapMiddle = 1.75 * math.pi;
      if (relativeAngle < gapMiddle) {
        progressPercent = 1.0;
      } else {
        progressPercent = 0.0;
      }
    } else {
      progressPercent = relativeAngle / (1.5 * math.pi);
    }

    final newTemp = (widget.minValue + progressPercent * (widget.maxValue - widget.minValue)).round().clamp(widget.minValue, widget.maxValue);
    if (newTemp != _currentValue) {
      setState(() {
        _currentValue = newTemp;
      });
      widget.onChanged(newTemp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return GestureDetector(
          onPanStart: (details) => _updateTouch(details.localPosition, size),
          onPanUpdate: (details) => _updateTouch(details.localPosition, size),
          child: CustomPaint(
            size: size,
            painter: TemperaturePainter(
              value: _currentValue,
              minValue: widget.minValue,
              maxValue: widget.maxValue,
              activeColor: widget.activeColor,
            ),
          ),
        );
      },
    );
  }
}

class TemperaturePainter extends CustomPainter {
  final int value;
  final int minValue;
  final int maxValue;
  final Color activeColor;

  TemperaturePainter({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.activeColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = 14.0;
    final radius = size.width / 2 - strokeWidth;

    // Background track
    final backgroundPaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.75 * math.pi,
      1.5 * math.pi,
      false,
      backgroundPaint,
    );

    // Active track
    final progressPercent = (value - minValue) / (maxValue - minValue);
    final sweepAngle = 1.5 * math.pi * progressPercent;

    if (sweepAngle > 0) {
      // Glow
      final glowPaint = Paint()
        ..color = activeColor.withOpacity(0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 6
        ..strokeCap = StrokeCap.round
        ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0.75 * math.pi,
        sweepAngle,
        false,
        glowPaint,
      );

      // Active line
      final activePaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        0.75 * math.pi,
        sweepAngle,
        false,
        activePaint,
      );
    }

    // Thumb (Handle) - represented as a pill rotated along the arc tangent
    final thumbAngle = 0.75 * math.pi + sweepAngle;
    final thumbX = center.dx + radius * math.cos(thumbAngle);
    final thumbY = center.dy + radius * math.sin(thumbAngle);

    canvas.save();
    canvas.translate(thumbX, thumbY);
    canvas.rotate(thumbAngle + math.pi / 2);

    // Draw thumb shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill
      ..imageFilter = ImageFilter.blur(sigmaX: 2, sigmaY: 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 14, height: 26),
        const Radius.circular(8),
      ),
      shadowPaint,
    );

    // Draw white thumb capsule
    final thumbPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 12, height: 24),
        const Radius.circular(6),
      ),
      thumbPaint,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant TemperaturePainter oldDelegate) {
    return oldDelegate.value != value ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.activeColor != activeColor;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Collapsible Card Helper
// ─────────────────────────────────────────────────────────────────────────────

class CollapsibleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const CollapsibleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  State<CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<CollapsibleCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                Icon(widget.icon, color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: Colors.white54,
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14.0),
              child: widget.child,
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }
}

class _AcModeData {
  final String label;
  final IconData icon;
  final Color color;

  const _AcModeData(this.label, this.icon, this.color);
}