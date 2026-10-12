import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

part 'settings_local_datasource.g.dart';

/// Local data source managing persistent configuration and preferences using [SharedPreferences].
class SettingsLocalDatasource {
  static const String keyHubIp = 'hub_ip_address';
  static const String keyUserName = 'user_name';
  static const String keyUserRole = 'user_role';
  static const String keyIsCelsius = 'is_celsius';
  static const String keyVoiceAssistant = 'voice_assistant';
  static const String keyNotificationsEnabled = 'notifications_enabled';
  static const String keyConnectionMode = 'hub_connection_mode';
  static const String keyAutoBackups = 'auto_backups';
  static const String keyLockTimeout = 'lock_timeout';

  /// Retrieves the saved hub IP address from local storage.
  Future<String?> getHubIp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyHubIp);
  }

  /// Persists the hub IP address.
  Future<void> saveHubIp(String ip) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyHubIp, ip);
  }

  /// Loads persisted settings and returns a [SettingsModel].
  Future<SettingsModel> loadSettings({String defaultIp = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsModel(
      userName: prefs.getString(keyUserName) ?? 'Dexter',
      userRole: prefs.getString(keyUserRole) ?? 'Administrator',
      isCelsius: prefs.getBool(keyIsCelsius) ?? true,
      selectedVoiceAssistant: prefs.getString(keyVoiceAssistant) ?? 'Google Assistant',
      notificationsEnabled: prefs.getBool(keyNotificationsEnabled) ?? true,
      hubConnectionMode: prefs.getString(keyConnectionMode) ?? 'Wi-Fi',
      autoBackups: prefs.getBool(keyAutoBackups) ?? true,
      lockTimeout: prefs.getDouble(keyLockTimeout) ?? 5.0,
      ipAddress: prefs.getString(keyHubIp) ?? defaultIp,
    );
  }

  /// Persists user preferences to local storage.
  Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(keyUserName, settings.userName),
      prefs.setString(keyUserRole, settings.userRole),
      prefs.setBool(keyIsCelsius, settings.isCelsius),
      prefs.setString(keyVoiceAssistant, settings.selectedVoiceAssistant),
      prefs.setBool(keyNotificationsEnabled, settings.notificationsEnabled),
      prefs.setString(keyConnectionMode, settings.hubConnectionMode),
      prefs.setBool(keyAutoBackups, settings.autoBackups),
      prefs.setDouble(keyLockTimeout, settings.lockTimeout),
      if (settings.ipAddress.isNotEmpty) prefs.setString(keyHubIp, settings.ipAddress),
    ]);
  }
}

/// Provider for accessing [SettingsLocalDatasource].
@riverpod
SettingsLocalDatasource settingsLocalDatasource(Ref ref) {
  return SettingsLocalDatasource();
}
