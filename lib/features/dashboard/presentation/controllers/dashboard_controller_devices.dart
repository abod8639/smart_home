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
            if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
              esp32.setAnalogOutput(pin, 0);
            } else {
              esp32.setDigitalOutput(pin, false);
            }
          } else if (device is RgbLampDeviceEntity) {
            final pin = device.pin ?? 23;
            if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
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
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      final device = newDevices[index];
      final newIsOn = !device.isOn;

      newDevices[index] = device.copyWith(isOn: newIsOn);
      state = state.copyWith(devices: newDevices);
      _persistDevices();

      // Matter Devices
      if (device.matterNodeId != null) {
        ref.read(matterServiceProvider.notifier).toggleDevice(
          device.matterNodeId!,
          device.matterEndpointId ?? 1,
          newIsOn,
        );
      }
      // Trigger ESP32 if the device matches our GPIO mappings
      else {
        final esp32 = ref.read(esp32ServiceProvider.notifier);
        if (device is LampDeviceEntity) {
          final pin = device.pin ?? 2;
          if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
            esp32.setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
          } else {
            esp32.setDigitalOutput(pin, newIsOn);
          }
        } else if (device is RgbLampDeviceEntity) {
          final pin = device.pin ?? 23;
          if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
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
          final pin = device.pin ?? 2;
          esp32.setDigitalOutput(pin, newIsOn);
        } else if (device is AcDeviceEntity) {
          if (device.acIrCodes.irPower != null) {
            sendIrCommand(null, device.acIrCodes.irPower!);
          } else if (device.pin != null) {
            esp32.setDigitalOutput(device.pin!, newIsOn);
          } else {
            esp32.sendRawCommand(
              'control/ac',
              method: 'POST',
              data: {'isOn': newIsOn},
            );
          }
        }
      }
    }
  }
  
  void toggleDoor(String id) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      final device = newDevices[index];
      if (device is DoorDeviceEntity) {
        final newIsLocked = !(device.isLocked ?? false);
        newDevices[index] = device.copyWith(isLocked: newIsLocked);
        state = state.copyWith(devices: newDevices);
        _persistDevices();

        // Unlocked = Relay HIGH, Locked = Relay LOW
        final esp32 = ref.read(esp32ServiceProvider.notifier);
        final pin = device.pin ?? 18;
        esp32.setDigitalOutput(pin, !newIsLocked);
      }
    }
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
          String currentTemp = state.temperature;
          String currentHum = state.humidity;
          
          if (data['temperature'] != null) {
            currentTemp = '${data['temperature']}°';
          }
          if (data['humidity'] != null) {
            currentHum = '${data['humidity']}%';
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
                // Find label corresponding to the configured pin
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
          
          if (changed || currentTemp != state.temperature || currentHum != state.humidity) {
            state = state.copyWith(
              devices: newDevices,
              temperature: currentTemp,
              humidity: currentHum,
            );
          }
        }
      } catch (e) {
        // Silently catch background polling exceptions
      }
    });
  }
}
