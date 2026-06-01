import 'dart:convert';
import 'lib/features/device/domain/entities/ir_code_entity.dart';

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
  
  final entity = IrCodeEntity.fromJson(jsonStr);
  print(entity.protocol);
  print(entity.toEsp32Payload());
}
