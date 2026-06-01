import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_home/core/theme/app_theme.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';

class PlacementDeviceIrControls extends StatelessWidget {
  final DeviceEntity device;
  final DashboardController dashboardController;

  const PlacementDeviceIrControls({
    super.key,
    required this.device,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context) {
    if (device.type != DeviceType.airConditioner) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Divider(color: Colors.white10),
        const SizedBox(height: 12),
        const Text(
          'IR Remote Codes',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'You can copy and save the air conditioner remote buttons to control it directly through the ESP32 sensor.',
          style: TextStyle(color: AppTheme.textGrey, fontSize: 11),
        ),
        const SizedBox(height: 16),
        _buildIrRecordRow(
          context,
          label: 'Temp Up',
          savedValue: device.irTempUp,
          fieldKey: 'irTempUp',
        ),
        const SizedBox(height: 10),
        _buildIrRecordRow(
          context,
          label: 'Temp Down',
          savedValue: device.irTempDown,
          fieldKey: 'irTempDown',
        ),
        const SizedBox(height: 10),
        _buildIrRecordRow(
          context,
          label: 'Power',
          savedValue: device.irPower,
          fieldKey: 'irPower',
        ),
        const SizedBox(height: 10),
        _buildIrRecordRow(
          context,
          label: 'Auto Mode',
          savedValue: device.irAuto,
          fieldKey: 'irAuto',
        ),
        const SizedBox(height: 10),
        _buildIrRecordRow(
          context,
          label: 'Cool Mode',
          savedValue: device.irCool,
          fieldKey: 'irCool',
        ),
        const SizedBox(height: 10),
        _buildIrRecordRow(
          context,
          label: 'Heat Mode',
          savedValue: device.irHeat,
          fieldKey: 'irHeat',
        ),
        const SizedBox(height: 10),
        _buildIrRecordRow(
          context,
          label: 'Eco Mode',
          savedValue: device.irEco,
          fieldKey: 'irEco',
        ),
      ],
    );
  }

  Widget _buildIrRecordRow(
    BuildContext context, {
    required String label,
    required String? savedValue,
    required String fieldKey,
  }) {
    IrCodeEntity? code;
    if (savedValue != null) {
      try {
        code = IrCodeEntity.fromJson(savedValue);
      } catch (_) {}
    }
    final hasCode = code != null;
    final isMobile = Responsive.isMobile(context);
    final double padding = isMobile ? 10.0 : 14.0;
    final double titleFontSize = isMobile ? 12.0 : 13.0;
    final double rowGap = isMobile ? 6.0 : 10.0;
    final double iconBtnSize = isMobile ? 32.0 : 36.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasCode
              ? Colors.blueAccent.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Title row ─────────────────────────────────────────
          Row(
            children: [
              Container(
                width: isMobile ? 24 : 28,
                height: isMobile ? 24 : 28,
                decoration: BoxDecoration(
                  color: hasCode
                      ? Colors.green.withValues(alpha: 0.05)
                      : Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  hasCode ? Icons.check_rounded : Icons.radio_button_unchecked,
                  color: hasCode ? Colors.greenAccent : Colors.white30,
                  size: isMobile ? 14 : 16,
                ),
              ),
              SizedBox(width: rowGap),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: hasCode ? Colors.white : Colors.white60,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // ── Stored code info ──────────────────────────────────
          if (hasCode) ...[
            SizedBox(height: rowGap),
            _IrCodeInfoChips(code: code),
          ] else ...[
            SizedBox(height: rowGap - 2),
            const Text(
              'Not yet recorded',
              style: TextStyle(color: Colors.white30, fontSize: 11),
            ),
          ],

          SizedBox(height: rowGap + 2),

          // ── Action buttons ────────────────────────────────────
          Row(
            children: [
              // Record / Re-record button
              Expanded(
                child: _IrLearnButton(
                  hasCode: hasCode,
                  onTap: () => dashboardController.learnAndSaveIrCode(
                    device.id,
                    fieldKey,
                  ),
                ),
              ),
              if (hasCode) ...[
                SizedBox(width: rowGap),
                // Send button
                Obx(() {
                  final trackingKey =
                      dashboardController.irTrackingKey(device.id, fieldKey);
                  final isSending =
                      dashboardController.sendingIrKeys.contains(trackingKey);
                  return _IrSendButton(
                    isSending: isSending,
                    onTap: isSending
                        ? null
                        : () => dashboardController.sendIrCommand(
                              savedValue!,
                              trackingKey: trackingKey,
                            ),
                  );
                }),
                SizedBox(width: rowGap - 2),
                // Delete button
                SizedBox(
                  width: iconBtnSize,
                  height: iconBtnSize,
                  child: IconButton.outlined(
                    padding: EdgeInsets.zero,
                    icon: Icon(Icons.delete_outline,
                        size: isMobile ? 14 : 16, color: Colors.redAccent),
                    style: IconButton.styleFrom(
                      side: const BorderSide(color: Colors.redAccent, width: 0.8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    tooltip: 'Delete',
                    onPressed: () => dashboardController.clearIrCode(
                      device.id,
                      fieldKey,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ────────────────────────────────────────────────────────────────

/// Displays protocol/bits/address chips for a stored IR code
class _IrCodeInfoChips extends StatelessWidget {
  final IrCodeEntity code;
  const _IrCodeInfoChips({required this.code});

  @override
  Widget build(BuildContext context) {
    final chips = <_ChipData>[
      _ChipData(
        label: code.protocol.name.toUpperCase(),
        color: _protocolColor(code.protocol),
        icon: Icons.wifi_tethering_rounded,
      ),
      _ChipData(
        label: '${code.bits} bits',
        color: Colors.blueAccent,
        icon: Icons.memory_rounded,
      ),
      if (code.address != null)
        _ChipData(
          label: 'Addr: 0x${code.address!.toRadixString(16).toUpperCase()}',
          color: Colors.purpleAccent,
          icon: Icons.tag,
        ),
      if (code.command != null)
        _ChipData(
          label: 'Cmd: 0x${code.command!.toRadixString(16).toUpperCase()}',
          color: Colors.orangeAccent,
          icon: Icons.code_rounded,
        ),
      if (code.headerMark != null)
        _ChipData(
          label: 'H: ${code.headerMark}/${code.headerSpace} µs',
          color: Colors.tealAccent,
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
        // color: data.color.withValues(alpha: 0.12),
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

  static Color _protocolColor(IrProtocol p) {
    switch (p) {
      case IrProtocol.pulseDistance:
      case IrProtocol.pulseWidth:
        return Colors.cyanAccent;
      case IrProtocol.samsung:
        return Colors.blueAccent;
      case IrProtocol.nec:
        return Colors.greenAccent;
      case IrProtocol.sony:
        return Colors.yellowAccent;
      case IrProtocol.lg:
        return Colors.pinkAccent;
      case IrProtocol.raw:
        return Colors.deepOrangeAccent;
      default:
        return Colors.white54;
    }
  }
}

class _ChipData {
  final String label;
  final Color color;
  final IconData icon;
  const _ChipData({required this.label, required this.color, required this.icon});
}

/// Learn/Record button with animated state
class _IrLearnButton extends StatelessWidget {
  final bool hasCode;
  final VoidCallback onTap;
  const _IrLearnButton({required this.hasCode, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double btnHeight = isMobile ? 32.0 : 36.0;
    final double fontSize = isMobile ? 11.0 : 12.0;
    final double iconSize = isMobile ? 13.0 : 15.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: btnHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasCode
                ? [Colors.white.withValues(alpha: 0.07), Colors.white.withValues(alpha: 0.04)]
                : [
                    const Color(0xFF4C86FF).withValues(alpha: 0.3),
                    const Color(0xFF4C86FF).withValues(alpha: 0.15),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasCode
                ? Colors.white.withValues(alpha: 0.1)
                : const Color(0xFF4C86FF).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasCode ? Icons.replay_rounded : Icons.settings_remote_rounded,
              size: iconSize,
              color: hasCode ? Colors.white54 : const Color(0xFF4C86FF),
            ),
            const SizedBox(width: 4),
            Text(
              hasCode ? 'Re-Record' : 'Record',
              style: TextStyle(
                color: hasCode ? Colors.white54 : Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Send button with loading indicator
class _IrSendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback? onTap;
  const _IrSendButton({required this.isSending, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final double btnHeight = isMobile ? 32.0 : 36.0;
    final double padding = isMobile ? 10.0 : 14.0;
    final double fontSize = isMobile ? 11.0 : 12.0;
    final double iconSize = isMobile ? 13.0 : 14.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: btnHeight,
        padding: EdgeInsets.symmetric(horizontal: padding),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: isSending ? 0.05 : 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.greenAccent.withValues(alpha: isSending ? 0.2 : 0.4),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: isSending
              ? [
                  SizedBox(
                    width: isMobile ? 11 : 13,
                    height: isMobile ? 11 : 13,
                    child: CircularProgressIndicator(
                      strokeWidth: 1.8,
                      color: Colors.greenAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Sending...',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600),
                  ),
                ]
              : [
                  Icon(Icons.send_rounded, size: iconSize, color: Colors.greenAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Send',
                    style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600),
                  ),
                ],
        ),
      ),
    );
  }
}
