import re
import os

def replace_file(path, replacements):
    if not os.path.exists(path): return
    with open(path, 'r') as f: c = f.read()
    for old, new in replacements.items(): c = c.replace(old, new)
    with open(path, 'w') as f: f.write(c)

# placement_image_panel.dart
replace_file("lib/features/room/presentation/widgets/placement_image_panel.dart", {
    "dashboardController.devices": "ref.watch(dashboardControllerProvider).devices",
    "placementController.selectedDeviceId.value": "ref.watch(roomPlacementControllerProvider).selectedDeviceId",
    "placementController.selectedDeviceId": "ref.watch(roomPlacementControllerProvider).selectedDeviceId",
})

# placement_room_details.dart
replace_file("lib/features/room/presentation/widgets/placement_room_details.dart", {
    "dashboardController.devices": "ref.watch(dashboardControllerProvider).devices",
    "dashboardController.temperature": "ref.watch(dashboardControllerProvider).temperature",
    "dashboardController.humidity": "ref.watch(dashboardControllerProvider).humidity",
    "dashboardController.airflow": "ref.watch(dashboardControllerProvider).airflow",
    "dashboardController.powerUsage": "ref.watch(dashboardControllerProvider).powerUsage",
    "buildDeviceCards(),": "buildDeviceCards(context, ref)," # not enough positional arguments
})

# room_management_dialogs.dart
p = "lib/features/room/presentation/widgets/room_management_dialogs.dart"
if os.path.exists(p):
    with open(p, 'r') as f: c = f.read()
    # Remove the broken showDialog
    c = c.replace("showDialog(context: context, builder: (context) => Consumer(builder: (context, ref, _) =>", "showDialog(context: context, builder: (context) =>")
    c = c.replace("Get.back()", "if (context.mounted) context.pop()")
    c = c.replace("Get.back();", "if (context.mounted) context.pop();")
    c = c.replace("Get.back", "if (context.mounted) context.pop")
    c = c.replace("Get.dialog(", "showDialog(context: context, builder: (context) => ")
    # Fix the missing parenthesis from showDialog
    c = re.sub(r'(showDialog\(context: context, builder: \(context\) =>.*?);', r'\1;', c, flags=re.DOTALL) # Need manual fix for showDialog closing if missing
    with open(p, 'w') as f: f.write(c)

# add_device_dialog.dart
replace_file("lib/features/settings/presentation/widgets/add_device_dialog.dart", {
    "State<AddDeviceDialog> createState()": "ConsumerState<AddDeviceDialog> createState()",
    "Get.back()": "if (context.mounted) context.pop()",
    "Get.snackbar": "ScaffoldMessenger.of(context).showSnackBar",
    ".capitalizeFirst": ".substring(0, 1).toUpperCase() + type.name.substring(1)", # type is likely an enum
    "required child,": "child: Container(),", # "The named parameter 'child' is required"
})

# device_placement_card.dart
replace_file("lib/features/settings/presentation/widgets/device_placement_card.dart", {
    "settingsControllerProvider": "dashboardControllerProvider",
    "controller.devices": "state.devices",
    "controller.updateDevicePosition": "controller.updateDevicePosition",
})

# fcm_token_card.dart
replace_file("lib/features/settings/presentation/widgets/fcm_token_card.dart", {
    "settingsControllerProvider": "notificationServiceProvider",
    "Get.snackbar": "ScaffoldMessenger.of(context).showSnackBar",
    "state.hasPermission": "ref.watch(hasNotificationPermissionProvider)",
    "state.fcmToken": "ref.watch(fcmTokenProvider)",
})

# google_home_card.dart
replace_file("lib/features/settings/presentation/widgets/google_home_card.dart", {
    "onPressed: () => _showCommissioningDialog(context)": "onPressed: () { _showCommissioningDialog(context); }",
    "onPressed: () => _unlink()": "onPressed: () { _unlink(); }"
})

# hub_config_card.dart
replace_file("lib/features/settings/presentation/widgets/hub_config_card.dart", {
    "controller.hubConnectionMode.value": "state.hubConnectionMode",
    "controller.hubConnectionMode": "state.hubConnectionMode",
    "controller.updateHubConnectionMode": "controller.updateHubConnectionMode",
})

# matter_commissioning_dialog.dart
replace_file("lib/features/settings/presentation/widgets/matter_commissioning_dialog.dart", {
    "State<MatterCommissioningDialog> createState()": "ConsumerState<MatterCommissioningDialog> createState()",
    "Get.back()": "if (context.mounted) context.pop()",
})

# profile_card.dart
replace_file("lib/features/settings/presentation/widgets/profile_card.dart", {
    "controller.currentUser": "state.currentUser",
    "controller.logout": "controller.logout",
})

