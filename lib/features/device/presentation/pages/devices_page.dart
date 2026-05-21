import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/device_list.dart';
import '../../../../core/theme/app_theme.dart';

class DevicesPage extends ConsumerWidget {
  const DevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Living Room'), // Example static room name
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.neonPurple),
            onPressed: () {
              // Navigate to settings to change IP
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
