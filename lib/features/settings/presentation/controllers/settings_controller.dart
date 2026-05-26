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

  // Available options
  final voiceAssistants = ['Alexa', 'Google Assistant', 'Siri', 'None'];
  final connectionModes = ['Zigbee', 'Wi-Fi', 'Bluetooth'];

  void updateUserName(String name) {
    if (name.isNotEmpty) {
      userName.value = name;
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
}
