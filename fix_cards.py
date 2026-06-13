import os
import re

files_to_process = [
    "lib/features/settings/presentation/widgets/device_placement_card.dart",
    "lib/features/settings/presentation/widgets/fcm_token_card.dart",
    "lib/features/settings/presentation/widgets/google_home_card.dart",
    "lib/features/settings/presentation/widgets/hub_config_card.dart",
    "lib/features/settings/presentation/widgets/preferences_card.dart",
    "lib/features/settings/presentation/widgets/profile_card.dart",
    "lib/features/settings/presentation/widgets/safety_card.dart",
]

for file_path in files_to_process:
    if not os.path.exists(file_path):
        continue
    with open(file_path, 'r') as f:
        c = f.read()
    
    # Check if it was a GetView
    c = c.replace('class ProfileCard extends GetView<SettingsController>', 'class ProfileCard extends ConsumerWidget')
    c = c.replace('class HubConfigCard extends GetView<SettingsController>', 'class HubConfigCard extends ConsumerWidget')
    c = c.replace('class PreferencesCard extends GetView<SettingsController>', 'class PreferencesCard extends ConsumerWidget')
    
    # Insert controller definition into the build method if not present
    if 'Widget build(BuildContext context, WidgetRef ref) {' in c and 'final controller =' not in c:
        c = c.replace('Widget build(BuildContext context, WidgetRef ref) {', 
                      'Widget build(BuildContext context, WidgetRef ref) {\n    final controller = ref.read(settingsControllerProvider.notifier);\n    final state = ref.watch(settingsControllerProvider);')
        
    # Replace controller variables with state ones where applicable
    # e.g. controller.isHubReachable.value -> state.isHubReachable
    c = re.sub(r'controller\.([a-zA-Z0-9_]+)\.value', r'state.\1', c)
    # Also if there's any remaining `controller.autoBackups.value` it would be caught.
    # Note: methods like controller.toggleAutoBackups() are fine since they exist on the notifier.

    with open(file_path, 'w') as f:
        f.write(c)

