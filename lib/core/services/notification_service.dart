import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/theme/app_theme.dart';

part 'notification_service.g.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

// Top-level background message handler.
// Must be annotated with @pragma('vm:entry-point')
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kDebugMode) {
    print("Handling a background message: ${message.messageId}");
    print("Notification Title: ${message.notification?.title}");
    print("Notification Body: ${message.notification?.body}");
    print("Notification Data: ${message.data}");
  }
}

@Riverpod(keepAlive: true)
class NotificationService extends _$NotificationService {
  late final FirebaseMessaging _fcm;
  
  @override
  void build() {
    final isTest = !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');
    final isSupported = kIsWeb ||
        defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;

    if (!isTest && isSupported) {
      _fcm = FirebaseMessaging.instance;
      setupNotifications();
    } else {
      if (kDebugMode) {
        print("Notifications (FCM) are disabled or unsupported on this platform.");
      }
    }
  }

  Future<void> setupNotifications() async {
    // 1. Request Permission
    await requestPermission();

    // 2. Get and print token
    await getFcmToken();

    // 3. Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('Got a message whilst in the foreground!');
        print('Message data: ${message.data}');
      }

      if (message.notification != null) {
        if (kDebugMode) {
          print('Message also contained a notification: ${message.notification}');
        }
        _showForegroundNotification(message);
      }
    });

    // 4. Handle Notification click when app is opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('A new onMessageOpenedApp event was published!');
      }
      _handleNotificationClick(message);
    });

    // 5. Check if app was opened from terminated state by tapping notification
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationClick(initialMessage);
    }
  }

  Future<void> requestPermission() async {
    try {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      ref.read(hasNotificationPermissionProvider.notifier).state = settings.authorizationStatus == AuthorizationStatus.authorized;

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error requesting notification permission: $e');
      }
    }
  }

  Future<void> getFcmToken() async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        ref.read(fcmTokenProvider.notifier).state = token;
        if (kDebugMode) {
          print('FCM Token: $token');
        }
      }
      // Listen to token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        ref.read(fcmTokenProvider.notifier).state = newToken;
        if (kDebugMode) {
          print('FCM Token Refreshed: $newToken');
        }
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting FCM Token: $e');
      }
    }
  }

  void copyTokenToClipboard() {
    final fcmToken = ref.read(fcmTokenProvider);
    if (fcmToken.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: fcmToken));
      
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: AppTheme.accentCyan),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Success', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('FCM Token copied to clipboard', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.cardBackground,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.3), width: 1),
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: AppTheme.primaryBlue,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    body,
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.primaryPurple.withOpacity(0.3), width: 1),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        duration: const Duration(seconds: 5),
        dismissDirection: DismissDirection.horizontal,
      ),
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification clicked with payload: ${message.data}');
    }
    // Implement custom routing or action here
  }
}


class _FcmTokenNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String value) => state = value;
}

class _NotificationPermissionNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}

final fcmTokenProvider = NotifierProvider<_FcmTokenNotifier, String>(_FcmTokenNotifier.new);
final hasNotificationPermissionProvider = NotifierProvider<_NotificationPermissionNotifier, bool>(_NotificationPermissionNotifier.new);
