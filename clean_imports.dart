import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  final importRegexes = [
    RegExp(r"import 'package:smart_home/features/device/domain/entities/ac_device_entity\.dart';\n?"),
    RegExp(r"import 'package:smart_home/features/device/domain/entities/lamp_device_entity\.dart';\n?"),
    RegExp(r"import 'package:smart_home/features/device/domain/entities/rgb_lamp_device_entity\.dart';\n?"),
    RegExp(r"import 'package:smart_home/features/device/domain/entities/vacuum_device_entity\.dart';\n?"),
    RegExp(r"import 'package:smart_home/features/device/domain/entities/door_device_entity\.dart';\n?"),
    RegExp(r"import 'package:smart_home/features/device/domain/entities/ac_ir_codes\.dart';\n?"),
  ];

  int modified = 0;
  for (final file in files) {
    String content = file.readAsStringSync();
    bool changed = false;
    for (final reg in importRegexes) {
      if (reg.hasMatch(content)) {
        content = content.replaceAll(reg, '');
        changed = true;
      }
    }
    if (changed) {
      file.writeAsStringSync(content);
      modified++;
    }
  }
  print('Modified $modified files.');
}
