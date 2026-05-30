import 'package:get/get.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/features/device/domain/entities/device_entity.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';

/// Controller that manages IR learning & sending for a single DeviceEntity.
/// Inject per AC device screen/binding.
class IrController extends GetxController {
  final Esp32Service _esp32 = Get.find<Esp32Service>();

  // ── Reactive state ─────────────────────────────────────────────────────────
  final isLearning = false.obs;
  final isSending = false.obs;
  final errorMessage = Rxn<String>();
  final lastLearnedCode = Rxn<IrCodeEntity>();

  // ── Supported IR command slots ─────────────────────────────────────────────
  static const List<String> slots = [
    'irPower',
    'irTempUp',
    'irTempDown',
    'irAuto',
    'irCool',
    'irHeat',
    'irEco',
  ];

  /// Learns a new IR code from the remote.
  /// Returns the [IrCodeEntity] on success, null on failure.
  Future<IrCodeEntity?> learnCode() async {
    isLearning.value = true;
    errorMessage.value = null;

    final result = await _esp32.learnIrCode();

    isLearning.value = false;

    if (result.isSuccess && result.data != null) {
      lastLearnedCode.value = result.data;
      return result.data;
    } else {
      errorMessage.value = result.errorMessage;
      return null;
    }
  }

  /// Sends a previously stored IR code to the ESP32.
  Future<bool> sendCode(IrCodeEntity code) async {
    isSending.value = true;
    errorMessage.value = null;

    final result = await _esp32.sendIrCode(code);

    isSending.value = false;

    if (!result.isSuccess) {
      errorMessage.value = result.errorMessage;
    }

    return result.isSuccess;
  }

  /// Sends the IR code stored in the given slot of [device].
  /// [slot] must be one of [slots] (e.g. 'irPower').
  Future<bool> sendSlot(DeviceEntity device, String slot) async {
    final jsonStr = _getSlotValue(device, slot);
    if (jsonStr == null) {
      errorMessage.value = 'No IR code saved for "$slot"';
      return false;
    }
    try {
      final code = IrCodeEntity.fromJson(jsonStr);
      return sendCode(code);
    } catch (e) {
      errorMessage.value = 'Corrupted IR code for "$slot"';
      return false;
    }
  }

  /// Encodes an [IrCodeEntity] to a JSON string ready for storage in
  /// [DeviceEntity] (e.g. device.irPower).
  static String encodeForStorage(IrCodeEntity code) => code.toJson();

  /// Decodes a stored JSON string back to [IrCodeEntity]. Returns null if
  /// the string is null or malformed.
  static IrCodeEntity? decodeFromStorage(String? jsonStr) {
    if (jsonStr == null) return null;
    try {
      return IrCodeEntity.fromJson(jsonStr);
    } catch (_) {
      return null;
    }
  }

  /// Returns true if [device] has an IR code saved for [slot].
  static bool hasCode(DeviceEntity device, String slot) {
    return _getSlotValue(device, slot) != null;
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static String? _getSlotValue(DeviceEntity device, String slot) {
    switch (slot) {
      case 'irPower':    return device.irPower;
      case 'irTempUp':   return device.irTempUp;
      case 'irTempDown': return device.irTempDown;
      case 'irAuto':     return device.irAuto;
      case 'irCool':     return device.irCool;
      case 'irHeat':     return device.irHeat;
      case 'irEco':      return device.irEco;
      default:           return null;
    }
  }
}
