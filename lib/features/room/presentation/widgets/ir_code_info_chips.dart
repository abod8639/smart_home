import 'package:flutter/material.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';

/// A widget that displays the protocol, bits, address, and command info chips
/// of a recorded IR code.
class IrCodeInfoChips extends StatelessWidget {
  /// The IR code entity whose details are displayed.
  final IrCodeEntity code;

  /// Creates an [IrCodeInfoChips].
  const IrCodeInfoChips({
    super.key,
    required this.code,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <_ChipData>[
      _ChipData(
        label: code.protocol.name.toUpperCase(),
        icon: Icons.wifi_tethering_rounded,
      ),
      _ChipData(
        label: '${code.bits} bits',
        icon: Icons.memory_rounded,
      ),
      if (code.address != null)
        _ChipData(
          label: 'Addr: 0x${code.address!.toRadixString(16).toUpperCase()}',
          icon: Icons.tag,
        ),
      if (code.command != null)
        _ChipData(
          label: 'Cmd: 0x${code.command!.toRadixString(16).toUpperCase()}',
          icon: Icons.code_rounded,
        ),
      if (code.headerMark != null)
        _ChipData(
          label: 'H: ${code.headerMark}/${code.headerSpace} µs',
          icon: Icons.timeline,
        ),
    ];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: chips.map((c) => _buildChip(c)).toList(),
    );
  }

  Widget _buildChip(_ChipData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: data.color.withValues(alpha: 0.3), width: 0.7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.icon, size: 10, color: data.color),
          const SizedBox(width: 4),
          Text(
            data.label,
            style: TextStyle(
              color: data.color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipData {
  final String label;
  final Color color;
  final IconData icon;
  const _ChipData({
    required this.label,
    required this.icon,
  }) : color = AppTheme.primaryBlue;
}
