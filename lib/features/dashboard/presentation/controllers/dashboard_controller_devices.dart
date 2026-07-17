// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of 'dashboard_controller.dart';

// ==========================================
// Device Management & Control Logic
// ==========================================

extension DashboardControllerDevices on DashboardController {
  void addDevice(DeviceEntity device) {
    var deviceWithRoom = device.roomId == null && activeRoom != null
        ? device.copyWith(roomId: activeRoom!.id)
        : device;
    // Default position to center if null
    final deviceWithPos = deviceWithRoom.positionX == null 
        ? deviceWithRoom.copyWith(positionX: 0.5, positionY: 0.5)
        : deviceWithRoom;
        
    state = state.copyWith(devices: [...state.devices, deviceWithPos]);
    _persistDevices();

    // Notify ESP32 to create a dynamic Matter endpoint
    int deviceType = 1; // 1 = on_off_light
    int pin = 4; // Default pin for dynamic endpoints

    if (device is LampDeviceEntity) {
      deviceType = 1;
    } else if (device is RgbLampDeviceEntity) {
      deviceType = 3; // dimmable_light or color_control
    } else if (device is DoorDeviceEntity) {
      deviceType = 2; // on_off_plugin_unit
    }

    final esp32 = ref.read(esp32ServiceProvider.notifier);
    esp32.sendRawCommand('commands', method: 'POST', data: {
      'action': 'add_device',
      'type': deviceType,
      'pin': pin,
    });
  }

