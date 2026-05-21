import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/device/presentation/pages/devices_page.dart';
import '../../features/room/presentation/pages/rooms_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'rooms',
        builder: (context, state) => const RoomsPage(),
      ),
      GoRoute(
        path: '/devices',
        name: 'devices',
        builder: (context, state) {
          // You can pass the room name via state.extra if needed
          final roomName = state.extra as String? ?? 'Living Room';
          return DevicesPage(roomName: roomName);
        },
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: \${state.error}'),
      ),
    ),
  );
});
