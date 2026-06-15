import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/core/utils/responsive.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/device/data/models/ir_code_model.dart';
import 'ir_code_info_chips.dart';
import 'ir_learn_button.dart';
import 'ir_send_button.dart';

/// A card widget representing a single IR code entry with learning, sending, and clearing options.
class IrRecordRow extends ConsumerWidget {
  /// The device entity whose IR commands are managed.
  final DeviceEntity device;

  /// The label for the IR entry (e.g. 'Temp Up', 'Power').
  final String label;

  /// The raw stored JSON string of the IR code, if any.
  final String? savedValue;

  /// The field key in the device configuration (e.g. 'irPower', 'irTempUp').
  final String fieldKey;

  /// The dashboard controller instance.
  final DashboardController dashboardController;

  /// Creates an [IrRecordRow].
  const IrRecordRow({
    super.key,
    required this.device,
    required this.label,
    required this.savedValue,
    required this.fieldKey,
    required this.dashboardController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    IrCodeEntity? code;
    if (savedValue != null) {
      try {
        code = IrCodeModel.fromJson(savedValue!);
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
            IrCodeInfoChips(code: code),
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
                child: IrLearnButton(
                  hasCode: hasCode,
                  onTap: () => dashboardController.learnAndSaveIrCode(
                    context,
                    device.id,
                    fieldKey,
                  ),
                ),
              ),
              if (hasCode) ...[
                SizedBox(width: rowGap),
                // Send button
                Consumer(builder: (context, ref, _) {
                  final trackingKey =
                      dashboardController.irTrackingKey(device.id, fieldKey);
                  final isSending =
                      ref.watch(dashboardControllerProvider).sendingIrKeys.contains(trackingKey);
                  return IrSendButton(
                    isSending: isSending,
                    onTap: isSending
                        ? null
                        : () => dashboardController.sendIrCommand(
                              context,
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
                      context,
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
