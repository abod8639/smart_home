import 'dart:convert';

/// Supported IR protocol types as returned by IRremote library
enum IrProtocol {
  pulseDistance, // AC remotes (Mitsubishi, Daikin, etc.)
  pulseWidth,
  nec,
  samsung,
  sony,
  lg,
  panasonic,
  denon,
  sharp,
  jvc,
  rc5,
  rc6,
  raw,
  unknown,
}

/// Immutable model for a single captured IR code.
/// Can be serialized to/from JSON string for Hive storage.
class IrCodeEntity {
  final IrProtocol protocol;

  /// Hex words for PulseDistance/PulseWidth/standard protocols
  /// e.g. "0x72111C810CF5AAA,0x1B0258008"
  final String value;

  /// Number of bits (e.g. 104 for AC, 32 for Samsung)
  final int bits;

  // ── Timing fields for PulseDistance / PulseWidth protocols ──────────────
  final int? frequency;    // kHz (default 38)
  final int? headerMark;   // µs
  final int? headerSpace;  // µs
  final int? oneMark;      // µs
  final int? oneSpace;     // µs
  final int? zeroMark;     // µs
  final int? zeroSpace;    // µs
  final bool? isMsb;       // bit order

  // ── Standard protocol fields (Samsung, NEC, LG, ...) ─────────────────────
  final int? address;   // decoded address
  final int? command;   // decoded command
  final int? rawData;   // 32-bit raw data word (for single-word protocols)

  const IrCodeEntity({
    required this.protocol,
    required this.value,
    required this.bits,
    this.frequency,
    this.headerMark,
    this.headerSpace,
    this.oneMark,
    this.oneSpace,
    this.zeroMark,
    this.zeroSpace,
    this.isMsb,
    this.address,
    this.command,
    this.rawData,
  });

  // ── Serialization ─────────────────────────────────────────────────────────

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

  factory IrCodeEntity.fromMap(Map<String, dynamic> map) {
    return IrCodeEntity(
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

  /// Encode to JSON string for storage in Hive (DeviceEntity IR fields)
  String toJson() => jsonEncode(toMap());

  /// Decode from JSON string stored in Hive
  factory IrCodeEntity.fromJson(String json) {
    return IrCodeEntity.fromMap(
      Map<String, dynamic>.from(jsonDecode(json) as Map),
    );
  }

  /// Returns the map that should be sent as HTTP body to ESP32 /control/ir/send
  Map<String, dynamic> toEsp32Payload() => toMap();

  bool get isPulseProtocol =>
      protocol == IrProtocol.pulseDistance ||
      protocol == IrProtocol.pulseWidth;

  /// True when the code has the minimum fields required for storage/send.
  bool get isValid => value.trim().isNotEmpty && bits > 0;

  /// Verifies JSON encode/decode preserves the ESP32 send payload.
  bool verifyRoundtrip() {
    final restored = IrCodeEntity.fromJson(toJson());
    final original = toEsp32Payload();
    final roundtripped = restored.toEsp32Payload();
    if (original.length != roundtripped.length) return false;
    for (final entry in original.entries) {
      if (roundtripped[entry.key] != entry.value) return false;
    }
    return true;
  }

  @override
  String toString() => 'IrCodeEntity(protocol: $protocol, bits: $bits)';

  // ── Protocol name helpers ─────────────────────────────────────────────────

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
