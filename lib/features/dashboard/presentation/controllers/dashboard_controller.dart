import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/matter_service.dart';
import 'package:smart_home/features/device/data/datasources/device_local_datasource.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/room/domain/entities/room_entity.dart';
import 'package:smart_home/features/room/data/datasources/room_local_datasource.dart';
import 'package:smart_home/features/room/presentation/controllers/room_placement_controller.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class DashboardController extends GetxController {
  // Observables
  var rooms = <RoomEntity>[].obs;
  var devices = <DeviceEntity>[].obs;
  var currentNavigationIndex = 0.obs;
  
  // Environment Stats for the selected room
  var humidity = '50%'.obs;
  var airflow = '80%'.obs;
  var temperature = '27°'.obs;
  var powerUsage = '360W'.obs;

  // Live Weather Observables
  var weatherLocation = 'Loading...'.obs;
  var weatherTemp = '--°C'.obs;
  var weatherCondition = 'Fetching...'.obs;
  var weatherDate = ''.obs;
  var weatherSuggestion = 'Optimizing settings...'.obs;
  var isWeatherLoading = true.obs;
  var isDay = 1.obs; // 1 = Day, 0 = Night
  var weatherCode = 0.obs;

  /// Tracks in-flight IR sends per "deviceId::fieldKey" for UI loading states.
  var sendingIrKeys = <String>{}.obs;

  /// Mutex flag — only one IR HTTP request at a time to prevent ESP32 overlap.
  bool _irBusy = false;

  final Dio _dio = Dio();
  Timer? _acTimer;
  Timer? _espTimer;
  final DeviceLocalDatasource _datasource = DeviceLocalDatasource();
  final RoomLocalDatasource _roomDatasource = RoomLocalDatasource();

  RoomEntity? get activeRoom => rooms.firstWhereOrNull((r) => r.isActive);

  void changeTab(int index) {
    currentNavigationIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    _loadData();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      fetchLiveWeather();
      _startAcTimer();
      _startEsp32Polling();
    } else {
      isWeatherLoading.value = false;
      weatherLocation.value = 'Mock City';
      weatherTemp.value = '25°C';
      weatherCondition.value = 'Sunny';
    }
  }

  @override
  void onClose() {
    _acTimer?.cancel();
    _espTimer?.cancel();
    super.onClose();
  }

  void _loadData() {
    // Prefer Hive-persisted rooms; fall back to mock only on first launch
    if (_roomDatasource.hasData) {
      rooms.value = _roomDatasource.loadRooms();
    } else {
      rooms.value = [
        const RoomEntity(id: '1', name: 'Bedroom', deviceCount: 3),
        const RoomEntity(id: '2', name: 'Kitchen', deviceCount: 2),
        const RoomEntity(id: '3', name: 'Living room', deviceCount: 5, isActive: true),
        const RoomEntity(id: '4', name: 'Bathroom', deviceCount: 3),
      ];
      _persistRooms();
    }

    // Prefer Hive-persisted devices; fall back to mock only on first launch
    if (_datasource.hasData) {
      devices.value = _datasource.loadDevices();
    } else {
      _loadMockData();
      _persistDevices(); // seed Hive with the initial mock data
    }
  }

  void _persistRooms() {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _roomDatasource.saveRooms(rooms.toList());
    }
  }

  /// Save current devices snapshot to Hive.
  void _persistDevices() {
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      _datasource.saveDevices(devices.toList());
    }
  }

  /// Seeds the initial mock devices on the very first launch.
  void _loadMockData() {
    devices.value = [
      const DeviceEntity(
        id: 'door1',
        name: 'Smart Door',
        type: DeviceType.door,
        isLocked: true,
        positionX: 0.8,
        positionY: 0.55,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'vac1',
        name: 'Robot vacuum cleaner',
        type: DeviceType.vacuum,
        isOn: true,
        batteryLevel: 75,
        areaCleaned: 82,
        cleaningTime: 32,
        filterStatus: 72,
        nextCleaning: '10:30 AM',
        positionX: 0.35,
        positionY: 0.75,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'ac1',
        name: 'Dining Area AC',
        type: DeviceType.airConditioner,
        isOn: true,
        temperature: 21,
        mode: 'Auto mode',
        coolingTime: 35,
        positionX: 0.25,
        positionY: 0.35,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'ac2',
        name: 'TV Area AC',
        type: DeviceType.airConditioner,
        isOn: false,
        temperature: 24,
        mode: 'Eco mode',
        coolingTime: 10,
        positionX: 0.72,
        positionY: 0.32,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'lamp1',
        name: 'Smart Lamp',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 62,
        positionX: 0.52,
        positionY: 0.18,
        roomId: '3',
      ),
      const DeviceEntity(
        id: 'rgb1',
        name: 'RGB Strip',
        type: DeviceType.rgb,
        isOn: true,
        rgbR: 98,
        rgbG: 52,
        rgbB: 234,
        brightness: 80,
        positionX: 0.65,
        positionY: 0.65,
        roomId: '3',
      ),
      // Bedroom (ID '1')
      const DeviceEntity(
        id: 'ac_bed',
        name: 'Bedroom AC',
        type: DeviceType.airConditioner,
        isOn: true,
        temperature: 22,
        mode: 'Quiet mode',
        coolingTime: 12,
        positionX: 0.3,
        positionY: 0.3,
        roomId: '1',
      ),
      const DeviceEntity(
        id: 'lamp_bed',
        name: 'Bedside Lamp',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 40,
        positionX: 0.7,
        positionY: 0.4,
        roomId: '1',
      ),
      // Kitchen (ID '2')
      const DeviceEntity(
        id: 'rgb_kitchen',
        name: 'Kitchen LED Strip',
        type: DeviceType.rgb,
        isOn: true,
        rgbR: 255,
        rgbG: 180,
        rgbB: 0,
        brightness: 75,
        positionX: 0.45,
        positionY: 0.25,
        roomId: '2',
      ),
      const DeviceEntity(
        id: 'vac_kitchen',
        name: 'Kitchen Vacuum',
        type: DeviceType.vacuum,
        isOn: false,
        batteryLevel: 90,
        positionX: 0.2,
        positionY: 0.8,
        roomId: '2',
      ),
      // Bathroom (ID '4')
      const DeviceEntity(
        id: 'lamp_bath',
        name: 'Mirror Light',
        type: DeviceType.lamp,
        isOn: true,
        brightness: 80,
        positionX: 0.5,
        positionY: 0.25,
        roomId: '4',
      ),
    ];
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
        if (device.type == DeviceType.lamp) {
          final pin = device.pin ?? 2;
          Get.find<Esp32Service>().setDigitalOutput(pin, newIsOn);
        } else if (device.type == DeviceType.airConditioner) {
          if (device.irPower != null) {
            sendIrCommand(device.irPower!);
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

  void selectRoom(String id) {
    rooms.value = rooms.map((r) => r.copyWith(isActive: r.id == id)).toList();
    _persistRooms();
    if (Get.isRegistered<RoomPlacementController>()) {
      Get.find<RoomPlacementController>().selectDevice(null);
    }
  }

  void addRoom(RoomEntity room) {
    rooms.add(room);
    _persistRooms();
  }

  void updateRoom(RoomEntity room) {
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index != -1) {
      rooms[index] = room;
      _persistRooms();
    }
  }

  void deleteRoom(String id) {
    rooms.removeWhere((r) => r.id == id);
    // If the active room is deleted, select the first remaining room
    final hasActive = rooms.any((r) => r.isActive);
    if (!hasActive && rooms.isNotEmpty) {
      rooms[0] = rooms[0].copyWith(isActive: true);
    }
    _persistRooms();
  }

  void updateAcTemperature(String id, int temp) async {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final oldTemp = device.temperature ?? 24;
      final newTemp = temp.clamp(16, 30);
      final delta = newTemp - oldTemp;

      devices[index] = device.copyWith(temperature: newTemp);
      _persistDevices();

      if (delta == 0 || !Get.isRegistered<Esp32Service>()) return;

      if (delta > 0 && device.irTempUp != null) {
        await _sendIrRepeated(device.irTempUp!, delta.abs());
      } else if (delta < 0 && device.irTempDown != null) {
        await _sendIrRepeated(device.irTempDown!, delta.abs());
      } else {
        Get.find<Esp32Service>().sendRawCommand(
          'control/ac',
          method: 'POST',
          data: {'target_temp': newTemp},
        );
      }
    }
  }

  /// Activates the given AC [mode]: sends the learned IR signal and
  /// updates the device [mode] field to reflect it in the UI.
  void setAcMode(String id, String mode) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index == -1) return;

    final device = devices[index];

    // Resolve which stored IR code corresponds to the requested mode
    final String? irCode = switch (mode) {
      'Auto mode' => device.irAuto,
      'Cool mode' => device.irCool,
      'Heat mode' => device.irHeat,
      'Eco mode'  => device.irEco,
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
    switch (fieldKey) {
      case 'irPower':
        return device.copyWith(irPower: jsonCode);
      case 'irTempUp':
        return device.copyWith(irTempUp: jsonCode);
      case 'irTempDown':
        return device.copyWith(irTempDown: jsonCode);
      case 'irAuto':
        return device.copyWith(irAuto: jsonCode);
      case 'irCool':
        return device.copyWith(irCool: jsonCode);
      case 'irHeat':
        return device.copyWith(irHeat: jsonCode);
      case 'irEco':
        return device.copyWith(irEco: jsonCode);
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

  void updateDeviceBrightness(String id, int brightness) {
    final index = devices.indexWhere((d) => d.id == id);
    if (index != -1) {
      final device = devices[index];
      final newIsOn = brightness > 0;
      devices[index] = device.copyWith(
        brightness: brightness,
        isOn: newIsOn,
      );
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
        content: const _IrLearningDialogContent(),
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
          Get.snackbar(
            'Error',
            'فشل التحقق من سلامة بيانات IR قبل الحفظ.',
            backgroundColor: Colors.redAccent.withValues(alpha: 0.85),
            colorText: Colors.white,
          );
          return false;
        }

        final jsonCode = data.toJson();
        final index = devices.indexWhere((d) => d.id == deviceId);
        if (index != -1) {
          final updated = _applyIrField(devices[index], fieldKey, jsonCode);
          if (updated == null) return false;

          devices[index] = updated;
          _persistDevices();

          Get.snackbar(
            ' Success',
            'تم نسخ زر الريموت وحفظه كـ ${data.protocol.name} (${data.bits} bits)',
            backgroundColor: const Color(0xFF4C86FF).withValues(alpha: 0.85),
            colorText: Colors.white,
          );
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

    if (!await _ensureHubReachable(actionLabel: 'IR Send')) {
      return false;
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

  // Fetch real weather and geolocation details
  Future<void> fetchLiveWeather() async {
    isWeatherLoading.value = true;
    weatherDate.value = _getFormattedDate();

    try {
      // Step 1: Geolocation using ipapi.co
      final geoResponse = await _dio.get('https://ipapi.co/json/');
      if (geoResponse.statusCode == 200 && geoResponse.data != null) {
        final data = geoResponse.data;
        final city = data['city'] ?? 'Cairo';
        final country = data['country_name'] ?? 'Egypt';
        final double lat = (data['latitude'] as num?)?.toDouble() ?? 30.0507;
        final double lon = (data['longitude'] as num?)?.toDouble() ?? 31.2489;

        weatherLocation.value = '$city, $country';

        // Step 2: Fetch weather details using Open-Meteo
        final weatherResponse = await _dio.get(
          'https://api.open-meteo.com/v1/forecast',
          queryParameters: {
            'latitude': lat,
            'longitude': lon,
            'current_weather': true,
          },
        );

        if (weatherResponse.statusCode == 200 && weatherResponse.data != null) {
          final weatherData = weatherResponse.data['current_weather'];
          if (weatherData != null) {
            final double temp = (weatherData['temperature'] as num?)?.toDouble() ?? 27.0;
            final int code = (weatherData['weathercode'] as num?)?.toInt() ?? 0;
            final int dayFlag = (weatherData['is_day'] as num?)?.toInt() ?? 1;

            weatherTemp.value = '${temp.round()}°C';
            weatherCode.value = code;
            isDay.value = dayFlag;
            weatherCondition.value = _mapWeatherCode(code, dayFlag);
            weatherSuggestion.value = _generateSuggestion(temp, code);
          }
        }
      }
    } catch (e) {
      // Fallback gracefully on network error
      weatherLocation.value = 'Jakarta, Indonesia';
      weatherTemp.value = '27°C';
      weatherCondition.value = 'Clear Evening';
      isDay.value = 0;
      weatherCode.value = 0;
      weatherSuggestion.value = "Activate 'Relax Mode', dim lights, soft music, and lower thermostat.";
    } finally {
      isWeatherLoading.value = false;
    }
  }

  // Format date to: weekday, month day
  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final weekday = weekdays[now.weekday - 1];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  // Map WMO codes to weather conditions
  String _mapWeatherCode(int code, int dayFlag) {
    final isNight = dayFlag == 0;
    switch (code) {
      case 0:
        return isNight ? 'Clear Evening' : 'Sunny Day';
      case 1:
      case 2:
      case 3:
        return 'Partly Cloudy';
      case 45:
      case 48:
        return 'Foggy';
      case 51:
      case 53:
      case 55:
        return 'Light Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rainy';
      case 71:
      case 73:
      case 75:
        return 'Snowy';
      case 80:
      case 81:
      case 82:
        return 'Rain Showers';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return isNight ? 'Clear Evening' : 'Clear Day';
    }
  }

  // Generate dynamic contextual suggestion
  String _generateSuggestion(double temp, int code) {
    if (code >= 50 && code <= 99) {
      return "Rainy weather. Perfect time to stay warm, dim the lights and play cozy music.";
    }
    if (temp > 30) {
      return "It's hot outside. Lowering the AC to 22°C and activating air circulation is recommended.";
    }
    if (temp < 18) {
      return "Cold outside. Activating heating mode on the AC and setting comfortable lighting.";
    }
    return "Weather is pleasant. Open windows for fresh air or keep lights dim for a relaxed evening.";
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

class _IrLearningDialogContent extends StatefulWidget {
  const _IrLearningDialogContent();

  @override
  State<_IrLearningDialogContent> createState() => _IrLearningDialogContentState();
}

class _IrLearningDialogContentState extends State<_IrLearningDialogContent> {
  int _countdown = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
          } else {
            _timer?.cancel();
            if (Get.isDialogOpen ?? false) {
              Get.back();
            }
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Animated circular countdown
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _countdown / 10.0,
                strokeWidth: 4,
                color: const Color(0xFF4C86FF),
                backgroundColor: Colors.white10,
              ),
              Text(
                '$_countdown',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings_remote_rounded,
                color: Color(0xFF4C86FF), size: 20),
            const SizedBox(width: 8),
            Text(
              'جاري الاستماع للريموت',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Point the remote at the ESP32 sensor and press the desired button',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13, height: 1.5),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'It will close automatically after 10 seconds if no signal is received',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.38), fontSize: 11),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

