import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/device_providers.dart';
import 'device_card.dart';

class DeviceList extends ConsumerWidget {
  const DeviceList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsyncValue = ref.watch(deviceListProvider);

    return listAsyncValue.when(
      data: (items) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (_, i) => DeviceCard(entity: items[i]),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, st) => Center(child: Text('Error: $e')),
    );
  }
}
