import 'package:flutter/material.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';

class RgbPage extends StatelessWidget {
  final DeviceEntity device;

  const RgbPage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Text(
          'RGB Control Page for ${device.name}',
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
