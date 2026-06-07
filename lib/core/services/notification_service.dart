import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';

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

class NotificationService extends GetxService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  
  final RxString fcmToken = ''.obs;
  final RxBool hasPermission = false.obs;

  @override
  void onInit() {
    super.onInit();
    setupNotifications();
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

      hasPermission.value = settings.authorizationStatus == AuthorizationStatus.authorized;

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
        fcmToken.value = token;
        if (kDebugMode) {
          print('FCM Token: $token');
        }
      }
      // Listen to token refresh
      _fcm.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
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
    if (fcmToken.value.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: fcmToken.value));
      Get.snackbar(
        'Success',
        'FCM Token copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.cardBackground,
        colorText: Colors.white,
        borderColor: AppTheme.primaryBlue.withOpacity(0.3),
        borderWidth: 1,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.check_circle_outline, color: AppTheme.accentCyan),
      );
    }
  }

  void _showForegroundNotification(RemoteMessage message) {
    final title = message.notification?.title ?? 'Notification';
    final body = message.notification?.body ?? '';
    
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      messageText: Text(
        body,
        style: const TextStyle(
          color: AppTheme.textGrey,
          fontSize: 14,
        ),
      ),
      icon: Container(
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
      backgroundColor: AppTheme.cardBackground,
      borderRadius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      borderColor: AppTheme.primaryPurple.withOpacity(0.3),
      borderWidth: 1,
      duration: const Duration(seconds: 5),
      snackPosition: SnackPosition.TOP,
      barBlur: 10,
      dismissDirection: DismissDirection.horizontal,
    );
  }

  void _handleNotificationClick(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification clicked with payload: ${message.data}');
    }
    // Implement custom routing or action here
  }
}
