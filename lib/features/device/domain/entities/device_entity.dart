import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
// Exports of subclasses for backwards compatibility
export 'device_entity_compat.dart';
export 'ac_ir_codes.dart';
export 'vacuum_device_entity.dart';
export 'ac_device_entity.dart';
export 'lamp_device_entity.dart';
export 'rgb_lamp_device_entity.dart';
export 'door_device_entity.dart';

enum DeviceType { vacuum, airConditioner, lamp, door, rgb }

abstract class DeviceEntity extends Equatable {
  final String id;
  final String name;
  final DeviceType type;
  final bool isOn;
  final String? roomId;
  final IconData? icon;

  // Placement coordinates (normalized 0.0 to 1.0)
  final double? positionX;
  final double? positionY;

  // Display size in logical pixels (for room placement view)
  final double? markerWidth;
  final double? markerHeight;

  // Presentation style
  final bool showAsDot;

  // Matter fields
  final int? matterNodeId;
  final int? matterEndpointId;

  // ESP32 GPIO pin mapping
  final int? pin;

  const DeviceEntity({
    required this.id,
    required this.name,
    required this.type,
    this.isOn = false,
    this.roomId,
    this.icon,
    this.positionX,
    this.positionY,
    this.markerWidth,
    this.markerHeight,
    this.showAsDot = false,
    this.matterNodeId,
    this.matterEndpointId,
    this.pin,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isOn,
        roomId,
        positionX,
        positionY,
        markerWidth,
        markerHeight,
        showAsDot,
        matterNodeId,
        matterEndpointId,
        pin,
      ];
}