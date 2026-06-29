import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
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

/// A page that displays a remote control interface for an air conditioner device.
///
/// It supports adjustments for temperature, fan speed, air swing direction,
/// sleep timer configuration, and infrared (IR) signal learning.
class RemotePage extends ConsumerStatefulWidget {
  /// The air conditioner device entity associated with this remote control page.
  final DeviceEntity device;

  /// Creates a [RemotePage] widget.
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

    // Reactively listen to the controller to synchronize the sleep timer remaining state
    ref.listen<DashboardState>(
      dashboardControllerProvider,
      (previous, next) {
        final newDevice = next.devices.firstWhereOrNull((d) => d.id == widget.device.id);
        if (newDevice is AcDeviceEntity) {
          final espSec = newDevice.sleepTimerRemaining ?? 0;
          final localSec = _timeLeft?.inSeconds ?? 0;
          if ((localSec - espSec).abs() > 5 || (espSec == 0 && localSec > 0) || (espSec > 0 && localSec == 0)) {
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
        }
      },
    );

    // Watch the active device state reactively
    final device = ref.watch(dashboardControllerProvider).devices.firstWhere(
      (d) => d.id == widget.device.id,
      orElse: () => widget.device,
    );

    final isDesktop = Responsive.isDesktop(context);
    final gap = Responsive.contentGap(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          device.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
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
        child: SafeArea(
          child: isDesktop
              ? _buildDesktopLayout(device, controller, gap)
              : _buildMobileLayout(device, controller),
        ),
      ),
    );
  }

  /// Builds a two-column layout optimized for desktop viewports.
  Widget _buildDesktopLayout(DeviceEntity device, DashboardController controller, double gap) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: gap * 1.5, vertical: gap * 0.5),
      key: const ValueKey('desktop_layout'),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel: Visualizer, Dial, and Power/Timer
          Expanded(
            flex: 5,
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTopVisualizer(device, scale: 1.6),
                    const SizedBox(height: 20),
                    _buildDialSection(device, controller, isDesktop: true),
                    const SizedBox(height: 24),
                    _buildPowerTimerCard(device, controller),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: gap * 1.5),

          // Right Panel: Device Control Panel
          Expanded(
            flex: 4,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _buildControlCardsList(device, controller, gap),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a single-column scrollable layout optimized for mobile and tablet screens.
  Widget _buildMobileLayout(DeviceEntity device, DashboardController controller) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      key: const ValueKey('mobile_layout'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildTopVisualizer(device),
            const SizedBox(height: 10),
            _buildDialSection(device, controller, isDesktop: false),
            const SizedBox(height: 24),
            _buildPowerTimerCard(device, controller),
            const SizedBox(height: 16),
            ..._buildControlCardsList(device, controller, 20.0),
          ],
        ),
      ),
    );
  }

  /// Helper to build the visualizer widget.
  Widget _buildTopVisualizer(DeviceEntity device, {double scale = 1.25}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 10, bottom: 15),
      child: Column(
        children: [
          AcVisualizer(
            device: device,
            onDecreaseTemp: () {
              final temp = device.temperature ?? 24;
              if (temp > 16) {
                ref.read(dashboardControllerProvider.notifier).updateAcTemperature(device.id, temp - 1);
              }
            },
            onIncreaseTemp: () {
              final temp = device.temperature ?? 24;
              if (temp < 30) {
                ref.read(dashboardControllerProvider.notifier).updateAcTemperature(device.id, temp + 1);
              }
            },
            scale: scale,
          ),
        ],
      ),
    );
  }

  /// Helper to build the temperature dial widget.
  Widget _buildDialSection(DeviceEntity device, DashboardController controller, {required bool isDesktop}) {
    final dialSize = isDesktop ? 280.0 : 210.0;
    final tempFontSize = isDesktop ? 52.0 : 42.0;
    final buttonSize = isDesktop ? 52.0 : 44.0;
    final buttonIconSize = isDesktop ? 22.0 : 18.0;
    final dialLabelWidth = isDesktop ? 260.0 : 200.0;

    final temp = device.temperature ?? 24;
    final isDeviceOn = device.isOn;
    final currentModeColor = _modeColor(device.mode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Decrement (-) Button
            _buildRoundActionButton(
              icon: Icons.remove,
              size: buttonSize,
              iconSize: buttonIconSize,
              onPressed: () {
                if (temp > 16) {
                  controller.updateAcTemperature(device.id, temp - 1);
                }
              },
            ),
            SizedBox(width: isDesktop ? 24 : 15),

            // Custom Temperature dial
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: dialSize,
                  height: dialSize,
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
                        fontSize: isDesktop ? 14 : 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isDeviceOn ? '$temp°C' : '°C',
                      style: TextStyle(
                        color: isDeviceOn ? Colors.white : AppTheme.textGrey,
                        fontSize: tempFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isDeviceOn) ...[
                      const SizedBox(height: 2),
                      Text(
                        device.mode ?? 'Auto mode',
                        style: TextStyle(
                          color: currentModeColor.withValues(alpha:0.85),
                          fontSize: isDesktop ? 13 : 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            SizedBox(width: isDesktop ? 24 : 15),

            // Increment (+) Button
            _buildRoundActionButton(
              icon: Icons.add,
              size: buttonSize,
              iconSize: buttonIconSize,
              onPressed: () {
                if (temp < 30) {
                  controller.updateAcTemperature(device.id, temp + 1);
                }
              },
            ),
          ],
        ),

        // Dial limits labels
        const SizedBox(height: 4),
        SizedBox(
          width: dialLabelWidth,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('16°', style: TextStyle(color: Colors.white.withValues(alpha:0.25), fontSize: 12)),
              Text('30°', style: TextStyle(color: Colors.white.withValues(alpha:0.25), fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper to build the power and timer card.
  Widget _buildPowerTimerCard(DeviceEntity device, DashboardController controller) {
    return PowerTimerCard(
      device: device,
      controller: controller,
      timeLeft: _timeLeft,
      onTimerTap: () => _showSleepTimerSheet(context),
    );
  }

  /// Generates the list of control card widgets.
  List<Widget> _buildControlCardsList(DeviceEntity device, DashboardController controller, double gap) {
    return [
      // Mode Selection Grid
      AcModeSelectionCard(device: device, controller: controller),
      SizedBox(height: gap * 0.8),

      // Fan Speed Controls
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
      SizedBox(height: gap * 0.8),

      // Air Swing Toggles
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
      SizedBox(height: gap * 0.8),

      // Advanced Features
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
      SizedBox(height: gap * 0.8),

      // IR Remote Custom Buttons Learning
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
    ];
  }

  /// Builds a rounded action button with transparency.
  Widget _buildRoundActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    double size = 44,
    double iconSize = 18,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.04),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white10),
      ),
      child: IconButton(
        icon: Icon(icon, size: iconSize, color: Colors.white70),
        onPressed: onPressed,
      ),
    );
  }
}