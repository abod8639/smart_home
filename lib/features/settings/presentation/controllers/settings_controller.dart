import 'package:get/get.dart';

class SettingsController extends GetxController {
  // Profile settings
  var userName = 'Dexter'.obs;
  var userRole = 'Administrator'.obs;

  // Preferences settings
  var isCelsius = true.obs;
  var selectedVoiceAssistant = 'Alexa'.obs;
  var notificationsEnabled = true.obs;

  // Hub Connection & System settings
  var hubConnectionMode = 'Zigbee'.obs;
  var autoBackups = true.obs;
  var lockTimeout = 5.0.obs; // in minutes
  var ipAddress = '192.168.1.2'.obs;

  // Google Home Integration settings
  var isGoogleLinked = false.obs;
  var googleEmail = 'dexter.smart.home@gmail.com'.obs;
  var isSyncing = false.obs;
  var lastSyncTime = 'Never'.obs;

  // Available options
  final voiceAssistants = ['Alexa', 'Google Assistant', 'Siri', 'None'];
  final connectionModes = ['Zigbee', 'Wi-Fi', 'Bluetooth'];

  void updateUserName(String name) {
    if (name.isNotEmpty) {
      userName.value = name;
    }
  }

  void updateIpAddress(String ip) {
    if (ip.isNotEmpty) {
      ipAddress.value = ip;
    }
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
