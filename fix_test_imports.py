import re
with open('test/dashboard_controller_test.dart', 'r') as f:
    c = f.read()

# Replace GetX import with Riverpod
c = re.sub(r"import 'package:get/get\.dart';", "import 'package:flutter_riverpod/flutter_riverpod.dart';", c)

# Make sure we import dashboard_controller correctly, wait, it's already imported?
# Let's check if `createContainer` is defined
if "ProviderContainer createContainer" not in c:
    c = re.sub(r'void main\(\) \{', '''
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(overrides: overrides);
  addTearDown(container.dispose);
  return container;
}

void main() {
''', c)

with open('test/dashboard_controller_test.dart', 'w') as f:
    f.write(c)
