import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/services/hive_service.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'core/bindings/initial_binding.dart';
import 'features/room/presentation/pages/room_placement_view.dart';
import 'features/room/presentation/controllers/room_placement_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
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
