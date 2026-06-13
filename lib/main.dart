import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/hive_service.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
  }

  // Only initialize Firebase if the platform is supported
  final isFirebaseSupported = kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (isFirebaseSupported) {
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
  } else {
    debugPrint("Firebase is not supported on this platform (\$defaultTargetPlatform). Skipping initialization.");
  }
  
  await HiveService.init();
  runApp(const ProviderScope(child: SmartHomeApp()));
}


class SmartHomeApp extends ConsumerWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Smart Home IoT',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: goRouter,
    );
  }
}
