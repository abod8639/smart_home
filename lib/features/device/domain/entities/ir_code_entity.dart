
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

/// Immutable entity representing a captured Infrared (IR) remote command.
/// 
/// This is a pure domain entity and does not contain serialization/deserialization logic.
class IrCodeEntity {
  /// The IR transmission protocol (e.g., NEC, Samsung, PulseDistance).
  final IrProtocol protocol;

  /// Hexadecimal string representation of the captured IR code.
  /// 
  /// For multi-word AC protocols (e.g. PulseDistance), this can be comma-separated values,
  /// e.g. "0x72111C810CF5AAA,0x1B0258008".
  final String value;

  /// The number of bits in the transmission (e.g. 104 for AC, 32 for Samsung).
  final int bits;

  /// Carrier frequency of the IR signal in kHz (typically 38).
  final int? frequency;

  /// Header mark duration in microseconds (µs) for pulse-based protocols.
  final int? headerMark;

  /// Header space duration in microseconds (µs) for pulse-based protocols.
  final int? headerSpace;

  /// Duration in microseconds (µs) representing a logical '1' mark.
  final int? oneMark;

  /// Duration in microseconds (µs) representing a logical '1' space.
  final int? oneSpace;

  /// Duration in microseconds (µs) representing a logical '0' mark.
  final int? zeroMark;

  /// Duration in microseconds (µs) representing a logical '0' space.
  final int? zeroSpace;

  /// Whether the bit ordering is Most Significant Bit (MSB) first.
  final bool? isMsb;

  /// The decoded address word (if applicable for standard protocols).
  final int? address;

  /// The decoded command word (if applicable for standard protocols).
  final int? command;

  /// The 32-bit raw decoded data word.
  final int? rawData;

  /// Creates a constant [IrCodeEntity] instance.
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

  /// Returns true if this is a timing-sensitive pulse-based protocol (e.g. PulseDistance, PulseWidth).
  bool get isPulseProtocol =>
      protocol == IrProtocol.pulseDistance ||
      protocol == IrProtocol.pulseWidth;

  /// Returns true if the entity has minimum valid fields for transmission or storage.
  bool get isValid => value.trim().isNotEmpty && bits > 0;

  @override
  String toString() => 'IrCodeEntity(protocol: $protocol, bits: $bits)';
}
