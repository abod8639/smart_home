import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
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
import 'package:smart_home/features/dashboard/presentation/widgets/remote/power_timer_card.dart';
import 'package:smart_home/features/dashboard/presentation/widgets/remote/sleep_timer_sheet.dart';

class RemotePage extends ConsumerStatefulWidget {
  final DeviceEntity device;
  const RemotePage({super.key, required this.device});

  @override
  ConsumerState<RemotePage> createState() => _RemotePageState();
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
    final d = ref.read(dashboardControllerProvider).devices.firstWhereOrNull((device) => device.id == widget.device.id);
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

    ref.read(dashboardControllerProvider.notifier).setAcSleepTimer(context, widget.device.id, duration);
  }

  void _cancelSleepTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    _timeLeft = null;
    if (mounted) {
      setState(() {});
    }
    
    ref.read(dashboardControllerProvider.notifier).setAcSleepTimer(context, widget.device.id, Duration.zero);
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
      builder: (_) => SleepTimerSheet(
        timeLeft: _timeLeft,
        onDurationSelected: (duration) {
          if (duration.inSeconds == 0) {
            _cancelSleepTimer();
          } else {
            _setSleepTimer(duration);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = ref.read(dashboardControllerProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Consumer(builder: (context, ref, _) {
          final device = ref.watch(dashboardControllerProvider).devices.firstWhere(
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
          final device = ref.watch(dashboardControllerProvider).devices.firstWhere(
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
                    PowerTimerCard(
                      device: device,
                      controller: controller,
                      timeLeft: _timeLeft,
                      onTimerTap: () => _showSleepTimerSheet(context),
                    ),
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


}