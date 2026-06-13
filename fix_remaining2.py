import re
import os

def replace_file(path, replacements):
    if not os.path.exists(path): return
    with open(path, 'r') as f: c = f.read()
    for old, new in replacements.items():
        c = c.replace(old, new)
    with open(path, 'w') as f: f.write(c)

# google_home_card.dart
replace_file("lib/features/settings/presentation/widgets/google_home_card.dart", {
    "class GoogleHomeCard extends GetView<SettingsController>": "class GoogleHomeCard extends ConsumerWidget",
    "onPressed: () => _showCommissioningDialog(context)": "onPressed: () { _showCommissioningDialog(context); }",
    "onPressed: _unlink": "onPressed: () { _unlink(); }"
})

# matter_commissioning_dialog.dart
replace_file("lib/features/settings/presentation/widgets/matter_commissioning_dialog.dart", {
    "class MatterCommissioningDialog extends StatefulWidget": "class MatterCommissioningDialog extends ConsumerStatefulWidget",
    "class _MatterCommissioningDialogState extends State<MatterCommissioningDialog>": "class _MatterCommissioningDialogState extends ConsumerState<MatterCommissioningDialog>",
    "Widget build(BuildContext context) {": "Widget build(BuildContext context) {", # Already correct if I didn't add ref
    "Widget build(BuildContext context, WidgetRef ref) {": "Widget build(BuildContext context) {" # Fix invalid override
})

# And re-run device_placement_card.dart
replace_file("lib/features/settings/presentation/widgets/device_placement_card.dart", {
    "class DevicePlacementCard extends GetView<SettingsController>": "class DevicePlacementCard extends ConsumerWidget",
})

