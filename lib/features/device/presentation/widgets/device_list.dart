import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import 'device_card.dart';

class DeviceList extends ConsumerWidget {
  const DeviceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsyncValue = ref.watch(deviceControllerProvider);

    return listAsyncValue.when(
      data: (items) {
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'No devices found in this room.',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          );
        }
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (_, i) => DeviceCard(device: items[i]),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFF00F0FF)), // Neon Blue
      ),
      error: (e, st) => Center(
        child: Text(
          'Error loading devices: \$e',
          style: const TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
