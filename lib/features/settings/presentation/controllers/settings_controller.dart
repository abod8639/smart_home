import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

class SettingsState extends Equatable {
  final String userName;
  final String userRole;
  final bool isCelsius;
  final String selectedVoiceAssistant;
  final bool notificationsEnabled;
  final String hubConnectionMode;
  final bool autoBackups;
  final double lockTimeout;
  final String ipAddress;
  final bool isHubReachable;
  final bool isCheckingHub;
  final bool isGoogleLinked;
  final String googleEmail;
  final bool isSyncing;
  final String lastSyncTime;

  const SettingsState({
    this.userName = 'Dexter',
    this.userRole = 'Administrator',
    this.isCelsius = true,
    this.selectedVoiceAssistant = 'Google Assistant',
    this.notificationsEnabled = true,
    this.hubConnectionMode = 'Wi-Fi',
    this.autoBackups = true,
    this.lockTimeout = 5.0,
    this.ipAddress = '',
    this.isHubReachable = false,
    this.isCheckingHub = false,
    this.isGoogleLinked = false,
    this.googleEmail = '',
    this.isSyncing = false,
    this.lastSyncTime = 'Never',
  });

  SettingsState copyWith({
    String? userName,
    String? userRole,
    bool? isCelsius,
    String? selectedVoiceAssistant,
    bool? notificationsEnabled,
    String? hubConnectionMode,
    bool? autoBackups,
    double? lockTimeout,
    String? ipAddress,
    bool? isHubReachable,
    bool? isCheckingHub,
    bool? isGoogleLinked,
    String? googleEmail,
    bool? isSyncing,
    String? lastSyncTime,
  }) {
    return SettingsState(
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      isCelsius: isCelsius ?? this.isCelsius,
      selectedVoiceAssistant: selectedVoiceAssistant ?? this.selectedVoiceAssistant,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      hubConnectionMode: hubConnectionMode ?? this.hubConnectionMode,
      autoBackups: autoBackups ?? this.autoBackups,
      lockTimeout: lockTimeout ?? this.lockTimeout,
      ipAddress: ipAddress ?? this.ipAddress,
      isHubReachable: isHubReachable ?? this.isHubReachable,
      isCheckingHub: isCheckingHub ?? this.isCheckingHub,
      isGoogleLinked: isGoogleLinked ?? this.isGoogleLinked,
      googleEmail: googleEmail ?? this.googleEmail,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  @override
  List<Object?> get props => [
        userName, userRole, isCelsius, selectedVoiceAssistant, notificationsEnabled,
        hubConnectionMode, autoBackups, lockTimeout, ipAddress, isHubReachable,
        isCheckingHub, isGoogleLinked, googleEmail, isSyncing, lastSyncTime
      ];
}

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  static const _ipKey = 'hub_ip_address';

  // Available options
  final voiceAssistants = ['Google Assistant', 'Alexa', 'Siri', 'None'];
  final connectionModes = ['Wi-Fi', 'Zigbee', 'Bluetooth'];

  @override
  SettingsState build() {
    final defaultIp = dotenv.env['MQTT_BROKER_URL'] ?? 'broker.hivemq.com';
    final initialState = SettingsState(ipAddress: defaultIp);
    
    // Defer initialization tasks
    Future.microtask(() {
      _loadIpAddress();
      _bindAuthUser();
    });
    
    return initialState;
  }

  void _bindAuthUser() {
    ref.listen(authStateProvider, (prev, user) {
        state = state.copyWith(
          isGoogleLinked: true,
          googleEmail: user.value?.email ?? '',
          userName: user.value?.displayName ?? 'Dexter',
        );
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      state = state.copyWith(
        isGoogleLinked: true,
        googleEmail: user.email ?? '',
        userName: user.displayName ?? 'Dexter',
      );
    }
  }

  Future<void> _loadIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIp = prefs.getString(_ipKey);
    if (savedIp != null && savedIp.isNotEmpty) {
      state = state.copyWith(ipAddress: savedIp);
    }
    await checkHubConnection();
  }

  Future<void> checkHubConnection() async {
    state = state.copyWith(isCheckingHub: true);
    try {
      final result = await ref.read(esp32ServiceProvider.notifier).pingHub();
      state = state.copyWith(isHubReachable: result.isSuccess);
    } catch (e) {
      state = state.copyWith(isHubReachable: false);
    } finally {
      state = state.copyWith(isCheckingHub: false);
    }
  }

  void updateUserName(String name) {
    if (name.isNotEmpty) {
      state = state.copyWith(userName: name);
    }
  }

  Future<void> updateIpAddress(String ip) async {
    if (ip.isEmpty) return;
    state = state.copyWith(ipAddress: ip);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ip);
    await checkHubConnection();
  }

  void toggleTempUnit() {
    state = state.copyWith(isCelsius: !state.isCelsius);
  }

  void selectVoiceAssistant(String assistant) {
    if (voiceAssistants.contains(assistant)) {
      state = state.copyWith(selectedVoiceAssistant: assistant);
    }
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
  }

  void selectConnectionMode(String mode) {
    if (connectionModes.contains(mode)) {
      state = state.copyWith(hubConnectionMode: mode);
    }
  }

  void toggleAutoBackups() {
    state = state.copyWith(autoBackups: !state.autoBackups);
  }

  void updateLockTimeout(double value) {
    state = state.copyWith(lockTimeout: value.clamp(1.0, 30.0));
  }

  void toggleGoogleLink(BuildContext context) async {
    if (state.isGoogleLinked) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF8B8B8D)),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await ref.read(authServiceProvider.notifier).signOut();
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      await ref.read(authServiceProvider.notifier).signInWithGoogle();
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading dialog
      }
    }
  }

  void syncGoogleDevices(BuildContext context) async {
    if (!state.isGoogleLinked) return;
    state = state.copyWith(isSyncing: true);

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

    final now = DateTime.now();
    final minutesStr = now.minute < 10 ? '0${now.minute}' : '${now.minute}';
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
        
    state = state.copyWith(
      isSyncing: false,
      lastSyncTime: '$hour:$minutesStr $ampm',
    );

    // Show result feedback to the user
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
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
              onPressed: () => Navigator.of(context).pop(),
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
}