  void updateDevice(DeviceEntity device) {
    final index = state.devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      newDevices[index] = device;
      state = state.copyWith(devices: newDevices);
      _persistDevices();
    }
  }

  void deleteDevice(String id) {
    final newDevices = state.devices.where((d) => d.id != id).toList();
    state = state.copyWith(devices: newDevices);
    _persistDevices();
  }

  void updateDevicePosition(String id, double x, double y, {bool persist = true}) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      newDevices[index] = newDevices[index].copyWith(positionX: x, positionY: y);
      state = state.copyWith(devices: newDevices);
      if (persist) {
        _persistDevices();
      }
    }
  }

  void persistDevices() {
    _persistDevices();
  }

  void reorderDevices(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newDevices = List<DeviceEntity>.from(state.devices);
    final device = newDevices.removeAt(oldIndex);
    newDevices.insert(newIndex, device);
    state = state.copyWith(devices: newDevices);
    _persistDevices();
  }

  void closeAllDevicesInRoom(String roomId) {
    bool changed = false;
    final newDevices = List<DeviceEntity>.from(state.devices);
    for (int i = 0; i < newDevices.length; i++) {
      final device = newDevices[i];
      if (device.roomId == roomId && device.isOn) {
        newDevices[i] = device.copyWith(isOn: false);
        changed = true;

        // Matter Devices
        if (device.matterNodeId != null) {
          ref.read(matterServiceProvider.notifier).toggleDevice(
            device.matterNodeId!,
            device.matterEndpointId ?? 1,
            false,
          );
        }
        // Trigger ESP32 if the device matches our GPIO mappings
        else {
          final esp32 = ref.read(esp32ServiceProvider.notifier);
          if (device is LampDeviceEntity) {
            final pin = device.pin ?? 2;
            if (device.isPwmConfigured) {
              esp32.setAnalogOutput(pin, 0);
            } else {
              esp32.setDigitalOutput(pin, false);
            }
          } else if (device is RgbLampDeviceEntity) {
            final pin = device.pin ?? 23;
            if (device.isPwmConfigured) {
              if (pin == 23) {
                esp32.setAnalogOutput(23, 0);
                esp32.setAnalogOutput(25, 0);
                esp32.setAnalogOutput(26, 0);
              } else {
                esp32.setAnalogOutput(pin, 0);
              }
            } else {
              esp32.setDigitalOutput(pin, false);
            }
          } else if (device is VacuumDeviceEntity) {
            final pin = device.pin ?? 2;
            esp32.setDigitalOutput(pin, false);
          } else if (device is AcDeviceEntity) {
            if (device.acIrCodes.irPower != null) {
              sendIrCommand(null, device.acIrCodes.irPower!);
            } else if (device.pin != null) {
              esp32.setDigitalOutput(device.pin!, false);
            } else {
              esp32.sendRawCommand(
                'control/ac',
                method: 'POST',
                data: {'isOn': false},
              );
            }
          }
        }
      }
    }
    if (changed) {
      state = state.copyWith(devices: newDevices);
      _persistDevices();
    }
  }

  void toggleDevice(String id) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    // Ignore if already pending (debounce)
    if (state.pendingDeviceIds.contains(id)) return;

    final device = state.devices[index];
    final newIsOn = !device.isOn;

    // Matter devices: optimistic update (Matter has its own ack mechanism)
    if (device.matterNodeId != null) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      newDevices[index] = device.copyWith(isOn: newIsOn);
      state = state.copyWith(devices: newDevices);
      _persistDevices();
      ref.read(matterServiceProvider.notifier).toggleDevice(
        device.matterNodeId!,
        device.matterEndpointId ?? 1,
        newIsOn,
      );
      return;
    }

    final esp32 = ref.read(esp32ServiceProvider.notifier);
    final isMqttConnected = ref.read(isConnectedProvider);

    if (!isMqttConnected) {
      // Firebase fallback: no confirmation message expected, update immediately
      final newDevices = List<DeviceEntity>.from(state.devices);
      newDevices[index] = device.copyWith(isOn: newIsOn);
      state = state.copyWith(devices: newDevices);
      _persistDevices();
      if (device is LampDeviceEntity) {
        final pin = device.pin ?? 2;
        if (device.isPwmConfigured) {
          esp32.setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
        } else {
          esp32.setDigitalOutput(pin, newIsOn);
        }
      } else if (device is RgbLampDeviceEntity) {
        final pin = device.pin ?? 23;
        if (device.isPwmConfigured) {
          if (pin == 23) {
            esp32.setAnalogOutput(23, newIsOn ? (device.rgbR ?? 255) : 0);
            esp32.setAnalogOutput(25, newIsOn ? (device.rgbG ?? 255) : 0);
            esp32.setAnalogOutput(26, newIsOn ? (device.rgbB ?? 255) : 0);
          } else {
            esp32.setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
          }
        } else {
          esp32.setDigitalOutput(pin, newIsOn);
        }
      } else if (device is VacuumDeviceEntity) {
        esp32.setDigitalOutput(device.pin ?? 2, newIsOn);
      } else if (device is AcDeviceEntity) {
        if (device.acIrCodes.irPower != null) {
          sendIrCommand(null, device.acIrCodes.irPower!);
        } else if (device.pin != null) {
          esp32.setDigitalOutput(device.pin!, newIsOn);
        } else {
          esp32.sendRawCommand('control/ac', method: 'POST', data: {'isOn': newIsOn});
        }
      }
      return;
    }

    // MQTT connected: enter pending state and wait for ESP32 confirmation
    final newPending = Set<String>.from(state.pendingDeviceIds)..add(id);
    state = state.copyWith(pendingDeviceIds: newPending);

    // Send command
    if (device is LampDeviceEntity) {
      final pin = device.pin ?? 2;
      if (device.isPwmConfigured) {
        esp32.setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
      } else {
        esp32.setDigitalOutput(pin, newIsOn);
      }
    } else if (device is RgbLampDeviceEntity) {
      final pin = device.pin ?? 23;
      if (device.isPwmConfigured) {
        if (pin == 23) {
          esp32.setAnalogOutput(23, newIsOn ? (device.rgbR ?? 255) : 0);
          esp32.setAnalogOutput(25, newIsOn ? (device.rgbG ?? 255) : 0);
          esp32.setAnalogOutput(26, newIsOn ? (device.rgbB ?? 255) : 0);
        } else {
          esp32.setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
        }
      } else {
        esp32.setDigitalOutput(pin, newIsOn);
      }
    } else if (device is VacuumDeviceEntity) {
      esp32.setDigitalOutput(device.pin ?? 2, newIsOn);
    } else if (device is AcDeviceEntity) {
      if (device.acIrCodes.irPower != null) {
        sendIrCommand(null, device.acIrCodes.irPower!);
        // IR devices: remove pending after IR send completes (no relay_update expected)
        Future.delayed(const Duration(milliseconds: 800), () {
          if (!ref.mounted) return;
          final removePending = Set<String>.from(state.pendingDeviceIds)..remove(id);
          final idx = state.devices.indexWhere((d) => d.id == id);
          if (idx != -1) {
            final updated = List<DeviceEntity>.from(state.devices);
            updated[idx] = state.devices[idx].copyWith(isOn: newIsOn);
            state = state.copyWith(devices: updated, pendingDeviceIds: removePending);
          } else {
            state = state.copyWith(pendingDeviceIds: removePending);
          }
          _persistDevices();
        });
        return;
      } else if (device.pin != null) {
        esp32.setDigitalOutput(device.pin!, newIsOn);
      } else {
        esp32.sendRawCommand('control/ac', method: 'POST', data: {'isOn': newIsOn});
      }
    }

    // Timeout: if ESP32 does not confirm within 5 seconds, cancel pending
    Future.delayed(const Duration(seconds: 5), () {
      if (!ref.mounted) return;
      if (state.pendingDeviceIds.contains(id)) {
        final removePending = Set<String>.from(state.pendingDeviceIds)..remove(id);
        state = state.copyWith(pendingDeviceIds: removePending);
        debugPrint('[Pending] Timeout: no confirmation from ESP32 for device $id');
      }
    });
  }

  void toggleDoor(String id) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    // Ignore if already pending (debounce)
    if (state.pendingDeviceIds.contains(id)) return;

    final device = state.devices[index];
    if (device is! DoorDeviceEntity) return;

    final newIsLocked = !(device.isLocked ?? false);
    final esp32 = ref.read(esp32ServiceProvider.notifier);
    final pin = device.pin ?? 18;
    final isMqttConnected = ref.read(isConnectedProvider);

    if (!isMqttConnected) {
      // Firebase fallback: no confirmation expected, update immediately
      final newDevices = List<DeviceEntity>.from(state.devices);
      newDevices[index] = device.copyWith(isLocked: newIsLocked);
      state = state.copyWith(devices: newDevices);
      _persistDevices();
      esp32.setDigitalOutput(pin, !newIsLocked); // Unlocked = HIGH, Locked = LOW
      return;
    }

    // MQTT connected: enter pending state and wait for ESP32 confirmation
    final newPending = Set<String>.from(state.pendingDeviceIds)..add(id);
    state = state.copyWith(pendingDeviceIds: newPending);

    // Unlocked = Relay HIGH, Locked = Relay LOW
    esp32.setDigitalOutput(pin, !newIsLocked);

    // Timeout: if ESP32 does not confirm within 5 seconds, cancel pending
    Future.delayed(const Duration(seconds: 5), () {
      if (!ref.mounted) return;
      if (state.pendingDeviceIds.contains(id)) {
        final removePending = Set<String>.from(state.pendingDeviceIds)..remove(id);
        state = state.copyWith(pendingDeviceIds: removePending);
        debugPrint('[Pending] Timeout: no confirmation from ESP32 for door $id');
      }
    });
  }

  void updateDeviceBrightness(String id, int brightness) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      final device = newDevices[index];
      final newIsOn = brightness > 0;
      
      if (device is LampDeviceEntity) {
        newDevices[index] = device.copyWith(
          brightness: brightness,
          isOn: newIsOn,
        );
      } else if (device is RgbLampDeviceEntity) {
        newDevices[index] = device.copyWith(
          brightness: brightness,
          isOn: newIsOn,
        );
      }
      
      state = state.copyWith(devices: newDevices);
      _persistDevices();

      // Matter Devices
      if (device.matterNodeId != null) {
        ref.read(matterServiceProvider.notifier).setBrightness(
          device.matterNodeId!,
          device.matterEndpointId ?? 1,
          brightness,
        );
      }
      // Control ESP32 PWM lamp (pin 22)
      else {
        final esp32 = ref.read(esp32ServiceProvider.notifier);
        final pin = device.pin ?? 22;
        esp32.setAnalogOutput(pin, brightness);
      }
    }
  }

  void updateDeviceColor(String id, int r, int g, int b) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      final device = newDevices[index];
      if (device is RgbLampDeviceEntity) {
        newDevices[index] = device.copyWith(rgbR: r, rgbG: g, rgbB: b);
        state = state.copyWith(devices: newDevices);
        _persistDevices();

        // Matter Devices
        if (device.matterNodeId != null) {
          ref.read(matterServiceProvider.notifier).setColor(
            device.matterNodeId!,
            device.matterEndpointId ?? 1,
            r,
            g,
            b,
          );
        }
        // Control ESP32 RGB Strip channels (R: 23, G: 25, B: 26)
        else {
          final esp32 = ref.read(esp32ServiceProvider.notifier);
          final pin = device.pin ?? 23;
          if (pin == 23) {
            esp32.setAnalogOutput(23, r);
            esp32.setAnalogOutput(25, g);
            esp32.setAnalogOutput(26, b);
          } else {
            esp32.setAnalogOutput(pin, r);
            esp32.setAnalogOutput(25, g);
            esp32.setAnalogOutput(26, b);
          }
        }
      }
    }
  }

  void updateDeviceMarkerSize(String id, double width, double height, {bool persist = true}) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      newDevices[index] = newDevices[index].copyWith(
        markerWidth: width.clamp(0.05, 0.8),
        markerHeight: height.clamp(0.05, 0.8),
      );
      state = state.copyWith(devices: newDevices);
      if (persist) {
        _persistDevices();
      }
    }
  }

  void _startAcTimer() {
    _acTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      bool changed = false;
      final newDevices = List<DeviceEntity>.from(state.devices);
      for (int i = 0; i < newDevices.length; i++) {
        final d = newDevices[i];
        if (d.type == DeviceType.airConditioner && d.isOn) {
          newDevices[i] = d.copyWith(coolingTime: (d.coolingTime ?? 0) + 1);
          changed = true;
        }
      }
      if (changed) {
        state = state.copyWith(devices: newDevices);
      }
    });
  }

  void _startEsp32Polling() {
    _espTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      try {
        final esp32 = ref.read(esp32ServiceProvider.notifier);
        final response = await esp32.getSensorData();
        if (response.isSuccess && response.data != null) {
          final data = response.data!;
          if (data['temperature'] != null) {
            ref.read(environmentControllerProvider.notifier).setTemperature('${data['temperature']}°');
          }
          if (data['humidity'] != null) {
            ref.read(environmentControllerProvider.notifier).setHumidity('${data['humidity']}%');
          }

          final newDevices = List<DeviceEntity>.from(state.devices);
          bool changed = false;

          // Sync target AC temperature (primary AC: ac1)
          if (data['target_temperature'] != null) {
            final int targetTemp = data['target_temperature'];
            final acIndex = newDevices.indexWhere((d) => d.id == 'ac1');
            if (acIndex != -1 && newDevices[acIndex].temperature != targetTemp) {
              newDevices[acIndex] = newDevices[acIndex].copyWith(temperature: targetTemp);
              changed = true;
            }
          }

          // Sync AC Sleep Timer remaining seconds
          if (data['ac_timer_remaining'] != null) {
            final int timerRemaining = data['ac_timer_remaining'];
            final acIndex = newDevices.indexWhere((d) => d.id == 'ac1');
            if (acIndex != -1) {
              final acDevice = newDevices[acIndex] as AcDeviceEntity;
              if (acDevice.sleepTimerRemaining != timerRemaining) {
                newDevices[acIndex] = acDevice.copyWith(sleepTimerRemaining: timerRemaining);
                changed = true;
              }
            }
          }

          if (data['pins'] != null) {
            final pinsMap = data['pins'] as Map<String, dynamic>;

            for (var i = 0; i < newDevices.length; i++) {
              final device = newDevices[i];
              final pin = device.pin;

              if (pin != null) {
                final label = device.pinLabel;

                if (label != null && pinsMap.containsKey(label)) {
                  final val = pinsMap[label];
                  if (device.type == DeviceType.door) {
                    final bool isLocked = (val == 0);
                    if (device.isLocked != isLocked) {
                      newDevices[i] = device.copyWith(isLocked: isLocked);
                      changed = true;
                    }
                  } else if (device.type == DeviceType.lamp && pin == 22) {
                    final int brightness = val as int;
                    final bool isOn = brightness > 0;
                    if (device.brightness != brightness || device.isOn != isOn) {
                      newDevices[i] = device.copyWith(brightness: brightness, isOn: isOn);
                      changed = true;
                    }
                  } else if (device.type == DeviceType.rgb) {
                    final int rVal = pinsMap['pwm_rgb_r'] ?? device.rgbR ?? 0;
                    final int gVal = pinsMap['pwm_rgb_g'] ?? device.rgbG ?? 0;
                    final int bVal = pinsMap['pwm_rgb_b'] ?? device.rgbB ?? 0;
                    if (device.rgbR != rVal || device.rgbG != gVal || device.rgbB != bVal) {
                      newDevices[i] = device.copyWith(rgbR: rVal, rgbG: gVal, rgbB: bVal);
                      changed = true;
                    }
                  } else {
                    // Skip IR-controlled devices (AC)
                    if (device.type != DeviceType.airConditioner) {
                      final bool isOn = (val == 1);
                      if (device.isOn != isOn) {
                        newDevices[i] = device.copyWith(isOn: isOn);
                        changed = true;
                      }
                    }
                  }
                }
              } else {
                // Backward-compatible fallback for hardcoded default devices when pin is null
                if (device.id == 'lamp1' && pinsMap.containsKey('relay_1')) {
                  final int val = pinsMap['relay_1'];
                  if (device.isOn != (val == 1)) {
                    newDevices[i] = device.copyWith(isOn: val == 1);
                    changed = true;
                  }
                } else if (device.id == 'door1' && pinsMap.containsKey('relay_2')) {
                  final int val = pinsMap['relay_2'];
                  if ((device.isLocked ?? true) != (val == 0)) {
                    newDevices[i] = device.copyWith(isLocked: val == 0);
                    changed = true;
                  }
                }
              }
            }
          }
          
          if (changed) {
            state = state.copyWith(
              devices: newDevices,
            );
          }
        }
      } catch (e) {
        // Silently catch background polling exceptions
      }
    });
  }
}
