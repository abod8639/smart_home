import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/widgets/ac_visualizer.dart';
import 'package:smart_home/features/room/presentation/widgets/placement_device_ir_controls.dart';

// Split components imports
import 'package:smart_home/features/dashboard/presentation/widgets/remote/temperature_dial.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/remote/collapsible_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/remote/ac_mode_selection_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/remote/fan_speed_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/remote/air_swing_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/remote/advanced_features_card.dart';

class RemotePage extends ConsumerStatefulWidget {
  final DeviceEntity device;
  const RemotePage({super.key, required this.device});

  @override
  State<RemotePage> createState() => _RemotePageState();
}

class _RemotePageState extends ConsumerState<RemotePage> {
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
  Timer? _countdownTimer;
  Duration? _timeLeft;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(dashboardControllerProvider.notifier);
    final d = controller.devices.firstWhereOrNull((device) => device.id == widget.device.id);
    if (d is AcDeviceEntity && d.sleepTimerRemaining != null && d.sleepTimerRemaining! > 0) {
      _timeLeft = Duration(seconds: d.sleepTimerRemaining!);
      _startLocalCountdown();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _setSleepTimer(Duration duration) {
    _countdownTimer?.cancel();
    _timeLeft = duration;
    _startLocalCountdown();

    ref.read(dashboardControllerProvider.notifier).setAcSleepTimer(widget.device.id, duration);
  }

  void _cancelSleepTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _timeLeft = null;
    if (mounted) {
      setState(() {});
    }
    
    ref.read(dashboardControllerProvider.notifier).setAcSleepTimer(widget.device.id, Duration.zero);
  }

  void _startLocalCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft == null || _timeLeft!.inSeconds <= 1) {
            _timeLeft = null;
            _countdownTimer?.cancel();
            _countdownTimer = null;
          } else {
            _timeLeft = Duration(seconds: _timeLeft!.inSeconds - 1);
          }
        });
      }
    });
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
              'Sleep Timer',
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
            _buildTimerOption(context, 'Turn Off Timer', const Duration(seconds: 0)),
            _buildTimerOption(context, '30 Minutes', const Duration(minutes: 30)),
            _buildTimerOption(context, '1 Hour', const Duration(hours: 1)),
            _buildTimerOption(context, '2 Hours', const Duration(hours: 2)),
            _buildTimerOption(context, '4 Hours', const Duration(hours: 4)),
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
          color: isCurrent ? AppTheme.primaryBlue.withValues(alpha:0.1) : Colors.white.withValues(alpha:0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrent ? AppTheme.primaryBlue.withValues(alpha:0.5) : Colors.white10,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardController controller = ref.read(dashboardControllerProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Consumer(builder: (context, ref, _) {
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
              color: Colors.black.withValues(alpha:0.1),
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
        child: Consumer(builder: (context, ref, _) {
          // Reactively fetch the latest device state
          final device = controller.devices.firstWhere(
            (d) => d.id == widget.device.id,
            orElse: () => widget.device,
          );

          if (device is AcDeviceEntity) {
            final espSec = device.sleepTimerRemaining ?? 0;
            final localSec = _timeLeft?.inSeconds ?? 0;
            if ((localSec - espSec).abs() > 5 || (espSec == 0 && localSec > 0) || (espSec > 0 && localSec == 0)) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    if (espSec > 0) {
                      _timeLeft = Duration(seconds: espSec);
                      _startLocalCountdown();
                    } else {
                      _timeLeft = null;
                      _countdownTimer?.cancel();
                      _countdownTimer = null;
                    }
                  });
                }
              });
            }
          }

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
                                activeColor: isDeviceOn ? currentModeColor : AppTheme.textGrey.withValues(alpha:0.3),
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
                                    color: Colors.white.withValues(alpha:0.4),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isDeviceOn ? '$temp°C' : '°C',
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
                                      color: currentModeColor.withValues(alpha:0.85),
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
                          Text('16°', style: TextStyle(color: Colors.white.withValues(alpha:0.25), fontSize: 12)),
                          Text('30°', style: TextStyle(color: Colors.white.withValues(alpha:0.25), fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Power and Sleep Timer Selector Row
                    _buildPowerTimerCard(device, controller),
                    const SizedBox(height: 16),

                    // 4. Mode Selection Grid
                    AcModeSelectionCard(device: device, controller: controller),
                    const SizedBox(height: 16),

                    // 5. Fan Speed Controls
                    FanSpeedCard(
                      device: device,
                      controller: controller,
                      currentFanSpeed: _fanSpeed,
                      onFanSpeedChanged: (speed) {
                        setState(() {
                          _fanSpeed = speed;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // 6. Air Swing Toggles
                    AirSwingCard(
                      device: device,
                      controller: controller,
                      verticalSwing: _verticalSwing,
                      horizontalSwing: _horizontalSwing,
                      onVerticalSwingChanged: (val) {
                        setState(() {
                          _verticalSwing = val;
                        });
                      },
                      onHorizontalSwingChanged: (val) {
                        setState(() {
                          _horizontalSwing = val;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Extra: Advanced Features (Sharp remote specifically)
                    AdvancedFeaturesCard(
                      device: device,
                      controller: controller,
                      isPlasmaclusterOn: _isPlasmaclusterOn,
                      isSuperJetOn: _isSuperJetOn,
                      isCoandaOn: _isCoandaOn,
                      isMyAreaOn: _isMyAreaOn,
                      isDisplayOn: _isDisplayOn,
                      onPlasmaclusterChanged: (val) => setState(() => _isPlasmaclusterOn = val),
                      onSuperJetChanged: (val) => setState(() => _isSuperJetOn = val),
                      onCoandaChanged: (val) => setState(() => _isCoandaOn = val),
                      onMyAreaChanged: (val) => setState(() => _isMyAreaOn = val),
                      onDisplayChanged: (val) => setState(() => _isDisplayOn = val),
                    ),
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
        color: Colors.white.withValues(alpha:0.04),
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
            onTap: isDeviceOn ? () => controller.toggleDevice(device.id) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDeviceOn
                      ? [
                          const Color(0xFFEF4444).withValues(alpha:0.18),
                          const Color(0xFFEF4444).withValues(alpha:0.08),
                        ]
                      : [
                          Colors.white.withValues(alpha:0.05),
                          Colors.white.withValues(alpha:0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDeviceOn
                      ? const Color(0xFFEF4444).withValues(alpha:0.5)
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
                    isDeviceOn ? 'ON' : 'OFF',
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
                          AppTheme.primaryBlue.withValues(alpha:0.18),
                          AppTheme.primaryBlue.withValues(alpha: .08),
                        ]
                      : [
                          Colors.white.withValues(alpha:0.05),
                          Colors.white.withValues(alpha:0.02),
                        ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _timeLeft != null
                      ? AppTheme.primaryBlue.withValues(alpha:0.5)
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
                    _timeLeft != null ? _formatDuration(_timeLeft!) : 'Sleep Timer',
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
}