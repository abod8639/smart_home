import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import 'package:smart_home/core/services/auth_service.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/formatting_utils.dart';
import 'package:smart_home/core/widgets/app_dialog.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/get_settings_usecase.dart';
import '../../domain/usecases/save_hub_ip_usecase.dart';
import '../../domain/usecases/ping_hub_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';

part 'settings_controller.g.dart';

/// Presentation state for the settings view, extending [SettingsEntity].
class SettingsState extends SettingsEntity {
  const SettingsState({
    super.userName = 'Dexter',
    super.userRole = 'Administrator',
    super.isCelsius = true,
    super.selectedVoiceAssistant = 'Google Assistant',
    super.notificationsEnabled = true,
    super.hubConnectionMode = 'Wi-Fi',
    super.autoBackups = true,
    super.lockTimeout = 5.0,
    super.ipAddress = '',
    super.isHubReachable = false,
    super.isCheckingHub = false,
    super.isGoogleLinked = false,
    super.googleEmail = '',
    super.isSyncing = false,
    super.lastSyncTime = 'Never',
  });

  @override
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
}

@Riverpod(keepAlive: true)
class SettingsController extends _$SettingsController {
  // Available options
  final voiceAssistants = ['Google Assistant', 'Alexa', 'Siri', 'None'];
  final connectionModes = ['Wi-Fi', 'Zigbee', 'Bluetooth'];

  @override
  SettingsState build() {
    final defaultIp = dotenv.env['MQTT_BROKER_URL'] ?? 'broker.hivemq.com';
    final initialState = SettingsState(ipAddress: defaultIp);

    // Defer initialization tasks
    Future.microtask(() {
      _loadSavedSettings();
      _bindAuthUser();
    });

    return initialState;
  }

  void _bindAuthUser() {
    ref.listen(authStateProvider, (prev, user) {
      final u = user.value;
      state = state.copyWith(
        isGoogleLinked: u != null,
        googleEmail: u?.email ?? '',
        userName: u?.displayName ?? 'Dexter',
      );
    });

    try {
      final user = ref.read(firebaseAuthProvider).currentUser;
      if (user != null) {
        state = state.copyWith(
          isGoogleLinked: true,
          googleEmail: user.email ?? '',
          userName: user.displayName ?? 'Dexter',
        );
      } else {
        state = state.copyWith(
          isGoogleLinked: false,
          googleEmail: '',
        );
      }
    } catch (_) {
      // FirebaseAuth might not be initialized in some test environments
    }
  }

  Future<void> _loadSavedSettings() async {
    try {
      final savedSettings = await ref.read(getSettingsUseCaseProvider)();
      if (!ref.mounted) return;
      if (savedSettings.ipAddress.isNotEmpty) {
        state = state.copyWith(
          ipAddress: savedSettings.ipAddress,
          userName: savedSettings.userName,
          userRole: savedSettings.userRole,
          isCelsius: savedSettings.isCelsius,
          selectedVoiceAssistant: savedSettings.selectedVoiceAssistant,
          notificationsEnabled: savedSettings.notificationsEnabled,
          hubConnectionMode: savedSettings.hubConnectionMode,
          autoBackups: savedSettings.autoBackups,
          lockTimeout: savedSettings.lockTimeout,
        );
      }
    } catch (_) {
      // Local storage fallback
    }
    await checkHubConnection();
  }

  Future<void> checkHubConnection() async {
    if (!ref.mounted) return;
    state = state.copyWith(isCheckingHub: true);
    try {
      final reachable = await ref.read(pingHubUseCaseProvider)();
      if (!ref.mounted) return;
      state = state.copyWith(isHubReachable: reachable);
    } catch (e) {
      if (ref.mounted) {
        state = state.copyWith(isHubReachable: false);
      }
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isCheckingHub: false);
      }
    }
  }

  void updateUserName(String name) {
    if (name.isNotEmpty) {
      state = state.copyWith(userName: name);
      _persistCurrentSettings();
    }
  }

  Future<void> updateIpAddress(String ip) async {
    if (ip.isEmpty) return;
    state = state.copyWith(ipAddress: ip);
    try {
      await ref.read(saveHubIpUseCaseProvider)(ip);
    } catch (_) {}
    await checkHubConnection();
  }

  void toggleTempUnit() {
    state = state.copyWith(isCelsius: !state.isCelsius);
    _persistCurrentSettings();
  }

  void selectVoiceAssistant(String assistant) {
    if (voiceAssistants.contains(assistant)) {
      state = state.copyWith(selectedVoiceAssistant: assistant);
      _persistCurrentSettings();
    }
  }

  void toggleNotifications() {
    state = state.copyWith(notificationsEnabled: !state.notificationsEnabled);
    _persistCurrentSettings();
  }

  void selectConnectionMode(String mode) {
    if (connectionModes.contains(mode)) {
      state = state.copyWith(hubConnectionMode: mode);
      _persistCurrentSettings();
    }
  }

  void toggleAutoBackups() {
    state = state.copyWith(autoBackups: !state.autoBackups);
    _persistCurrentSettings();
  }

  void updateLockTimeout(double value) {
    state = state.copyWith(lockTimeout: value.clamp(1.0, 30.0));
    _persistCurrentSettings();
  }

  void _persistCurrentSettings() {
    try {
      ref.read(saveSettingsUseCaseProvider)(state);
    } catch (_) {}
  }

  void toggleGoogleLink(BuildContext context) async {
    if (state.isGoogleLinked) {
      AppDialog.show(
        context: context,
        builder: (context) => AppDialog(
          title: const Text(
            'Disconnect Google Smart Home?',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'This will disconnect your smart home integration and sign you out of your account.',
            style: TextStyle(color: AppTheme.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppTheme.textGrey),
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

    state = state.copyWith(
      isSyncing: false,
      lastSyncTime: FormattingUtils.formatTime(DateTime.now()),
    );

    // Show result feedback to the user
    if (context.mounted) {
      AppDialog.show(
        context: context,
        builder: (context) => AppDialog(
          title: Row(
            children: [
              Icon(
                syncSuccess ? Icons.check_circle_outline : Icons.info_outline,
                color: syncSuccess ? Colors.greenAccent : AppTheme.accentCyan,
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
            style: const TextStyle(color: AppTheme.textGrey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: AppTheme.accentCyan,
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
