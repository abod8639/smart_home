import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/dashboard/presentation/controllers/dashboard_binding.dart';

void main() {
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
      getPages: [
        GetPage(
          name: '/dashboard',
          page: () => const DashboardPage(),
          binding: DashboardBinding(),
        ),
      ],
      );
  }
}
