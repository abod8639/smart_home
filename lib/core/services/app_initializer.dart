import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_home/firebase_options.dart';
import 'hive_service.dart';
import 'notification_service.dart';

/// Centralized application bootstrap and service initialization manager.
/// Adheres to Clean Architecture by encapsulating all startup infrastructure routines.
abstract final class AppInitializer {
  /// Initializes all core infrastructure services required before the widget tree mounts.
  static Future<void> init() async {
    await initEnvironment();
    await initFirebase();
    await initHive();
  }

  /// Loads local environment variables from `.env` gracefully.
  static Future<void> initEnvironment({String envFile = '.env'}) async {
    try {
      await dotenv.load(fileName: envFile);
    } catch (e) {
      debugPrint('Warning: Could not load $envFile file: $e');
    }
  }

  /// Whether Firebase is officially supported on the current runtime platform.
  static bool get isFirebaseSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  /// Initializes Firebase and registers background message handlers if supported.
  static Future<void> initFirebase() async {
    if (!isFirebaseSupported) {
      debugPrint(
        'Firebase is not supported on this platform ($defaultTargetPlatform). Skipping initialization.',
      );
      return;
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      // Register background messaging handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    } catch (e) {
      if (e.toString().contains('duplicate-app')) {
        // Firebase already initialized, safe to ignore.
      } else {
        rethrow;
      }
    }
  }

  /// Initializes local Hive storage boxes.
  static Future<void> initHive({String? testPath}) async {
    try {
      await HiveService.init(testPath: testPath);
    } catch (e) {
      debugPrint('Warning: Failed to initialize Hive storage: $e');
    }
  }
}
