part of '../esp32_service.dart';

extension Esp32ControllerSync on Esp32Service {
  void _syncStateWithControllers(Map<String, dynamic> state) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    
    if (state['temperature'] != null) {
      dashboard.temperature.value = '${state['temperature']}°';
    }
    if (state['humidity'] != null) {
      dashboard.humidity.value = '${state['humidity']}%';
    }
    if (state['wifi_rssi'] != null) {
      dashboard.wifiRssi.value = '${state['wifi_rssi']} dBm';
    }
    if (state['heap_free'] != null) {
      dashboard.heapFree.value = '${(state['heap_free'] / 1024).toStringAsFixed(1)} KB';
    }

    // Target AC temperature
    if (state['target_temperature'] != null) {
      final int targetTemp = state['target_temperature'];
      final acIndex = dashboard.devices.indexWhere((d) => d.id == 'ac1');
      if (acIndex != -1 && dashboard.devices[acIndex].temperature != targetTemp) {
        dashboard.devices[acIndex] = dashboard.devices[acIndex].copyWith(temperature: targetTemp);
      }
    }

    // Relay & PWM pins mapping
    if (state['pins'] != null) {
      final pinsMap = state['pins'] as Map<String, dynamic>;
      _applyPinsMap(dashboard, pinsMap);
    }
  }

  void _syncSensorsWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    if (data['temperature'] != null) {
      dashboard.temperature.value = '${data['temperature']}°';
    }
    if (data['humidity'] != null) {
      dashboard.humidity.value = '${data['humidity']}%';
    }
  }

  void _syncRelayWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
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

    for (var i = 0; i < dashboard.devices.length; i++) {
      final device = dashboard.devices[i];
      if (device.pin == pin || (device.id == 'lamp1' && endpoint == 1) || (device.id == 'door1' && endpoint == 2)) {
        if (device.type == DeviceType.door) {
          final bool isLocked = (state == 0);
          if (device.isLocked != isLocked) {
            dashboard.devices[i] = device.copyWith(isLocked: isLocked);
          }
        } else {
          final bool isOn = (state == 1);
          if (device.isOn != isOn) {
            dashboard.devices[i] = device.copyWith(isOn: isOn);
          }
        }
      }
    }
  }

  void _syncPwmWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    final int? endpoint = data['endpoint'];
    final int? level = data['level'];
    if (endpoint == null || level == null) return;

    for (var i = 0; i < dashboard.devices.length; i++) {
      final device = dashboard.devices[i];
      if (endpoint == 5 && device.type == DeviceType.lamp && (device.pin == 22 || device.id == 'lamp1')) {
        final bool isOn = level > 0;
        if (device.brightness != level || device.isOn != isOn) {
          dashboard.devices[i] = device.copyWith(brightness: level, isOn: isOn);
        }
      } else if (endpoint == 6 && device.type == DeviceType.rgb) {
        if (device.brightness != level) {
          dashboard.devices[i] = device.copyWith(brightness: level);
        }
      }
    }
  }

  void _syncAcWithControllers(Map<String, dynamic> data) {
    if (!Get.isRegistered<DashboardController>()) return;
    final dashboard = Get.find<DashboardController>();
    final bool? isOn = data['isOn'];
    final int? targetTemp = data['target_temp'];
    
    final acIndex = dashboard.devices.indexWhere((d) => d.id == 'ac1');
    if (acIndex != -1) {
      var ac = dashboard.devices[acIndex];
      if (isOn != null) ac = ac.copyWith(isOn: isOn);
      if (targetTemp != null) ac = ac.copyWith(temperature: targetTemp);
      dashboard.devices[acIndex] = ac;
    }
  }

  void _applyPinsMap(DashboardController dashboard, Map<String, dynamic> pinsMap) {
    for (var i = 0; i < dashboard.devices.length; i++) {
      final device = dashboard.devices[i];
      final pin = device.pin;

      if (pin != null) {
        String? label;
        if (pin == 2) {
          label = 'relay_1';
        } else if (pin == 18) {
          label = 'relay_2';
        } else if (pin == 19) {
          label = 'relay_3';
        } else if (pin == 21) {
          label = 'relay_4';
        } else if (pin == 22) {
          label = 'pwm_lamp';
        } else if (pin == 23) {
          label = 'pwm_rgb_r';
        } else if (pin == 25) {
          label = 'pwm_rgb_g';
        } else if (pin == 26) {
          label = 'pwm_rgb_b';
        }

        if (label != null && pinsMap.containsKey(label)) {
          final val = pinsMap[label];
          if (device.type == DeviceType.door) {
            final bool isLocked = (val == 0);
            if (device.isLocked != isLocked) {
              dashboard.devices[i] = device.copyWith(isLocked: isLocked);
            }
          } else if (device.type == DeviceType.lamp && pin == 22) {
            final int brightness = val as int;
            final bool isOn = brightness > 0;
            if (device.brightness != brightness || device.isOn != isOn) {
              dashboard.devices[i] = device.copyWith(brightness: brightness, isOn: isOn);
            }
          } else if (device.type == DeviceType.rgb) {
            final int rVal = pinsMap['pwm_rgb_r'] ?? device.rgbR ?? 0;
            final int gVal = pinsMap['pwm_rgb_g'] ?? device.rgbG ?? 0;
            final int bVal = pinsMap['pwm_rgb_b'] ?? device.rgbB ?? 0;
            if (device.rgbR != rVal || device.rgbG != gVal || device.rgbB != bVal) {
              dashboard.devices[i] = device.copyWith(rgbR: rVal, rgbG: gVal, rgbB: bVal);
            }
          } else {
            if (device.type != DeviceType.airConditioner) {
              final bool isOn = (val == 1);
              if (device.isOn != isOn) {
                dashboard.devices[i] = device.copyWith(isOn: isOn);
              }
            }
          }
        }
      }
    }
  }
}
