part of 'dashboard_controller.dart';

// ==========================================
// IR Learning & Transmission Logic
// ==========================================

extension DashboardControllerIr on DashboardController {
  void updateAcTemperature(String id, int temp) async {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      if (device is AcDeviceEntity) {
        final oldTemp = device.temperature ?? 24;
        final newTemp = temp.clamp(16, 30);
        final delta = newTemp - oldTemp;

        devices[index] = device.copyWith(temperature: newTemp);
        _persistDevices();

        if (delta == 0 || !Get.isRegistered<Esp32Service>()) return;

        if (delta > 0 && device.acIrCodes.irTempUp != null) {
          await _sendIrRepeated(device.acIrCodes.irTempUp!, delta.abs());
        } else if (delta < 0 && device.acIrCodes.irTempDown != null) {
          await _sendIrRepeated(device.acIrCodes.irTempDown!, delta.abs());
        } else {
          Get.find<Esp32Service>().sendRawCommand(
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
  void setAcMode(String id, String mode) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final device = devices[index];
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
      Get.snackbar(
        mode,
        'لم يتم تسجيل زر هذا الوضع بعد.\nافتح إعدادات الجهاز وسجّل زر $mode.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Update mode label in UI
    devices[index] = device.copyWith(mode: mode);
    _persistDevices();

    // Send IR signal
    sendIrCommand(irCode);
  }

  /// Sends the same IR code [count] times sequentially (for temp up/down steps).
  /// Uses a shorter inter-signal gap of 220 ms which is safe for most remotes.
  Future<void> _sendIrRepeated(String jsonCodeString, int count) async {
    for (var i = 0; i < count; i++) {
      final ok = await sendIrCommand(
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

  Future<bool> _ensureHubReachable({required String actionLabel}) async {
    if (!Get.isRegistered<Esp32Service>()) {
      Get.snackbar(
        'خطأ / Error',
        'خدمة ESP32 غير مسجلة.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    }

    if (Get.isRegistered<SettingsController>()) {
      await Get.find<SettingsController>().checkHubConnection();
      if (!Get.find<SettingsController>().isHubReachable.value) {
        Get.snackbar(
          'لا اتصال / No Connection',
          'تعذر الوصول إلى ESP32. تحقق من IP في الإعدادات قبل $actionLabel.',
          backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
          colorText: Colors.white,
        );
        return false;
      }
      return true;
    }

    final ping = await Get.find<Esp32Service>().pingHub();
    if (!ping.isSuccess) {
      Get.snackbar(
        'لا اتصال / No Connection',
        ping.errorMessage ?? 'ESP32 غير متصل.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    }
    return true;
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

  Future<void> clearIrCode(String deviceId, String fieldKey) async {
    final index = devices.indexWhere((d) => d.id == deviceId);
    if (index == -1) return;

    final updated = _applyIrField(devices[index], fieldKey, null);
    if (updated == null) return;

    devices[index] = updated;
    _persistDevices();

    Get.snackbar(
      'تم الحذف / Deleted',
      'تم حذف إشارة الريموت المحفوظة.',
      backgroundColor: const Color(0xFF4C86FF).withValues(alpha: 0.85),
      colorText: Colors.white,
    );
  }

  /// Legacy convenience — kept for backward compat.
  void setAcAutoMode(String id) => setAcMode(id, 'Auto mode');

  Future<bool> learnAndSaveIrCode(String deviceId, String fieldKey) async {
    if (!await _ensureHubReachable(actionLabel: 'نسخ الإشارة')) {
      return false;
    }

    // Show animated countdown learning dialog
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1A1B2E),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        content: const IrLearningDialogContent(),
      ),
      barrierDismissible: false,
    );

    try {
      final response = await Get.find<Esp32Service>().learnIrCode();
      if (Get.isDialogOpen ?? false) Get.back();

      if (response.isSuccess && response.data != null) {
        final data = response.data!;

        if (!data.isValid) {
          Get.snackbar(
            'Error',
            'الإشارة المستلمة غير صالحة (قيمة أو bits فارغة).',
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
          );
          return false;
        }

        if (!data.verifyRoundtrip()) {
          return false;
        }

        final jsonCode = data.toJson();
        final index = devices.indexWhere((d) => d.id == deviceId);
        if (index != -1) {
          final updated = _applyIrField(devices[index], fieldKey, jsonCode);
          if (updated == null) return false;

          devices[index] = updated;
          _persistDevices();
          return true;
        }
      }

      Get.snackbar(
        'Error',
        response.errorMessage ?? 'لم يتم تلقي أي إشارة IR من الريموت.',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar(
        'خطأ / Error',
        'فشل عملية النسخ: $e',
        backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
        colorText: Colors.white,
      );
      return false;
    }
  }

  /// Sends a stored IR code to the ESP32.
  ///
  /// - [trackingKey]: ties this send to a UI loading indicator.
  /// - [showFeedback]: whether to show snackbars on success/failure.
  /// - [allowRetry]: if true, automatically retries once on failure (default true).
  Future<bool> sendIrCommand(
    String jsonCodeString, {
    String? trackingKey,
    bool showFeedback = true,
    bool allowRetry = true,
  }) async {
    // ── Decode early so we never send garbage to the ESP32 ────────────────
    final IrCodeEntity irCode;
    try {
      irCode = IrCodeEntity.fromJson(jsonCodeString);
    } catch (_) {
      if (showFeedback) {
        _showIrSnackbar(
          title: 'Invalid Code',
          message: 'Stored IR code is corrupted or unreadable.',
          isError: true,
        );
      }
      return false;
    }

    if (!irCode.isValid) {
      if (showFeedback) {
        _showIrSnackbar(
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

    final bool isLocalConnected = Get.isRegistered<Esp32Service>() && Get.find<Esp32Service>().isConnected.value;

    if (!isLocalConnected) {
      if (Get.isRegistered<FirebaseService>()) {
        debugPrint('[IR] Local WebSocket offline. Falling back to Firebase cloud channel...');
        if (showFeedback) {
          _showIrSnackbar(
            title: 'إرسال عبر السحاب... / Sending via Cloud...',
            message: 'الاتصال المحلي غير متاح، يتم الإرسال عبر Firebase.',
            isError: false,
          );
        }
        try {
          await Get.find<FirebaseService>().sendIrCommand(
            irCode.protocol.name.toUpperCase(),
            irCode.value,
          );
          if (showFeedback) {
            _showIrSnackbar(
              title: 'تم الإرسال للسحاب ✓ / Sent to Cloud',
              message: 'تم إرسال الأمر بنجاح إلى Firebase.',
              isError: false,
            );
          }
          return true;
        } catch (e) {
          debugPrint('[IR] Failed sending via Firebase: $e');
          if (showFeedback) {
            _showIrSnackbar(
              title: 'فشل الإرسال السحابي / Cloud Send Failed',
              message: e.toString(),
              isError: true,
            );
          }
          return false;
        }
      } else {
        if (!await _ensureHubReachable(actionLabel: 'IR Send')) {
          return false;
        }
      }
    }

    if (trackingKey != null) {
      sendingIrKeys.add(trackingKey);
      sendingIrKeys.refresh();
    }

    _irBusy = true;
    try {
      EspResponse<bool> response = await Get.find<Esp32Service>().sendIrCode(irCode);

      // ── Single automatic retry on transient failure ───────────────────
      if (!response.isSuccess && allowRetry) {
        debugPrint('[IR] First attempt failed — retrying after 150 ms...');
        await Future.delayed(const Duration(milliseconds: 150));
        response = await Get.find<Esp32Service>().sendIrCode(irCode);
      }

      if (response.isSuccess) {
        if (showFeedback) {
          _showIrSnackbar(
            title: 'Signal Sent ✓',
            message: '${irCode.protocol.name.toUpperCase()} · ${irCode.bits} bits',
            isError: false,
          );
        }
        return true;
      }

      if (showFeedback) {
        _showIrSnackbar(
          title: 'Send Failed',
          message: response.errorMessage ?? 'ESP32 rejected the IR payload.',
          isError: true,
        );
      }
      debugPrint('[IR] Send failed: ${response.errorMessage}');
      return false;
    } catch (e) {
      if (showFeedback) {
        _showIrSnackbar(
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
        sendingIrKeys.remove(trackingKey);
        sendingIrKeys.refresh();
      }
    }
  }

  /// Shows a compact IR-themed snackbar with colour-coded result.
  void _showIrSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError
          ? Colors.redAccent.withValues(alpha: 0.90)
          : const Color(0xFF1E3A5F),
      colorText: Colors.white,
      icon: Icon(
        isError ? Icons.wifi_tethering_error_rounded : Icons.wifi_tethering_rounded,
        color: isError ? Colors.white : Colors.cyanAccent,
        size: 22,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      borderRadius: 14,
      duration: Duration(seconds: isError ? 3 : 2),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
    );
  }
}
