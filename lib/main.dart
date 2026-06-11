import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:smart_home/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/hive_service.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'core/bindings/initial_binding.dart';
import 'features/room/presentation/pages/room_placement_view.dart';
import 'features/room/presentation/controllers/room_placement_controller.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'core/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Warning: Could not load .env file: $e");
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
  await HiveService.init();
  runApp(const SmartHomeApp());
}




class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Home IoT',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/dashboard',
      initialBinding: InitialBinding(),
      getPages: [
        GetPage(
          name: '/login',
          page: () => const LoginPage(),
        ),
        GetPage(
          name: '/dashboard',
          page: () => const DashboardPage(),
        ),
        GetPage(
          name: '/room-placement',
          page: () => const RoomPlacementView(),
          binding: BindingsBuilder(() {
            Get.lazyPut(() => RoomPlacementController());
          }),
        ),
      ],
      );
  }
}
