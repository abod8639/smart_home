import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../widgets/device_list.dart';
import '../../../../core/theme/app_theme.dart';

class DevicesPage extends ConsumerWidget {
  final String roomName;

  const DevicesPage({super.key, required this.roomName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: Text(roomName), 
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.neonPink),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundDark,
              Color(0xFF1A1D2D), // Slightly lighter dark
            ],
          ),
        ),
        child: const DeviceList(),
      ),
    );
  }
}
