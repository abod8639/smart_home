import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/widgets/glass_container.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class ProfileCard extends ConsumerWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settingsControllerProvider);

    final isMobile = Responsive.isMobile(context);
    final avatarSize = isMobile ? 56.0 : 72.0;

    return GlassContainer(
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      'https://avatars.githubusercontent.com/u/108903062?v=4',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Container(
                width: isMobile ? 14 : 18,
                height: isMobile ? 14 : 18,
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.cardBackground,
                    width: 2,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: isMobile ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer(builder: (context, ref, _) => Text(
                      state.userName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                const SizedBox(height: 4),
                Consumer(builder: (context, ref, _) => Text(
                      state.userRole,
                      style: TextStyle(
                        color: AppTheme.textGrey,
                        fontSize: isMobile ? 11 : 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    )),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppTheme.primaryBlue),
            onPressed: () => _showEditProfileDialog(context, ref),
          ),
        ],
      ),
    );
  }

  // Dialog to Edit profile name
  void _showEditProfileDialog(BuildContext context, WidgetRef ref) {
    final state = ref.read(settingsControllerProvider);
    final controller = ref.read(settingsControllerProvider.notifier);
    final textController = TextEditingController(text: state.userName);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppTheme.cardBackground,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          ),
          title: const Text(
            'Edit Profile Name',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: const TextStyle(color: AppTheme.textGrey),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: AppTheme.textGrey)),
            ),
            TextButton(
              onPressed: () {
                controller.updateUserName(textController.text);
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
