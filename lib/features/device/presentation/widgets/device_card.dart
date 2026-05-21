import 'package:flutter/material.dart';
import '../../domain/entities/device_entity.dart';

class DeviceCard extends StatelessWidget {
  final DeviceEntity entity;

  const DeviceCard({super.key, required this.entity});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(entity.name),
        subtitle: Text(entity.id),
      ),
    );
  }
}
