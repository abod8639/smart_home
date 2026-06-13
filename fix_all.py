import os
import re

def process_file(path):
    if not os.path.exists(path): return
    with open(path, 'r') as f:
        c = f.read()

    # Generic GetX replacements
    c = c.replace("Get.back()", "if (context.mounted) context.pop()")
    c = c.replace("Get.back();", "if (context.mounted) context.pop();")
    c = c.replace("Get.snackbar", "ScaffoldMessenger.of(context).showSnackBar")
    
    # placement_room_details.dart
    if "PlacementRoomDetails" in c:
        c = c.replace("extends StatelessWidget", "extends ConsumerWidget")
        c = c.replace("Widget build(BuildContext context) {", "Widget build(BuildContext context, WidgetRef ref) {")
        c = c.replace("buildDeviceCards(context, ref)", "buildDeviceCards(ref, context)")

    # placement_device_dialogs.dart
    if "PlacementDeviceDialogs" in c:
        c = c.replace("import 'package:get/get.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';")
        c = c.replace("Obx(() {", "Consumer(builder: (context, ref, _) {")
        c = c.replace("Obx(() =>", "Consumer(builder: (context, ref, _) =>")
        c = c.replace("child: Container(),,", "child: Container(),")

    # placement_device_ir_controls.dart
    if "placement_device_ir_controls" in path or "PlacementDeviceIrControls" in c:
        c = c.replace("dashboardController.sendingIrKeys", "ref.watch(dashboardControllerProvider).sendingIrKeys")
        
    # placement_image_panel.dart
    if "PlacementImagePanel" in c:
        c = c.replace("placementController.selectedDeviceId.value", "ref.watch(roomPlacementControllerProvider).selectedDeviceId")
        c = c.replace("placementController.selectedDeviceId?.value", "ref.watch(roomPlacementControllerProvider).selectedDeviceId")

    # google_home_card.dart
    if "GoogleHomeCard" in c:
        c = c.replace("onPressed: () { _showCommissioningDialog(context); }", "onPressed: () => _showCommissioningDialog(context)")

    # hub_config_card.dart
    if "HubConfigCard" in c:
        c = c.replace("Widget build(BuildContext context, WidgetRef ref) {", "Widget build(BuildContext context, WidgetRef ref) {\n    final state = ref.watch(settingsControllerProvider);\n    final controller = ref.read(settingsControllerProvider.notifier);")

    # profile_card.dart
    if "ProfileCard" in c:
        if "final state = ref.watch(settingsControllerProvider);" not in c:
            c = c.replace("Widget build(BuildContext context, WidgetRef ref) {", "Widget build(BuildContext context, WidgetRef ref) {\n    final state = ref.watch(settingsControllerProvider);\n    final controller = ref.read(settingsControllerProvider.notifier);")

    # matter_commissioning_dialog.dart
    if "MatterCommissioningDialog" in c:
        c = c.replace("Get.back()", "if (context.mounted) context.pop()")

    with open(path, 'w') as f:
        f.write(c)


for root, dirs, files in os.walk("lib"):
    for file in files:
        if file.endswith(".dart"):
            process_file(os.path.join(root, file))

