// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member

part of 'dashboard_controller.dart';

// ==========================================
// IR Learning & Transmission Logic
// ==========================================

extension DashboardControllerIr on DashboardController {
  void updateAcTemperature(String id, int temp) async {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final newDevices = List<DeviceEntity>.from(state.devices);
      final device = newDevices[index];
      if (device is AcDeviceEntity) {
        final oldTemp = device.temperature ?? 24;
        final newTemp = temp.clamp(16, 30);
        final delta = newTemp - oldTemp;

        newDevices[index] = device.copyWith(temperature: newTemp);
        state = state.copyWith(devices: newDevices);
        _persistDevices();

        if (delta == 0) return;

        if (delta > 0 && device.acIrCodes.irTempUp != null) {
          await _sendIrRepeated(null, device.acIrCodes.irTempUp!, delta.abs());
        } else if (delta < 0 && device.acIrCodes.irTempDown != null) {
          await _sendIrRepeated(null, device.acIrCodes.irTempDown!, delta.abs());
        } else {
          final esp32 = ref.read(esp32ServiceProvider.notifier);
          esp32.sendRawCommand(
            'control/ac',
            method: 'POST',
            data: {'target_temp': newTemp},
          );
        }
      }
    }
  }

  /// Activates the given AC [mode]: sends the learned IR signal and
  /// updates the device [mode] field to reflect it in the UI.
  void setAcMode(BuildContext context, String id, String mode) {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final newDevices = List<DeviceEntity>.from(state.devices);
    final device = newDevices[index];
    if (device is! AcDeviceEntity) return;

    // Resolve which stored IR code corresponds to the requested mode
    final String? irCode = switch (mode) {
      'Auto mode' => device.acIrCodes.irAuto,
      'Cool mode' => device.acIrCodes.irCool,
      'Heat mode' => device.acIrCodes.irHeat,
      'Eco mode'  => device.acIrCodes.irEco,
      'Dry mode'  => device.acIrCodes.irDry,
      _           => null,
    };

    if (irCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$mode hasn\'t been set yet.'),
          backgroundColor: const Color(0xFF1E293B),
        ),
      );
      return;
    }

    // Update mode label in UI and turn the device ON
    newDevices[index] = device.copyWith(mode: mode, isOn: true);
    state = state.copyWith(devices: newDevices);
    _persistDevices();

    // Send IR signal
    sendIrCommand(context, irCode);
  }

  /// Sends the same IR code [count] times sequentially (for temp up/down steps).
  /// Uses a shorter inter-signal gap of 220 ms which is safe for most remotes.
  Future<void> _sendIrRepeated(BuildContext? context, String jsonCodeString, int count) async {
    for (var i = 0; i < count; i++) {
      final ok = await sendIrCommand(
        // ignore: use_build_context_synchronously
        context,
        jsonCodeString,
        showFeedback: false,   // suppress per-step snackbars
        allowRetry: false,     // no retry in repeated mode — just skip
      );
      if (!ok) break;
      if (i < count - 1) {
        await Future.delayed(const Duration(milliseconds: 220));
      }
    }
  }

  String irTrackingKey(String deviceId, String fieldKey) => '$deviceId::$fieldKey';

  Future<bool> _ensureHubReachable(BuildContext? context, {required String actionLabel}) async {
    try {
      final settings = ref.read(settingsControllerProvider.notifier);
      await settings.checkHubConnection();
      if (!settings.state.isHubReachable) {
        if (context == null || !context.mounted) return false;
        print("Unable to reach ESP32. Check the IP address in Settings before $actionLabel.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to reach ESP32. Check the IP address in Settings before $actionLabel.'),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          ),
        );
        return false;
      }
      return true;
    } catch (_) {
      final esp32 = ref.read(esp32ServiceProvider.notifier);
      final ping = await esp32.pingHub();
      if (!ping.isSuccess) {
        if (context == null || !context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ping.errorMessage ?? 'ESP32 is not connected.'),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          ),
        );
      }
      return ping.isSuccess;
    }
  }

  DeviceEntity? _applyIrField(DeviceEntity device, String fieldKey, String? jsonCode) {
    if (device is! AcDeviceEntity) return null;
    final acIrCodes = device.acIrCodes;
    switch (fieldKey) {
      case 'irPower':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irPower: jsonCode));
      case 'irTempUp':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irTempUp: jsonCode));
      case 'irTempDown':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irTempDown: jsonCode));
      case 'irAuto':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irAuto: jsonCode));
      case 'irCool':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irCool: jsonCode));
      case 'irHeat':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irHeat: jsonCode));
      case 'irEco':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irEco: jsonCode));
      case 'irDry':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irDry: jsonCode));
      case 'irFanQuiet':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irFanQuiet: jsonCode));
      case 'irFanLow':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irFanLow: jsonCode));
      case 'irFanMed':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irFanMed: jsonCode));
      case 'irFanHigh':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irFanHigh: jsonCode));
      case 'irFanAuto':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irFanAuto: jsonCode));
      case 'irSwingV':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irSwingV: jsonCode));
      case 'irSwingH':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irSwingH: jsonCode));
      case 'irPlasmacluster':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irPlasmacluster: jsonCode));
      case 'irSuperJet':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irSuperJet: jsonCode));
      case 'irCoanda':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irCoanda: jsonCode));
      case 'irMyArea':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irMyArea: jsonCode));
      case 'irDisplay':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irDisplay: jsonCode));
      case 'irClean':
        return device.copyWith(acIrCodes: acIrCodes.copyWith(irClean: jsonCode));
      default:
        return null;
    }
  }

  Future<void> clearIrCode(BuildContext context, String deviceId, String fieldKey) async {
    final index = state.devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return;

    final newDevices = List<DeviceEntity>.from(state.devices);
    final updated = _applyIrField(newDevices[index], fieldKey, null);
    if (updated == null) return;

    newDevices[index] = updated;
    state = state.copyWith(devices: newDevices);
    _persistDevices();

    ref.read(firebaseServiceProvider.notifier).deleteIrCode(deviceId, fieldKey);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('IR code deleted successfully.'),
        backgroundColor: const Color(0xFF4C86FF).withValues(alpha: 0.85),
      ),
    );
  }

  /// Legacy convenience — kept for backward compat.
  void setAcAutoMode(BuildContext context, String id) => setAcMode(context, id, 'Auto mode');

  Future<bool> learnAndSaveIrCode(BuildContext context, String deviceId, String fieldKey) async {
    if (!await _ensureHubReachable(context, actionLabel: 'Learning')) {
      return false;
    }

    if (!context.mounted) return false;

    // Show animated countdown learning dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1B2E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: const IrLearningDialogContent(),
      ),
    );

    try {
      final esp32 = ref.read(esp32ServiceProvider.notifier);
      final response = await esp32.learnIrCode();
      
      if (context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop(); // dismiss dialog
        }

        if (response.isSuccess && response.data != null) {
          final data = response.data!;

          if (!data.isValid) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('The received signal is invalid.'),
                backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
              ),
            );
            return false;
          }

          final model = IrCodeModel.fromEntity(data);
          if (!model.verifyRoundtrip()) {
            return false;
          }

          final jsonCode = model.toJson();
          final index = state.devices.indexWhere((d) => d.id == deviceId);
          if (index != -1) {
            final newDevices = List<DeviceEntity>.from(state.devices);
            final updated = _applyIrField(newDevices[index], fieldKey, jsonCode);
            if (updated == null) return false;

            newDevices[index] = updated;
            state = state.copyWith(devices: newDevices);
            _persistDevices();

            ref.read(firebaseServiceProvider.notifier).saveIrCode(deviceId, fieldKey, jsonCode);

            return true;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.errorMessage ?? 'No IR signal was received from the remote.'),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          ),
        );
      }
      return false;
    } catch (e) {
      if (context.mounted) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Learning failed: $e'),
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          ),
        );
      }
      return false;
    }
  }

  /// Sends a stored IR code to the ESP32.
  ///
  /// - [trackingKey]: ties this send to a UI loading indicator.
  /// - [showFeedback]: whether to show snackbars on success/failure.
  /// - [allowRetry]: if true, automatically retries once on failure (default true).
  Future<bool> sendIrCommand(
    BuildContext? context,
    String jsonCodeString, {
    String? trackingKey,
    bool showFeedback = true,
    bool allowRetry = true,
  }) async {
    // ── Decode early so we never send garbage to the ESP32 ────────────────
    final IrCodeEntity irCode;
    try {
      irCode = IrCodeModel.fromJson(jsonCodeString);
    } catch (_) {
      if (showFeedback && context != null && context.mounted) {
        _showIrSnackbar(
          context: context,
          title: 'Invalid Code',
          message: 'Stored IR code is corrupted or unreadable.',
          isError: true,
        );
      }
      return false;
    }

    if (!irCode.isValid) {
      if (showFeedback && context != null && context.mounted) {
        _showIrSnackbar(
          context: context,
          title: 'Invalid Code',
          message: 'IR code is missing protocol or bit data.',
          isError: true,
        );
      }
      return false;
    }

    // ── Wait if another IR send is already in progress (max 2 s) ─────────
    int waited = 0;
    while (_irBusy && waited < 2000) {
      await Future.delayed(const Duration(milliseconds: 50));
      waited += 50;
    }

    await ref.read(esp32ServiceProvider.notifier).waitForConnection();
    final bool isLocalConnected = ref.read(isConnectedProvider);

    if (!isLocalConnected) {
      final firebaseService = ref.read(firebaseServiceProvider.notifier);
      debugPrint('[IR] Local WebSocket offline. Falling back to Firebase cloud channel...');
      if (showFeedback && context != null && context.mounted) {
        _showIrSnackbar(
          context: context,
          title: 'Sending via Cloud...',
          message: 'Local connection is not available, sending via Firebase.',
          isError: false,
        );
      }
      try {
        await firebaseService.sendIrCommand(
          irCode.protocol.name.toUpperCase(),
          irCode.value,
        );
        if (showFeedback && context != null && context.mounted) {
          _showIrSnackbar(
            context: context,
            title: 'Sent to Cloud',
            message: 'Command was sent to Firebase successfully.',
            isError: false,
          );
        }
        return true;
      } catch (e) {
        debugPrint('[IR] Failed sending via Firebase: $e');
        if (showFeedback && context != null && context.mounted) {
          _showIrSnackbar(
            context: context,
            title: 'Cloud Send Failed',
            message: e.toString(),
            isError: true,
          );
        }
        return false;
      }
    }

    if (trackingKey != null) {
      final newKeys = Set<String>.from(state.sendingIrKeys)..add(trackingKey);
      state = state.copyWith(sendingIrKeys: newKeys);
    }

    _irBusy = true;
    try {
      final esp32 = ref.read(esp32ServiceProvider.notifier);
      EspResponse<bool> response = await esp32.sendIrCode(irCode);

      // ── Single automatic retry on transient failure ───────────────────
      if (!response.isSuccess && allowRetry) {
        debugPrint('[IR] First attempt failed — retrying after 150 ms...');
        await Future.delayed(const Duration(milliseconds: 150));
        response = await esp32.sendIrCode(irCode);
      }

      if (response.isSuccess) {
        if (showFeedback && context != null && context.mounted) {
          _showIrSnackbar(
            context: context,
            title: 'Signal Sent ✓',
            message: '${irCode.protocol.name.toUpperCase()} · ${irCode.bits} bits',
            isError: false,
          );
        }
        return true;
      }

      if (showFeedback && context != null && context.mounted) {
        _showIrSnackbar(
          context: context,
          title: 'Send Failed',
          message: response.errorMessage ?? 'ESP32 rejected the IR payload.',
          isError: true,
        );
      }
      debugPrint('[IR] Send failed: ${response.errorMessage}');
      return false;
    } catch (e) {
      if (showFeedback && context != null && context.mounted) {
        _showIrSnackbar(
          context: context,
          title: 'Send Error',
          message: e.toString(),
          isError: true,
        );
      }
      debugPrint('[IR] Exception during send: $e');
      return false;
    } finally {
      _irBusy = false;
      if (trackingKey != null) {
        final newKeys = Set<String>.from(state.sendingIrKeys)..remove(trackingKey);
        state = state.copyWith(sendingIrKeys: newKeys);
      }
    }
  }

  /// Shows a compact IR-themed snackbar with colour-coded result.
  void _showIrSnackbar({
    required BuildContext context,
    required String title,
    required String message,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(message),
          ],
        ),
        backgroundColor: isError
            ? Colors.redAccent.withValues(alpha: 0.90)
            : const Color(0xFF1E3A5F),
        duration: Duration(seconds: isError ? 3 : 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  Future<void> setAcSleepTimer(BuildContext context, String id, Duration duration) async {
    final index = state.devices.indexWhere((d) => d.id == id);
    if (index == -1) return;
    
    final newDevices = List<DeviceEntity>.from(state.devices);
    final device = newDevices[index];
    if (device is! AcDeviceEntity) return;

    final esp32 = ref.read(esp32ServiceProvider.notifier);

    if (duration.inSeconds == 0) {
      // Cancel timer
      newDevices[index] = device.copyWith(sleepTimerRemaining: 0);
      state = state.copyWith(devices: newDevices);
      _persistDevices();

      await esp32.sendRawCommand(
        'control/ac/timer',
        method: 'POST',
        data: {
          'seconds': 0,
        },
      );
      return;
    }

    final String? irPowerCode = device.acIrCodes.irPower;
    if (irPowerCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Power button hasn\'t been learned yet.'),
          backgroundColor: Color(0xFF1E293B),
        ),
      );
      return;
    }

    final irCode = IrCodeModel.fromJson(irPowerCode);

    // Optimistically update UI
    newDevices[index] = device.copyWith(sleepTimerRemaining: duration.inSeconds);
    state = state.copyWith(devices: newDevices);
    _persistDevices();

    await esp32.sendRawCommand(
      'control/ac/timer',
      method: 'POST',
      data: {
        'seconds': duration.inSeconds,
        'ir_code': irCode.toEsp32Payload(),
      },
    );
  }
}
