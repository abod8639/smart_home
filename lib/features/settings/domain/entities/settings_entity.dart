import 'package:equatable/equatable.dart';

/// Domain entity encapsulating smart home user preferences and hub configuration.
class SettingsEntity extends Equatable {
  /// Display name of the user profile.
  final String userName;

  /// Role of the user in the smart home system.
  final String userRole;

  /// Whether temperature is displayed in Celsius (true) or Fahrenheit (false).
  final bool isCelsius;

  /// Selected voice assistant integration (e.g. Google Assistant, Alexa).
  final String selectedVoiceAssistant;

  /// Whether push notifications are enabled.
  final bool notificationsEnabled;

  /// Connection mode to the central hub (e.g. Wi-Fi, Zigbee, Bluetooth).
  final String hubConnectionMode;

  /// Whether automated configuration backups are enabled.
  final bool autoBackups;

  /// Security lock timeout in minutes.
  final double lockTimeout;

  /// MQTT broker URL or local IP address of the smart hub.
  final String ipAddress;

  /// Whether the smart hub is actively reachable over the network.
  final bool isHubReachable;

  /// Whether a network reachability check is currently in progress.
  final bool isCheckingHub;

  /// Whether the account is linked to Google Smart Home.
  final bool isGoogleLinked;

  /// Email address associated with the linked Google account.
  final String googleEmail;

  /// Whether device synchronization with cloud/Google Home is active.
  final bool isSyncing;

  /// Human-readable timestamp of the last successful sync.
  final String lastSyncTime;

  const SettingsEntity({
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

  /// Returns a copy of this [SettingsEntity] with updated fields.
  SettingsEntity copyWith({
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
    return SettingsEntity(
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
        userName,
        userRole,
        isCelsius,
        selectedVoiceAssistant,
        notificationsEnabled,
        hubConnectionMode,
        autoBackups,
        lockTimeout,
        ipAddress,
        isHubReachable,
        isCheckingHub,
        isGoogleLinked,
        googleEmail,
        isSyncing,
        lastSyncTime,
      ];
}
