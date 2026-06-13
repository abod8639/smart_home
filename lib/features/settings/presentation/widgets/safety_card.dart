import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/features/settings/presentation/widgets/settings_row.dart';

class SafetyCard extends ConsumerWidget {
  const SafetyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(settingsControllerProvider.notifier);
    final state = ref.watch(settingsControllerProvider);
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Safety & Security',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Hub Auto-Backups Switch
          SettingsRow(
            icon: Icons.backup_outlined,
            title: 'Automatic Backups',
            subtitle: 'Daily system config save to cloud',
            trailing: Consumer(builder: (context, ref, _) => Switch(
                  value: ref.watch(settingsControllerProvider).autoBackups,
                  onChanged: (_) => ref.read(settingsControllerProvider.notifier).toggleAutoBackups(),
                  activeThumbColor: AppTheme.primaryBlue,
                  activeTrackColor: AppTheme.primaryBlue.withValues(alpha: 0.3),
                  inactiveThumbColor: AppTheme.textGrey,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                )),
          ),


        ],
      ),
    );
  }


}
