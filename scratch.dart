// ignore_for_file: avoid_print
import 'dart:convert';
import 'lib/features/device/data/models/ir_code_model.dart';

void main() {
  final jsonStr = jsonEncode({
    'protocol': 'PulseDistance',
    'value': '0x82131C810CF5AAA,0xE1B4008008',
    'bits': 104,
    'frequency': 38,
    'headerMark': 3800,
    'headerSpace': 1950,
    'oneMark': 400,
    'oneSpace': 1500,
    'zeroMark': 400,
    'zeroSpace': 550,
    'isMsb': false,
  });
  
  final entity = IrCodeModel.fromJson(jsonStr);
  print(entity.protocol);
  print(entity.toEsp32Payload());
}
