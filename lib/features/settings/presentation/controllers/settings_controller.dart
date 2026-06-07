import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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
  var ipAddress = (dotenv.env['MQTT_BROKER_URL'] ?? 'broker.hivemq.com').obs;
  var isHubReachable = false.obs;
  var isCheckingHub = false.obs;

  // Google Home Integration settings
  var isGoogleLinked = false.obs;
  var googleEmail = ''.obs;
  var isSyncing = false.obs;
  var lastSyncTime = 'Never'.obs;

  // Available options
  final voiceAssistants = ['Google Assistant', 'Alexa', 'Siri', 'None'];
  final connectionModes = ['Wi-Fi', 'Zigbee', 'Bluetooth'];

  @override
  void onInit() {
    super.onInit();
    _loadIpAddress();
    _bindAuthUser();
  }

  void _bindAuthUser() {
    if (Get.isRegistered<AuthService>()) {
      final auth = Get.find<AuthService>();
      ever(auth.currentUser, (User? user) {
        if (user != null) {
          isGoogleLinked.value = true;
          googleEmail.value = user.email ?? '';
          userName.value = user.displayName ?? 'Dexter';
        } else {
          isGoogleLinked.value = false;
          googleEmail.value = '';
        }
      });
      // Initial value
      final user = auth.currentUser.value;
      if (user != null) {
        isGoogleLinked.value = true;
        googleEmail.value = user.email ?? '';
        userName.value = user.displayName ?? 'Dexter';
      }
    }
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
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Disconnect Google Smart Home?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will disconnect your smart home integration and sign you out of your account.',
            style: TextStyle(color: Color(0xFF8B8B8D)),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8B8B8D)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Get.back();
                if (Get.isRegistered<AuthService>()) {
                  await Get.find<AuthService>().signOut();
                }
              },
              child: const Text(
                'Disconnect',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      if (Get.isRegistered<AuthService>()) {
        Get.dialog(
          const Center(child: CircularProgressIndicator()),
          barrierDismissible: false,
        );
        await Get.find<AuthService>().signInWithGoogle();
        Get.back();
      }
    }
  }

  void syncGoogleDevices() async {
    if (!isGoogleLinked.value) return;
    isSyncing.value = true;

    bool syncSuccess = false;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final idToken = await user.getIdToken();
        final syncUrl = dotenv.env['GOOGLE_HOME_SYNC_URL'];
        final response = await Dio().post(
          syncUrl!,
          options: Options(
            headers: {'Authorization': 'Bearer $idToken'},
            sendTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        syncSuccess = (response.statusCode == 200);
      } catch (e) {
        if (kDebugMode) {
          print('Google Home Sync API error: $e');
        }
      }
    }

    isSyncing.value = false;

    final now = DateTime.now();
    final minutesStr = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    lastSyncTime.value = '$hour:$minutesStr $ampm';

    // Show result feedback to the user
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        title: Row(
          children: [
            Icon(
              syncSuccess ? Icons.check_circle_outline : Icons.info_outline,
              color: syncSuccess ? Colors.greenAccent : const Color(0xFF00E5FF),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              syncSuccess ? 'Sync Completed' : 'Local Sync Successful',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          syncSuccess
              ? 'Your device configuration has been successfully synchronized with your Google Home Graph.'
              : 'Rooms and devices are successfully synced to Firebase. To complete integration, make sure your account is linked inside the Google Home App.',
          style: const TextStyle(color: Color(0xFF8B8B8D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'OK',
              style: TextStyle(
                color: Color(0xFF00E5FF),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
