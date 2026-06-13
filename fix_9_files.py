import os
import re

def process_file(path, is_stateful=False):
    if not os.path.exists(path): return
    with open(path, 'r') as f: c = f.read()
    
    # 1. Imports
    c = c.replace("import 'package:get/get.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';")
    
    # 2. Add Settings/Dashboard imports if missing
    if "SettingsController" in c and "settings_controller.dart" not in c:
        c = c.replace("import 'package:flutter_riverpod/flutter_riverpod.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';")
    
    # 3. Widget Base
    if is_stateful:
        c = re.sub(r"class (\w+) extends StatefulWidget", r"class \1 extends ConsumerStatefulWidget", c)
        c = re.sub(r"class (\w+) extends State<(\w+)>", r"class \1 extends ConsumerState<\2>", c)
        c = c.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context) {") # State build already has ref accessible
    else:
        c = re.sub(r"class (\w+) extends GetView<\w+>", r"class \1 extends ConsumerWidget", c)
        c = re.sub(r"class (\w+) extends StatelessWidget", r"class \1 extends ConsumerWidget", c)
        c = c.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context, WidgetRef ref) {")
        
        # Inject controller & state for GetView equivalents
        if "Widget build(BuildContext context, WidgetRef ref) {" in c:
            provider = "settingsControllerProvider" if "SettingsController" in c or "settings" in path else "dashboardControllerProvider"
            injection = f"\n    final controller = ref.read({provider}.notifier);\n    final state = ref.watch({provider});\n"
            c = c.replace("Widget build(BuildContext context, WidgetRef ref) {", "Widget build(BuildContext context, WidgetRef ref) {" + injection)

    # 4. Routing
    c = re.sub(r"Get\.toNamed\((.*?)\)", r"context.push(\1)", c)
    c = re.sub(r"Get\.offAllNamed\((.*?)\)", r"context.go(\1)", c)
    c = re.sub(r"Get\.back\((.*?)\)", r"if (context.mounted) context.pop(\1)", c)

    # 5. Dialogs & Snackbars
    c = re.sub(r"Get\.dialog\((.*?)\);", r"showDialog(context: context, builder: (context) => \1);", c, flags=re.DOTALL)
    def snack_repl(m):
        t = m.group(1).strip()
        msg = m.group(2).strip()
        return f"ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text({t} + ': ' + {msg})));"
    c = re.sub(r"Get\.snackbar\(\s*(.*?),\s*(.*?)(?:,|\))(.*?);", snack_repl, c, flags=re.DOTALL)

    # 6. Variables (controller.xxx.value -> state.xxx)
    c = re.sub(r"controller\.([a-zA-Z0-9_]+)\.value", r"state.\1", c)

    # 7. Obx
    c = c.replace("Obx(() {", "Consumer(builder: (context, ref, _) {")
    c = c.replace("Obx(() =>", "Consumer(builder: (context, ref, _) =>")

    with open(path, 'w') as f: f.write(c)


process_file("lib/features/room/presentation/widgets/room_management_dialogs.dart")
process_file("lib/features/settings/presentation/pages/settings_view.dart")
process_file("lib/features/settings/presentation/widgets/add_device_dialog.dart", is_stateful=True)
process_file("lib/features/settings/presentation/widgets/device_placement_card.dart")
process_file("lib/features/settings/presentation/widgets/fcm_token_card.dart")
process_file("lib/features/settings/presentation/widgets/google_home_card.dart")
process_file("lib/features/settings/presentation/widgets/hub_config_card.dart")
process_file("lib/features/settings/presentation/widgets/matter_commissioning_dialog.dart", is_stateful=True)
process_file("lib/features/settings/presentation/widgets/profile_card.dart")

