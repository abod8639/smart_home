import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/app_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all core infrastructure services
  await AppInitializer.init();

  runApp(const ProviderScope(child: SmartHomeApp()));
}

/// Root widget of the Smart Home application configuring theme and navigation routing.
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
