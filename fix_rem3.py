import os
import re

files_with_state = [
    "lib/features/settings/presentation/widgets/hub_config_card.dart",
    "lib/features/settings/presentation/widgets/profile_card.dart",
    "lib/features/settings/presentation/widgets/fcm_token_card.dart",
    "lib/features/settings/presentation/widgets/device_placement_card.dart",
    "lib/features/settings/presentation/widgets/preferences_card.dart",
    "lib/features/settings/presentation/widgets/safety_card.dart",
]

for p in files_with_state:
    if not os.path.exists(p): continue
    with open(p, 'r') as f: c = f.read()
    
    # Import settings_controller
    if 'import \'package:smart_home/features/settings/presentation/controllers/settings_controller.dart\';' not in c:
        c = c.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';")
    
    # If the file has state.xxx but state is undefined (missed by previous scripts)
    if 'Widget build(BuildContext context, WidgetRef ref) {' in c and 'final state =' not in c:
        c = c.replace('Widget build(BuildContext context, WidgetRef ref) {',
                      'Widget build(BuildContext context, WidgetRef ref) {\n    final controller = ref.read(settingsControllerProvider.notifier);\n    final state = ref.watch(settingsControllerProvider);')
                      
    with open(p, 'w') as f: f.write(c)
