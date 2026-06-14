import 'dart:convert';
import '../../domain/entities/ir_code_entity.dart';

/// Data Transfer Object (DTO) for [IrCodeEntity] handling serialization/deserialization.
class IrCodeModel extends IrCodeEntity {
  /// Creates a constant [IrCodeModel] instance.
  const IrCodeModel({
    required super.protocol,
    required super.value,
    required super.bits,
    super.frequency,
    super.headerMark,
    super.headerSpace,
    super.oneMark,
    super.oneSpace,
    super.zeroMark,
    super.zeroSpace,
    super.isMsb,
    super.address,
    super.command,
    super.rawData,
  });

  /// Creates a [IrCodeModel] from a base [IrCodeEntity].
  factory IrCodeModel.fromEntity(IrCodeEntity entity) {
    return IrCodeModel(
      protocol: entity.protocol,
      value: entity.value,
      bits: entity.bits,
      frequency: entity.frequency,
      headerMark: entity.headerMark,
      headerSpace: entity.headerSpace,
      oneMark: entity.oneMark,
      oneSpace: entity.oneSpace,
      zeroMark: entity.zeroMark,
      zeroSpace: entity.zeroSpace,
      isMsb: entity.isMsb,
      address: entity.address,
      command: entity.command,
      rawData: entity.rawData,
    );
  }

  /// Converts this model into a map of timing and protocol parameters.
  Map<String, dynamic> toMap() {
    return {
      'protocol': _protocolToString(protocol),
      'value': value,
      'bits': bits,
      if (frequency != null) 'frequency': frequency,
      if (headerMark != null) 'headerMark': headerMark,
      if (headerSpace != null) 'headerSpace': headerSpace,
      if (oneMark != null) 'oneMark': oneMark,
      if (oneSpace != null) 'oneSpace': oneSpace,
      if (zeroMark != null) 'zeroMark': zeroMark,
      if (zeroSpace != null) 'zeroSpace': zeroSpace,
      if (isMsb != null) 'isMsb': isMsb,
      if (address != null) 'address': address,
      if (command != null) 'command': command,
      if (rawData != null) 'rawData': rawData,
    };
  }

  /// Restores a [IrCodeModel] from a map structure.
  factory IrCodeModel.fromMap(Map<String, dynamic> map) {
    return IrCodeModel(
      protocol: _protocolFromString(map['protocol'] as String? ?? 'unknown'),
      value: map['value'] as String? ?? '',
      bits: (map['bits'] as num?)?.toInt() ?? 0,
      frequency: (map['frequency'] as num?)?.toInt(),
      headerMark: (map['headerMark'] as num?)?.toInt(),
      headerSpace: (map['headerSpace'] as num?)?.toInt(),
      oneMark: (map['oneMark'] as num?)?.toInt(),
      oneSpace: (map['oneSpace'] as num?)?.toInt(),
      zeroMark: (map['zeroMark'] as num?)?.toInt(),
      zeroSpace: (map['zeroSpace'] as num?)?.toInt(),
      isMsb: map['isMsb'] as bool?,
      address: (map['address'] as num?)?.toInt(),
      command: (map['command'] as num?)?.toInt(),
      rawData: (map['rawData'] as num?)?.toInt(),
    );
  }

  /// Encodes this model as a JSON string.
  String toJson() => jsonEncode(toMap());

  /// Decodes an [IrCodeModel] from a JSON string.
  factory IrCodeModel.fromJson(String json) {
    return IrCodeModel.fromMap(
      Map<String, dynamic>.from(jsonDecode(json) as Map),
    );
  }

  /// Returns the JSON-serializable map sent to the ESP32 controller.
  Map<String, dynamic> toEsp32Payload() => toMap();

  /// Verifies that serializing and deserializing this model results in identical data.
  bool verifyRoundtrip() {
    final restored = IrCodeModel.fromJson(toJson());
    final original = toEsp32Payload();
    final roundtripped = restored.toEsp32Payload();
    if (original.length != roundtripped.length) return false;
    for (final entry in original.entries) {
      if (roundtripped[entry.key] != entry.value) return false;
    }
    return true;
  }

  static String _protocolToString(IrProtocol p) {
    switch (p) {
      case IrProtocol.pulseDistance: return 'PULSE_DISTANCE';
      case IrProtocol.pulseWidth:    return 'PULSE_WIDTH';
      case IrProtocol.nec:           return 'NEC';
      case IrProtocol.samsung:       return 'SAMSUNG';
      case IrProtocol.sony:          return 'SONY';
      case IrProtocol.lg:            return 'LG';
      case IrProtocol.panasonic:     return 'PANASONIC';
      case IrProtocol.denon:         return 'DENON';
      case IrProtocol.sharp:         return 'SHARP';
      case IrProtocol.jvc:           return 'JVC';
      case IrProtocol.rc5:           return 'RC5';
      case IrProtocol.rc6:           return 'RC6';
      case IrProtocol.raw:           return 'RAW';
      case IrProtocol.unknown:       return 'UNKNOWN';
    }
  }

  static IrProtocol _protocolFromString(String s) {
    switch (s.toUpperCase().replaceAll('_', '')) {
      case 'PULSEDISTANCE': return IrProtocol.pulseDistance;
      case 'PULSEWIDTH':    return IrProtocol.pulseWidth;
      case 'NEC':            return IrProtocol.nec;
      case 'SAMSUNG':        return IrProtocol.samsung;
      case 'SONY':           return IrProtocol.sony;
      case 'LG':             return IrProtocol.lg;
      case 'PANASONIC':      return IrProtocol.panasonic;
      case 'DENON':          return IrProtocol.denon;
      case 'SHARP':          return IrProtocol.sharp;
      case 'JVC':            return IrProtocol.jvc;
      case 'RC5':            return IrProtocol.rc5;
      case 'RC6':            return IrProtocol.rc6;
      case 'RAW':            return IrProtocol.raw;
      default:               return IrProtocol.unknown;
    }
  }
}
