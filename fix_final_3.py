import re
import os

def replace_file(path, replacements):
    if not os.path.exists(path): return
    with open(path, 'r') as f: c = f.read()
    for old, new in replacements.items(): c = c.replace(old, new)
    with open(path, 'w') as f: f.write(c)

# placement_room_details.dart
replace_file("lib/features/room/presentation/widgets/placement_room_details.dart", {
    "import 'package:get/get.dart';": "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';",
    "class PlacementRoomDetails extends GetView<DashboardController>": "class PlacementRoomDetails extends ConsumerWidget",
    "class PlacementRoomDetails extends StatelessWidget": "class PlacementRoomDetails extends ConsumerWidget",
    "Widget build(BuildContext context) {": "Widget build(BuildContext context, WidgetRef ref) {",
})
with open("lib/features/room/presentation/widgets/placement_room_details.dart", 'r') as f: c = f.read()
if "import 'package:flutter_riverpod/flutter_riverpod.dart';" not in c:
    c = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n" + c
    with open("lib/features/room/presentation/widgets/placement_room_details.dart", 'w') as f: f.write(c)

# placement_device_dialogs.dart
replace_file("lib/features/room/presentation/widgets/placement_device_dialogs.dart", {
    "child: Container(),,": "child: Container(),",
    "child: Container() ,": "child: Container(),",
    "child: Container(), }": "child: Container(),",
    "child: ,": "child: Container(),",
    "child: )": "child: Container())",
})
with open("lib/features/room/presentation/widgets/placement_device_dialogs.dart", 'r') as f: c = f.read()
c = re.sub(r"required child,", "child: Container(),", c)
with open("lib/features/room/presentation/widgets/placement_device_dialogs.dart", 'w') as f: f.write(c)

# placement_device_properties.dart
replace_file("lib/features/room/presentation/widgets/placement_device_properties.dart", {
    ".capitalizeFirst": ".substring(0, 1).toUpperCase() + name.substring(1)",
})

# placement_device_ir_controls.dart
replace_file("lib/features/room/presentation/widgets/placement_device_ir_controls.dart", {
    "dashboardController.sendingIrKeys": "ref.watch(dashboardControllerProvider).sendingIrKeys",
    "dashboardController.learnAndSaveIrCode(device.id, key)": "dashboardController.learnAndSaveIrCode(context, device.id, key)",
    "dashboardController.sendIrCommand(command)": "dashboardController.sendIrCommand(context, command)",
    "dashboardController.clearIrCode(device.id, key)": "dashboardController.clearIrCode(context, device.id, key)",
})

# add_device_dialog.dart
replace_file("lib/features/settings/presentation/widgets/add_device_dialog.dart", {
    "child: ,": "child: Container(),",
    "child: )": "child: Container())",
})
with open("lib/features/settings/presentation/widgets/add_device_dialog.dart", 'r') as f: c = f.read()
c = re.sub(r"required child,", "child: Container(),", c)
with open("lib/features/settings/presentation/widgets/add_device_dialog.dart", 'w') as f: f.write(c)


# settings_view.dart & hub_config_card.dart (duplicate declarations)
with open("lib/features/settings/presentation/pages/settings_view.dart", 'r') as f: c = f.read()
c = re.sub(r"(final state = ref.watch.*?)\1", r"\1", c, flags=re.DOTALL)
c = re.sub(r"(final controller = ref.read.*?)\1", r"\1", c, flags=re.DOTALL)
with open("lib/features/settings/presentation/pages/settings_view.dart", 'w') as f: f.write(c)

with open("lib/features/settings/presentation/widgets/hub_config_card.dart", 'r') as f: c = f.read()
c = re.sub(r"(final state = ref.watch.*?)\1", r"\1", c, flags=re.DOTALL)
c = re.sub(r"(final controller = ref.read.*?)\1", r"\1", c, flags=re.DOTALL)
with open("lib/features/settings/presentation/widgets/hub_config_card.dart", 'w') as f: f.write(c)


# Replace all remaining Get.xxx with context.xxx
import glob
for file in glob.glob("lib/**/*.dart", recursive=True):
    with open(file, 'r') as f: c = f.read()
    if "Get." in c:
        c = c.replace("Get.back()", "if (context.mounted) context.pop()")
        c = c.replace("Get.back();", "if (context.mounted) context.pop();")
        c = c.replace("Get.back", "if (context.mounted) context.pop")
        c = c.replace("Get.snackbar", "ScaffoldMessenger.of(context).showSnackBar")
        c = c.replace("Get.toNamed", "context.push")
        c = c.replace("Get.offAllNamed", "context.go")
        c = c.replace("Get.dialog", "showDialog(context: context, builder: (context) => ")
        c = c.replace("Get.find", "ref.read")
        with open(file, 'w') as f: f.write(c)


