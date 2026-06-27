import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:smart_home/core/services/firebase_service.dart';

class MatterCodeCard extends ConsumerWidget {
  const MatterCodeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stream = ref.watch(firebaseServiceProvider.notifier).matterPayloadStream;

    return GlassContainer(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.qr_code_scanner, color: AppTheme.primaryPurple, size: 24),
              const SizedBox(width: 12),
              Text(
                'Matter Setup Code',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Scan this QR code in Apple Home or Google Home to add the Smart Home Bridge.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
          ),
          const SizedBox(height: 24),
          StreamBuilder<DatabaseEvent>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasData && snapshot.data?.snapshot.value != null) {
                final data = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
                final qrCode = data['qr_code'] as String? ?? '';
                final manualCode = data['manual_code'] as String? ?? '';

                return Column(
                  children: [
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: QrImageView(
                          data: qrCode,
                          version: QrVersions.auto,
                          size: 180.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Manual Pairing Code',
                      style: TextStyle(color: AppTheme.textGrey, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                      ),
                      child: Text(
                        manualCode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                  ],
                );
              }
              
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.hourglass_empty, color: AppTheme.textGrey, size: 32),
                    SizedBox(height: 12),
                    Text(
                      'Waiting for ESP32 to upload Matter code...',
                      style: TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
