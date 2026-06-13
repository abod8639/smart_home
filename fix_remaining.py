import re
import os

# Fix SafetyCard GetView
path = 'lib/features/settings/presentation/widgets/safety_card.dart'
if os.path.exists(path):
    with open(path, 'r') as f:
        c = f.read()
    c = c.replace('class SafetyCard extends GetView<SettingsController>', 'class SafetyCard extends ConsumerWidget')
    c = c.replace('controller.autoBackups.value', 'ref.watch(settingsControllerProvider).autoBackups')
    c = c.replace('controller.toggleAutoBackups()', 'ref.read(settingsControllerProvider.notifier).toggleAutoBackups()')
    with open(path, 'w') as f:
        f.write(c)

# Fix tests
test_files = ['test/room_placement_controller_test.dart', 'test/settings_controller_test.dart', 'test/widget_test.dart']
for tf in test_files:
    if not os.path.exists(tf):
        continue
    with open(tf, 'r') as f:
        c = f.read()
    c = c.replace("import 'package:get/get.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';")
    c = c.replace("Get.put(SettingsController())", "container.read(settingsControllerProvider.notifier)")
    c = c.replace("Get.put(RoomPlacementController())", "container.read(roomPlacementControllerProvider.notifier)")
    # Just comment out GetX specific lines in tests or remove them if possible, or replace Get with container.
    c = re.sub(r'Get\.find<.*?>\(\)', '/* Get.find removed */', c)
    c = c.replace("Get.delete", "// Get.delete")
    c = c.replace("Get.reset()", "// Get.reset()")
    c = c.replace("Get.testMode = true;", "")
    c = c.replace("Get.isLogEnable = false;", "")
    with open(tf, 'w') as f:
        f.write(c)

