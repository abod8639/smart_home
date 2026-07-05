// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of '../esp32_service.dart';

extension Esp32ControllerSync on Esp32Service {
  void _syncStateWithControllers(Map<String, dynamic> state) {
    final env = ref.read(environmentControllerProvider.notifier);
    final dashboard = ref.read(dashboardControllerProvider.notifier);

    if (state['temperature'] != null) {
      env.setTemperature('${state['temperature']}°');
    }
    if (state['humidity'] != null) {
      env.setHumidity('${state['humidity']}%');
    }
    if (state['wifi_rssi'] != null) {
      env.setWifiRssi('${state['wifi_rssi']} dBm');
    }
    if (state['heap_free'] != null) {
      env.setHeapFree('${(state['heap_free'] / 1024).toStringAsFixed(1)} KB');
    }

    // Target AC temperature
    if (state['target_temperature'] != null) {
      final int targetTemp = state['target_temperature'];
      final acIndex = dashboard.state.devices.indexWhere((d) => d.id == 'ac1');
      if (acIndex != -1 && dashboard.state.devices[acIndex].temperature != targetTemp) {
        dashboard.updateDevice(dashboard.state.devices[acIndex].copyWith(temperature: targetTemp));
      }
    }

    // AC sleep timer remaining
    if (state['ac_timer_remaining'] != null) {
      final int timerRemaining = state['ac_timer_remaining'];
      final acIndex = dashboard.state.devices.indexWhere((d) => d.id == 'ac1');
      if (acIndex != -1) {
        final acDevice = dashboard.state.devices[acIndex] as AcDeviceEntity;
        if (acDevice.sleepTimerRemaining != timerRemaining) {
          dashboard.updateDevice(acDevice.copyWith(sleepTimerRemaining: timerRemaining));
        }
      }
    }

    // Relay & PWM pins mapping
    if (state['pins'] != null) {
      final pinsMap = state['pins'] as Map<String, dynamic>;
      _applyPinsMap(dashboard, pinsMap);
    }
  }

  void _syncSensorsWithControllers(Map<String, dynamic> data) {
    final env = ref.read(environmentControllerProvider.notifier);
    if (data['temperature'] != null) {
      env.setTemperature('${data['temperature']}°');
    }
    if (data['humidity'] != null) {
      env.setHumidity('${data['humidity']}%');
    }
  }

  void _syncRelayWithControllers(Map<String, dynamic> data) {
    final dashboard = ref.read(dashboardControllerProvider.notifier);
    final int? endpoint = data['endpoint'];
    final int? state = data['state'];
    if (endpoint == null || state == null) return;

    // Map Endpoint to Pin
    int pin = 2;
    if (endpoint == 2) {
      pin = 18;
    } else if (endpoint == 3) {
      pin = 19;
    } else if (endpoint == 4) {
      pin = 21;
    }

    for (var i = 0; i < dashboard.state.devices.length; i++) {
      final device = dashboard.state.devices[i];
      if (device.pin == pin || (device.id == 'lamp1' && endpoint == 1) || (device.id == 'door1' && endpoint == 2)) {
        if (device.type == DeviceType.door) {
          final bool isLocked = (state == 0);
          if (device.isLocked != isLocked) {
            dashboard.updateDevice(device.copyWith(isLocked: isLocked));
          }
        } else {
          final bool isOn = (state == 1);
          if (device.isOn != isOn) {
            dashboard.updateDevice(device.copyWith(isOn: isOn));
          }
        }
      }
    }
  }

  void _syncPwmWithControllers(Map<String, dynamic> data) {
    final dashboard = ref.read(dashboardControllerProvider.notifier);
    final int? endpoint = data['endpoint'];
    final int? level = data['level'];
    if (endpoint == null || level == null) return;

    for (var i = 0; i < dashboard.state.devices.length; i++) {
      final device = dashboard.state.devices[i];
      if (endpoint == 5 && device.type == DeviceType.lamp && (device.pin == 22 || device.id == 'lamp1')) {
        final bool isOn = level > 0;
        if (device.brightness != level || device.isOn != isOn) {
          dashboard.updateDevice(device.copyWith(brightness: level, isOn: isOn));
        }
      } else if (endpoint == 6 && device.type == DeviceType.rgb) {
        if (device.brightness != level) {
          dashboard.updateDevice(device.copyWith(brightness: level));
        }
      }
    }
  }

  void _syncAcWithControllers(Map<String, dynamic> data) {
    final dashboard = ref.read(dashboardControllerProvider.notifier);
    final bool? isOn = data['isOn'];
    final int? targetTemp = data['target_temp'];
    
    final acIndex = dashboard.state.devices.indexWhere((d) => d.id == 'ac1');
    if (acIndex != -1) {
      var ac = dashboard.state.devices[acIndex];
      if (isOn != null) ac = ac.copyWith(isOn: isOn);
      if (targetTemp != null) ac = ac.copyWith(temperature: targetTemp);
      dashboard.updateDevice(ac);
    }
  }

  void _applyPinsMap(DashboardController dashboard, Map<String, dynamic> pinsMap) {
    for (var i = 0; i < dashboard.state.devices.length; i++) {
      final device = dashboard.state.devices[i];
      final pin = device.pin;

      if (pin != null) {
        final label = device.pinLabel;

        if (label != null && pinsMap.containsKey(label)) {
          final val = pinsMap[label];
          if (device.type == DeviceType.door) {
            final bool isLocked = (val == 0);
            if (device.isLocked != isLocked) {
              dashboard.updateDevice(device.copyWith(isLocked: isLocked));
            }
          } else if (device.type == DeviceType.lamp && pin == 22) {
            final int brightness = val as int;
            final bool isOn = brightness > 0;
            if (device.brightness != brightness || device.isOn != isOn) {
              dashboard.updateDevice(device.copyWith(brightness: brightness, isOn: isOn));
            }
          } else if (device.type == DeviceType.rgb) {
            final int rVal = pinsMap['pwm_rgb_r'] ?? device.rgbR ?? 0;
            final int gVal = pinsMap['pwm_rgb_g'] ?? device.rgbG ?? 0;
            final int bVal = pinsMap['pwm_rgb_b'] ?? device.rgbB ?? 0;
            if (device.rgbR != rVal || device.rgbG != gVal || device.rgbB != bVal) {
              dashboard.updateDevice(device.copyWith(rgbR: rVal, rgbG: gVal, rgbB: bVal));
            }
          } else {
            if (device.type != DeviceType.airConditioner) {
              final bool isOn = (val == 1);
              if (device.isOn != isOn) {
                dashboard.updateDevice(device.copyWith(isOn: isOn));
              }
            }
          }
        }
      }
    }
  }
}
