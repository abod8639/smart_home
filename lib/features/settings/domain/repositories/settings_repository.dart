import '../entities/settings_entity.dart';

/// Repository contract for settings data management and hub connectivity checks.
abstract class SettingsRepository {
  /// Retrieves the saved MQTT broker URL or hub IP address.
  Future<String?> getSavedHubIp();

  /// Persists the MQTT broker URL or hub IP address.
  Future<void> saveHubIp(String ip);

  /// Retrieves persisted user settings and preferences.
  Future<SettingsEntity> getSettings();

  /// Persists user settings and preferences.
  Future<void> saveSettings(SettingsEntity settings);

  /// Pings the central ESP32 hub to verify network reachability.
  Future<bool> pingHub();
}
