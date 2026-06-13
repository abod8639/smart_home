with open('lib/core/services/esp32_service.dart', 'r') as f:
    lines = f.readlines()

new_lines = ["import 'package:flutter_riverpod/flutter_riverpod.dart';\n"] + lines
with open('lib/core/services/esp32_service.dart', 'w') as f:
    f.writelines(new_lines)
