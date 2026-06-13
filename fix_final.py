import re
import os

def replace_file(path, replacements):
    if not os.path.exists(path): return
    with open(path, 'r') as f: c = f.read()
    for old, new in replacements.items(): c = c.replace(old, new)
    with open(path, 'w') as f: f.write(c)

# 1. placement_room_details.dart
replace_file("lib/features/room/presentation/widgets/placement_room_details.dart", {
    "controller.temperature": "state.temperature",
    "controller.humidity": "state.humidity",
    "controller.airflow": "state.airflow",
    "controller.powerUsage": "state.powerUsage",
})

# 2. room_management_dialogs.dart
# The ref is used inside showDialog. We can just use Consumer wrapping the dialog contents.
# Actually, the python script earlier didn't provide `ref` because showDialog creates a new context.
replace_file("lib/features/room/presentation/widgets/room_management_dialogs.dart", {
    "showDialog(context: context, builder: (context) =>": "showDialog(context: context, builder: (context) => Consumer(builder: (context, ref, _) =>",
    ");\n    }\n  }\n}": ");\n    } )) ;\n  }\n}" # Will need to carefully balance parentheses, or just use regex
})
# Let's fix room_management_dialogs using regex
p = "lib/features/room/presentation/widgets/room_management_dialogs.dart"
if os.path.exists(p):
    with open(p, 'r') as f: c = f.read()
    c = c.replace("showDialog(context: context, builder: (context) =>", "showDialog(context: context, builder: (context) => Consumer(builder: (context, ref, _) =>")
    c = re.sub(r'(\n\s*\}\s*\);?\s*\n\s*\})', r')\1', c) # just close the Consumer parent
    with open(p, 'w') as f: f.write(c)

# 3. settings_view.dart
replace_file("lib/features/settings/presentation/pages/settings_view.dart", {
    "class SettingsView extends GetView<SettingsController>": "class SettingsView extends ConsumerWidget",
    "class SettingsView extends ConsumerWidget": "class SettingsView extends ConsumerWidget",
})

# 4. add_device_dialog.dart
replace_file("lib/features/settings/presentation/widgets/add_device_dialog.dart", {
    "class AddDeviceDialog extends StatefulWidget": "class AddDeviceDialog extends ConsumerStatefulWidget",
    "class _AddDeviceDialogState extends State<AddDeviceDialog>": "class _AddDeviceDialogState extends ConsumerState<AddDeviceDialog>",
    "Widget build(BuildContext context) {": "Widget build(BuildContext context) {",
    "Widget build(BuildContext context, WidgetRef ref) {": "Widget build(BuildContext context) {",
    ".capitalizeFirst": ".substring(0, 1).toUpperCase() + type.substring(1)",
    "onPressed: () => _scanDevices(context)": "onPressed: () { _scanDevices(context); }" # Reverting back to block
})

# 5. device_placement_card.dart
replace_file("lib/features/settings/presentation/widgets/device_placement_card.dart", {
    "class DevicePlacementCard extends ConsumerWidget": "class DevicePlacementCard extends ConsumerWidget",
    "settingsControllerProvider": "dashboardControllerProvider",
})

# 6. fcm_token_card.dart
replace_file("lib/features/settings/presentation/widgets/fcm_token_card.dart", {
    "ref.watch(hasNotificationPermissionProvider)": "ref.watch(hasNotificationPermissionProvider)",
    "ref.watch(fcmTokenProvider)": "ref.watch(fcmTokenProvider)"
})

# 7. google_home_card.dart
replace_file("lib/features/settings/presentation/widgets/google_home_card.dart", {
    "onPressed: () => _showCommissioningDialog(context)": "onPressed: () { _showCommissioningDialog(context); }",
})

# 8. hub_config_card.dart
replace_file("lib/features/settings/presentation/widgets/hub_config_card.dart", {
    "controller.hubConnectionMode": "state.hubConnectionMode",
    "controller.updateHubConnectionMode": "controller.updateHubConnectionMode",
})

# 9. profile_card.dart
replace_file("lib/features/settings/presentation/widgets/profile_card.dart", {
    "controller.currentUser": "state.currentUser",
})

# 10. matter_commissioning_dialog.dart
replace_file("lib/features/settings/presentation/widgets/matter_commissioning_dialog.dart", {
    "if (context.mounted) { context.pop(); }": "if (context.mounted) context.pop();",
})

