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
    devices.add(deviceWithPos);
    _persistDevices();
  }

  void updateDevice(DeviceEntity device) {
    final index = devices.indexWhere((d) => d.id == device.id);
    if (index != -1) {
      devices[index] = device;
      _persistDevices();
    }
  }

  void deleteDevice(String id) {
    devices.removeWhere((d) => d.id == id);
    _persistDevices();
  }

  void updateDevicePosition(String id, double x, double y, {bool persist = true}) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(positionX: x, positionY: y);
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
    final device = devices.removeAt(oldIndex);
    devices.insert(newIndex, device);
    _persistDevices();
  }

  void closeAllDevicesInRoom(String roomId) {
    bool changed = false;
    for (int i = 0; i < devices.length; i++) {
      final device = devices[i];
      if (device.roomId == roomId && device.isOn) {
        devices[i] = device.copyWith(isOn: false);
        changed = true;

        // Matter Devices
        if (device.matterNodeId != null && Get.isRegistered<MatterService>()) {
          Get.find<MatterService>().toggleDevice(
            device.matterNodeId!,
            device.matterEndpointId ?? 1,
            false,
          );
        }
        // Trigger ESP32 if the device matches our GPIO mappings
        else if (Get.isRegistered<Esp32Service>()) {
          if (device is LampDeviceEntity) {
            final pin = device.pin ?? 2;
            if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
              Get.find<Esp32Service>().setAnalogOutput(pin, 0);
            } else {
              Get.find<Esp32Service>().setDigitalOutput(pin, false);
            }
          } else if (device is RgbLampDeviceEntity) {
            final pin = device.pin ?? 23;
            if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
              if (pin == 23) {
                Get.find<Esp32Service>().setAnalogOutput(23, 0);
                Get.find<Esp32Service>().setAnalogOutput(25, 0);
                Get.find<Esp32Service>().setAnalogOutput(26, 0);
              } else {
                Get.find<Esp32Service>().setAnalogOutput(pin, 0);
              }
            } else {
              Get.find<Esp32Service>().setDigitalOutput(pin, false);
            }
          } else if (device is VacuumDeviceEntity) {
            final pin = device.pin ?? 2;
            Get.find<Esp32Service>().setDigitalOutput(pin, false);
          } else if (device is AcDeviceEntity) {
            if (device.acIrCodes.irPower != null) {
              sendIrCommand(device.acIrCodes.irPower!);
            } else if (device.pin != null) {
              Get.find<Esp32Service>().setDigitalOutput(device.pin!, false);
            } else {
              Get.find<Esp32Service>().sendRawCommand(
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
      _persistDevices();
    }
  }

  void toggleDevice(String id) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final newIsOn = !device.isOn;

      devices[index] = device.copyWith(isOn: newIsOn);
      _persistDevices();

      // Matter Devices
      if (device.matterNodeId != null && Get.isRegistered<MatterService>()) {
        Get.find<MatterService>().toggleDevice(
          device.matterNodeId!,
          device.matterEndpointId ?? 1,
          newIsOn,
        );
      }
      // Trigger ESP32 if the device matches our GPIO mappings
      else if (Get.isRegistered<Esp32Service>()) {
        if (device is LampDeviceEntity) {
          final pin = device.pin ?? 2;
          if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
            Get.find<Esp32Service>().setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
          } else {
            Get.find<Esp32Service>().setDigitalOutput(pin, newIsOn);
          }
        } else if (device is RgbLampDeviceEntity) {
          final pin = device.pin ?? 23;
          if (pin == 22 || pin == 23 || pin == 25 || pin == 26) {
            if (pin == 23) {
              Get.find<Esp32Service>().setAnalogOutput(23, newIsOn ? (device.rgbR ?? 255) : 0);
              Get.find<Esp32Service>().setAnalogOutput(25, newIsOn ? (device.rgbG ?? 255) : 0);
              Get.find<Esp32Service>().setAnalogOutput(26, newIsOn ? (device.rgbB ?? 255) : 0);
            } else {
              Get.find<Esp32Service>().setAnalogOutput(pin, newIsOn ? (device.brightness ?? 255) : 0);
            }
          } else {
            Get.find<Esp32Service>().setDigitalOutput(pin, newIsOn);
          }
        } else if (device is VacuumDeviceEntity) {
          final pin = device.pin ?? 2;
          Get.find<Esp32Service>().setDigitalOutput(pin, newIsOn);
        } else if (device is AcDeviceEntity) {
          if (device.acIrCodes.irPower != null) {
            sendIrCommand(device.acIrCodes.irPower!);
          } else if (device.pin != null) {
            Get.find<Esp32Service>().setDigitalOutput(device.pin!, newIsOn);
          } else {
            Get.find<Esp32Service>().sendRawCommand(
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
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      if (device is DoorDeviceEntity) {
        final newIsLocked = !(device.isLocked ?? false);
        devices[index] = device.copyWith(isLocked: newIsLocked);
        _persistDevices();

        // Unlocked = Relay HIGH, Locked = Relay LOW
        if (Get.isRegistered<Esp32Service>()) {
          final pin = device.pin ?? 18;
          Get.find<Esp32Service>().setDigitalOutput(pin, !newIsLocked);
        }
      }
    }
  }

  void updateDeviceBrightness(String id, int brightness) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final newIsOn = brightness > 0;
      
      if (device is LampDeviceEntity) {
        devices[index] = device.copyWith(
          brightness: brightness,
          isOn: newIsOn,
        );
      } else if (device is RgbLampDeviceEntity) {
        devices[index] = device.copyWith(
          brightness: brightness,
          isOn: newIsOn,
        );
      }
      
      _persistDevices();

      // Matter Devices
      if (device.matterNodeId != null && Get.isRegistered<MatterService>()) {
        Get.find<MatterService>().setBrightness(
          device.matterNodeId!,
          device.matterEndpointId ?? 1,
          brightness,
        );
      }
      // Control ESP32 PWM lamp (pin 22)
      else if (Get.isRegistered<Esp32Service>()) {
        final pin = device.pin ?? 22;
        Get.find<Esp32Service>().setAnalogOutput(pin, brightness);
      }
    }
  }

  void updateDeviceColor(String id, int r, int g, int b) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      if (device is RgbLampDeviceEntity) {
        devices[index] = device.copyWith(rgbR: r, rgbG: g, rgbB: b);
        _persistDevices();

        // Matter Devices
        if (device.matterNodeId != null && Get.isRegistered<MatterService>()) {
          Get.find<MatterService>().setColor(
            device.matterNodeId!,
            device.matterEndpointId ?? 1,
            r,
            g,
            b,
          );
        }
        // Control ESP32 RGB Strip channels (R: 23, G: 25, B: 26)
        else if (Get.isRegistered<Esp32Service>()) {
          final esp = Get.find<Esp32Service>();
          final pin = device.pin ?? 23;
          if (pin == 23) {
            esp.setAnalogOutput(23, r);
            esp.setAnalogOutput(25, g);
            esp.setAnalogOutput(26, b);
          } else {
            esp.setAnalogOutput(pin, r);
            esp.setAnalogOutput(25, g);
            esp.setAnalogOutput(26, b);
          }
        }
      }
    }
  }

  void updateDeviceMarkerSize(String id, double width, double height, {bool persist = true}) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      devices[index] = devices[index].copyWith(
        markerWidth: width.clamp(0.05, 0.8),
        markerHeight: height.clamp(0.05, 0.8),
      );
      if (persist) {
        _persistDevices();
      }
    }
  }

  void _startAcTimer() {
    _acTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      for (int i = 0; i < devices.length; i++) {
        final d = devices[i];
        if (d.type == DeviceType.airConditioner && d.isOn) {
          devices[i] = d.copyWith(coolingTime: (d.coolingTime ?? 0) + 1);
        }
      }
    });
  }

  void _startEsp32Polling() {
    _espTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      if (!Get.isRegistered<Esp32Service>()) return;
      try {
        final response = await Get.find<Esp32Service>().getSensorData();
        if (response.isSuccess && response.data != null) {
          final data = response.data!;
          if (data['temperature'] != null) {
            temperature.value = '${data['temperature']}°';
          }
          if (data['humidity'] != null) {
            humidity.value = '${data['humidity']}%';
          }

          // Sync target AC temperature (primary AC: ac1)
          if (data['target_temperature'] != null) {
            final int targetTemp = data['target_temperature'];
            final acIndex = devices.indexWhere((d) => d.id == 'ac1');
            if (acIndex != -1 && devices[acIndex].temperature != targetTemp) {
              devices[acIndex] = devices[acIndex].copyWith(temperature: targetTemp);
            }
          }

          if (data['pins'] != null) {
            final pinsMap = data['pins'] as Map<String, dynamic>;

            for (var i = 0; i < devices.length; i++) {
              final device = devices[i];
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
                      devices[i] = device.copyWith(isLocked: isLocked);
                    }
                  } else if (device.type == DeviceType.lamp && pin == 22) {
                    final int brightness = val as int;
                    final bool isOn = brightness > 0;
                    if (device.brightness != brightness || device.isOn != isOn) {
                      devices[i] = device.copyWith(brightness: brightness, isOn: isOn);
                    }
                  } else if (device.type == DeviceType.rgb) {
                    final int rVal = pinsMap['pwm_rgb_r'] ?? device.rgbR ?? 0;
                    final int gVal = pinsMap['pwm_rgb_g'] ?? device.rgbG ?? 0;
                    final int bVal = pinsMap['pwm_rgb_b'] ?? device.rgbB ?? 0;
                    if (device.rgbR != rVal || device.rgbG != gVal || device.rgbB != bVal) {
                      devices[i] = device.copyWith(rgbR: rVal, rgbG: gVal, rgbB: bVal);
                    }
                  } else {
                    // Skip IR-controlled devices (AC) — their state is managed
                    // locally via IR commands, not GPIO pin readings.
                    if (device.type != DeviceType.airConditioner) {
                      final bool isOn = (val == 1);
                      if (device.isOn != isOn) {
                        devices[i] = device.copyWith(isOn: isOn);
                      }
                    }
                  }
                }
              } else {
                // Backward-compatible fallback for hardcoded default devices when pin is null
                if (device.id == 'lamp1' && pinsMap.containsKey('relay_1')) {
                  final int val = pinsMap['relay_1'];
                  if (device.isOn != (val == 1)) {
                    devices[i] = device.copyWith(isOn: val == 1);
                  }
                } else if (device.id == 'door1' && pinsMap.containsKey('relay_2')) {
                  final int val = pinsMap['relay_2'];
                  if ((device.isLocked ?? true) != (val == 0)) {
                    devices[i] = device.copyWith(isLocked: val == 0);
                  }
                }
                // ac1/airConditioner is IR-controlled — never sync isOn from relay pins.
              }           // end: else (pin == null)
            }             // end: for loop

          }
        }
      } catch (e) {
        // Silently catch background polling exceptions
      }
    });
  }
}
