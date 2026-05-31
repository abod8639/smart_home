import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/core/services/esp32_service.dart';

class SettingsController extends GetxController {
  static const _ipKey = 'hub_ip_address';

  // Profile settings
  var userName = 'Dexter'.obs;
  var userRole = 'Administrator'.obs;

  // Preferences settings
  var isCelsius = true.obs;
  var selectedVoiceAssistant = 'Google Assistant'.obs;
  var notificationsEnabled = true.obs;

  // Hub Connection & System settings
  var hubConnectionMode = 'Wi-Fi'.obs;
  var autoBackups = true.obs;
  var lockTimeout = 5.0.obs; // in minutes
  var ipAddress = '192.168.1.2'.obs;
  var isHubReachable = false.obs;
  var isCheckingHub = false.obs;

  // Google Home Integration settings
  var isGoogleLinked = false.obs;
  var googleEmail = 'dexter.smart.home@gmail.com'.obs;
  var isSyncing = false.obs;
  var lastSyncTime = 'Never'.obs;

  // Available options
  final voiceAssistants = ['Google Assistant', 'Alexa', 'Siri', 'None'];
  final connectionModes = ['Wi-Fi', 'Zigbee', 'Bluetooth'];

  @override
  void onInit() {
    super.onInit();
    _loadIpAddress();
  }

  Future<void> _loadIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString(_ipKey);
    if (savedIp != null && savedIp.isNotEmpty) {
      ipAddress.value = savedIp;
    }
    await checkHubConnection();
  }

  Future<void> checkHubConnection() async {
    if (!Get.isRegistered<Esp32Service>()) return;
    isCheckingHub.value = true;
    try {
      final result = await Get.find<Esp32Service>().pingHub();
      isHubReachable.value = result.isSuccess;
    } finally {
      isCheckingHub.value = false;
    }
  }

  void updateUserName(String name) {
    if (name.isNotEmpty) {
      userName.value = name;
    }
  }

  Future<void> updateIpAddress(String ip) async {
    if (ip.isEmpty) return;
    ipAddress.value = ip;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    await checkHubConnection();
  }

  void toggleTempUnit() {
    isCelsius.value = !isCelsius.value;
  }

  void selectVoiceAssistant(String assistant) {
    if (voiceAssistants.contains(assistant)) {
      selectedVoiceAssistant.value = assistant;
    }
  }

  void toggleNotifications() {
    notificationsEnabled.value = !notificationsEnabled.value;
  }

  void selectConnectionMode(String mode) {
    if (connectionModes.contains(mode)) {
      hubConnectionMode.value = mode;
    }
  }

  void toggleAutoBackups() {
    autoBackups.value = !autoBackups.value;
  }

  void updateLockTimeout(double value) {
    lockTimeout.value = value.clamp(1.0, 30.0);
  }

  void toggleGoogleLink() async {
    if (isGoogleLinked.value) {
      isGoogleLinked.value = false;
      lastSyncTime.value = 'Never';
    } else {
      isSyncing.value = true;
      await Future.delayed(const Duration(seconds: 1));
      isGoogleLinked.value = true;
      isSyncing.value = false;
      lastSyncTime.value = 'Just now';
    }
  }

  void syncGoogleDevices() async {
    if (!isGoogleLinked.value) return;
    isSyncing.value = true;
    await Future.delayed(const Duration(seconds: 1));
    isSyncing.value = false;
    final now = DateTime.now();
    final minutesStr = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    lastSyncTime.value = '$hour:$minutesStr $ampm';
  }
}
