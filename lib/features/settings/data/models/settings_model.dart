import '../../domain/entities/settings_entity.dart';

/// Data model for settings serialization and persistence.
class SettingsModel extends SettingsEntity {
  const SettingsModel({
    super.userName,
    super.userRole,
    super.isCelsius,
    super.selectedVoiceAssistant,
    super.notificationsEnabled,
    super.hubConnectionMode,
    super.autoBackups,
    super.lockTimeout,
    super.ipAddress,
    super.isHubReachable,
    super.isCheckingHub,
    super.isGoogleLinked,
    super.googleEmail,
    super.isSyncing,
    super.lastSyncTime,
  });

  /// Creates a [SettingsModel] from a [SettingsEntity].
  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      userName: entity.userName,
      userRole: entity.userRole,
      isCelsius: entity.isCelsius,
      selectedVoiceAssistant: entity.selectedVoiceAssistant,
      notificationsEnabled: entity.notificationsEnabled,
      hubConnectionMode: entity.hubConnectionMode,
      autoBackups: entity.autoBackups,
      lockTimeout: entity.lockTimeout,
      ipAddress: entity.ipAddress,
      isHubReachable: entity.isHubReachable,
      isCheckingHub: entity.isCheckingHub,
      isGoogleLinked: entity.isGoogleLinked,
      googleEmail: entity.googleEmail,
      isSyncing: entity.isSyncing,
      lastSyncTime: entity.lastSyncTime,
    );
  }

  /// Converts this model to a persistent key-value map.
  Map<String, dynamic> toMap() => {
        'userName': userName,
        'userRole': userRole,
        'isCelsius': isCelsius,
        'selectedVoiceAssistant': selectedVoiceAssistant,
        'notificationsEnabled': notificationsEnabled,
        'hubConnectionMode': hubConnectionMode,
        'autoBackups': autoBackups,
        'lockTimeout': lockTimeout,
        'ipAddress': ipAddress,
        'isHubReachable': isHubReachable,
        'isCheckingHub': isCheckingHub,
        'isGoogleLinked': isGoogleLinked,
        'googleEmail': googleEmail,
        'isSyncing': isSyncing,
        'lastSyncTime': lastSyncTime,
      };

  /// Decodes a persisted key-value map into a [SettingsModel].
  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      userName: map['userName'] as String? ?? 'Dexter',
      userRole: map['userRole'] as String? ?? 'Administrator',
      isCelsius: map['isCelsius'] as bool? ?? true,
      selectedVoiceAssistant: map['selectedVoiceAssistant'] as String? ?? 'Google Assistant',
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      hubConnectionMode: map['hubConnectionMode'] as String? ?? 'Wi-Fi',
      autoBackups: map['autoBackups'] as bool? ?? true,
      lockTimeout: (map['lockTimeout'] as num?)?.toDouble() ?? 5.0,
      ipAddress: map['ipAddress'] as String? ?? '',
      isHubReachable: map['isHubReachable'] as bool? ?? false,
      isCheckingHub: map['isCheckingHub'] as bool? ?? false,
      isGoogleLinked: map['isGoogleLinked'] as bool? ?? false,
      googleEmail: map['googleEmail'] as String? ?? '',
      isSyncing: map['isSyncing'] as bool? ?? false,
      lastSyncTime: map['lastSyncTime'] as String? ?? 'Never',
    );
  }
}
