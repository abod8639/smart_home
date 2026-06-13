import os
import re

files_to_process = [
    "lib/features/room/presentation/widgets/placement_device_dialogs.dart",
    "lib/features/room/presentation/widgets/placement_device_ir_controls.dart",
    "lib/features/room/presentation/widgets/placement_device_properties.dart",
    "lib/features/room/presentation/widgets/placement_image_panel.dart",
    "lib/features/room/presentation/widgets/room_management_dialogs.dart",
    "lib/features/room/presentation/pages/room_placement_view.dart",
    "lib/features/dashboard/presentation/pages/remote_page.dart",
    "lib/features/dashboard/presentation/widgets/remote/advanced_features_card.dart",
    "lib/features/dashboard/presentation/widgets/remote/fan_speed_card.dart",
    "lib/features/settings/presentation/pages/settings_view.dart",
    "lib/features/settings/presentation/widgets/add_device_dialog.dart",
    "lib/features/settings/presentation/widgets/device_placement_card.dart",
    "lib/features/settings/presentation/widgets/fcm_token_card.dart",
    "lib/features/settings/presentation/widgets/google_home_card.dart",
    "lib/features/settings/presentation/widgets/hub_config_card.dart",
    "lib/features/settings/presentation/widgets/matter_commissioning_dialog.dart",
    "lib/features/settings/presentation/widgets/preferences_card.dart",
    "lib/features/settings/presentation/widgets/profile_card.dart",
    "lib/features/settings/presentation/widgets/safety_card.dart",
]

for file_path in files_to_process:
    if not os.path.exists(file_path):
        continue
        
    with open(file_path, 'r') as f:
        content = f.read()

    # Imports
    content = content.replace("import 'package:get/get.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';")
    
    # Widget class definition
    content = content.replace("class FcmTokenCard extends StatelessWidget", "class FcmTokenCard extends ConsumerWidget")
    content = content.replace("class RemotePage extends StatefulWidget", "class RemotePage extends ConsumerStatefulWidget")
    content = content.replace("extends StatelessWidget", "extends ConsumerWidget")
    content = content.replace("extends State<", "extends ConsumerState<")
    
    # Build method
    content = re.sub(r'Widget build\(BuildContext context\) \{', 'Widget build(BuildContext context, WidgetRef ref) {', content)
    
    # Controllers & Services
    content = content.replace("Get.find<DashboardController>()", "ref.read(dashboardControllerProvider.notifier)")
    content = content.replace("Get.find<RoomPlacementController>()", "ref.read(roomPlacementControllerProvider.notifier)")
    content = content.replace("Get.find<NotificationService>()", "ref.read(notificationServiceProvider.notifier)")
    content = content.replace("Get.find<MatterService>()", "ref.read(matterServiceProvider)")
    content = content.replace("Get.isRegistered<MatterService>()", "true") 
    
    # Snackbar (simplistic)
    # We find Get.snackbar('title', 'message', ...) and extract title and message.
    # To handle multiline, we replace Get.snackbar(...) block.
    # A simple regex for Get.snackbar('x', 'y' ... );
    def snackbar_repl(m):
        t = m.group(1).strip()
        msg = m.group(2).strip()
        return f"ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text({t} + ': ' + {msg})));"
    
    # Regex matches up to the first semicolon after Get.snackbar
    content = re.sub(r"Get\.snackbar\(\s*(.*?),\s*(.*?)(?:,|\))(.*?);", snackbar_repl, content, flags=re.DOTALL)
    
    # Dialogs
    content = re.sub(r"Get\.dialog\(\s*", "showDialog(context: context, builder: (context) => ", content)
    
    # Navigation
    content = re.sub(r"Get\.back\((.*?)\)", r"if (context.mounted) context.pop(\1)", content)
    content = re.sub(r"Get\.toNamed\((.*?)\)", r"context.push(\1)", content)
    content = re.sub(r"Get\.offAllNamed\((.*?)\)", r"context.go(\1)", content)
    
    # Obx
    content = content.replace("Obx(() {", "Consumer(builder: (context, ref, _) {")
    content = content.replace("Obx(() =>", "Consumer(builder: (context, ref, _) =>")
    
    with open(file_path, 'w') as f:
        f.write(content)
