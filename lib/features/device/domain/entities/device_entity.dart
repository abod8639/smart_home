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

/// The type of smart home device.
enum DeviceType {
  /// A robotic vacuum cleaner device.
  vacuum,
  /// An air conditioner device.
  airConditioner,
  /// A basic smart lamp/light.
  lamp,
  /// A smart door lock.
  door,
  /// An RGB led light strip/lamp.
  rgb
}

/// Abstract base class representing a smart home device.
/// 
/// All device entities in the system extend this class and inherit its common properties.
abstract class DeviceEntity extends Equatable {
  /// The unique identifier of the device.
  final String id;

  /// The human-readable name of the device.
  final String name;

  /// The category of the device.
  final DeviceType type;

  /// Whether the device is currently turned on.
  final bool isOn;

  /// The unique identifier of the room this device is placed in.
  final String? roomId;

  /// Icon representing the device in the user interface.
  final IconData? icon;

  /// Normalized X coordinate (0.0 to 1.0) of the device marker in the room layout.
  final double? positionX;

  /// Normalized Y coordinate (0.0 to 1.0) of the device marker in the room layout.
  final double? positionY;

  /// Explicit display width of the device marker in logical pixels.
  final double? markerWidth;

  /// Explicit display height of the device marker in logical pixels.
  final double? markerHeight;

  /// Whether to render this device as a simple dot instead of a full widget on the map.
  final bool showAsDot;

  /// The Matter node ID for Matter-compatible devices.
  final int? matterNodeId;

  /// The Matter endpoint ID for Matter-compatible devices.
  final int? matterEndpointId;

  /// The hardware GPIO pin number mapped on the ESP32.
  final int? pin;

  /// Creates a constant [DeviceEntity] instance.
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