import 'package:flutter/material.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/presentation/widgets/device_cards/widgets/ac_visualizer.dart';

class RemotePage extends StatelessWidget {
  final DeviceEntity device;
  const RemotePage({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(device.name),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          AcVisualizer(
            device: device,
            onDecreaseTemp: () {},
            onIncreaseTemp: () {},
            scale: 1.2,
          ),
          Container(
            color: Colors.red,
            child: Center(
              child: Text('Remote Page ${device.name} ${device.type}'),
            ),
          ),
        ],
      ),
    );
  }
}