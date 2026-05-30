import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_matter/flutter_matter.dart';

class MatterResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  MatterResponse.success(this.data) : isSuccess = true, errorMessage = null;
  MatterResponse.failure(this.errorMessage) : isSuccess = false, data = null;
}

class MatterService extends GetxService {
  ChipDeviceController? _controller;

  @override
  void onInit() {
    super.onInit();
    debugPrint('MatterService initialized');
  }

  Future<ChipDeviceController> _getController() async {
    if (_controller != null) return _controller!;
    _controller = await ChipDeviceController.newControllerIfNotExist(ControllerParams());
    return _controller!;
  }

  /// Start BLE or On-network commissioning for a new device
  Future<MatterResponse<int>> commissionDevice({int? setupPinCode, String? onboardingPayload}) async {
    try {
      final controller = await _getController();
      final completer = Completer<int>();

      // Generate a unique device ID (node ID) for the new device
      final nodeId = DateTime.now().millisecondsSinceEpoch % 10000 + 1;

      // Create a CompletionListener to receive the provisioning lifecycle callbacks
      final listener = _MatterCompletionListener(
        onCommissioningCompleteCallback: (commissionedNodeId, errorCode) {
          if (errorCode == 0) {
            completer.complete(commissionedNodeId);
          } else {
            completer.completeError(Exception('Commissioning failed with error code: $errorCode'));
          }
        },
        onErrorCallback: (e) {
          completer.completeError(e);
        },
      );

      // Default WiFi credentials matching our global settings
      final wifiCredentials = WiFiCredentials(ssid: '>_', password: 'Qwertyuio0qwertyuio0');
      final networkCredentials = NetworkCredentials.wifi(wifiCredentials);

      debugPrint('Matter: Starting pairing with Node $nodeId, PIN: $setupPinCode');
      await controller.pairDevice(
        nodeId,
        null,
        setupPinCode,
        onboardingPayload,
        null,
        networkCredentials,
        completionListener: listener,
      );

      final resultNodeId = await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => throw TimeoutException('Commissioning timed out after 2 minutes'),
      );

      return MatterResponse.success(resultNodeId);
    } catch (e) {
      debugPrint('Commissioning failed: $e');
      return MatterResponse.failure(e.toString());
    }
  }

  /// Remove a device from the Matter fabric
  Future<MatterResponse<bool>> unpairDevice(int nodeId) async {
    try {
      final controller = await _getController();
      await controller.stopDevicePairing(nodeId);
      return MatterResponse.success(true);
    } catch (e) {
      return MatterResponse.failure(e.toString());
    }
  }

  /// Toggle On/Off state for a Matter device
  /// Cluster ID: 6 (OnOff), Command ID: 0 (Off), 1 (On)
  Future<MatterResponse<bool>> toggleDevice(int nodeId, int endpointId, bool isOn) async {
    try {
      final controller = await _getController();
      final completer = Completer<bool>();
      final callback = _MatterInvokeCallback(completer);
      
      final writer = TlvWriter();
      writer.startStructure(AnonymousTag.instance);
      writer.endStructure();
      
      final element = InvokeElement.create(
        endpointId,
        0x0006, // OnOff Cluster
        isOn ? 1 : 0, // Command: 1 = On, 0 = Off
        writer.getEncoded(),
        null,
      );

      debugPrint('Matter: Toggling Node $nodeId, Endpoint $endpointId to $isOn');
      await controller.invoke(callback, nodeId, element);
      
      final success = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Toggle command timed out'),
      );
      
      return MatterResponse.success(success);
    } catch (e) {
      debugPrint('Matter toggle failed: $e');
      return MatterResponse.failure(e.toString());
    }
  }

  /// Change Brightness / Level Control
  /// Cluster ID: 8 (LevelControl), Command ID: 0 (MoveToLevel)
  Future<MatterResponse<bool>> setBrightness(int nodeId, int endpointId, int level) async {
    try {
      final controller = await _getController();
      final completer = Completer<bool>();
      final callback = _MatterInvokeCallback(completer);
      
      final writer = TlvWriter();
      writer.startStructure(AnonymousTag.instance);
      writer.putUnsigned(ContextSpecificTag(0), level); // Field 0: Level (0-255)
      writer.putUnsigned(ContextSpecificTag(1), 0);     // Field 1: TransitionTime (0 = instant)
      writer.putUnsigned(ContextSpecificTag(2), 0);     // Field 2: OptionsMask
      writer.putUnsigned(ContextSpecificTag(3), 0);     // Field 3: OptionsOverride
      writer.endStructure();
      
      final element = InvokeElement.create(
        endpointId,
        0x0008, // LevelControl Cluster
        0,      // Command: MoveToLevel
        writer.getEncoded(),
        null,
      );

      debugPrint('Matter: Setting brightness Node $nodeId, Endpoint $endpointId to $level');
      await controller.invoke(callback, nodeId, element);
      
      final success = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Brightness command timed out'),
      );
      
      return MatterResponse.success(success);
    } catch (e) {
      debugPrint('Matter brightness failed: $e');
      return MatterResponse.failure(e.toString());
    }
  }

  /// Change RGB Color (Color Control)
  /// Cluster ID: 0x0300, Command ID: 6 (MoveToHueAndSaturation)
  Future<MatterResponse<bool>> setColor(int nodeId, int endpointId, int r, int g, int b) async {
    try {
      final controller = await _getController();
      final completer = Completer<bool>();
      final callback = _MatterInvokeCallback(completer);

      // Convert RGB to HSV
      final hsv = _rgbToHsv(r, g, b);
      final hue = (hsv.hue * 254).round().clamp(0, 254);
      final saturation = (hsv.saturation * 254).round().clamp(0, 254);

      final writer = TlvWriter();
      writer.startStructure(AnonymousTag.instance);
      writer.putUnsigned(ContextSpecificTag(0), hue);         // Field 0: Hue (0-254)
      writer.putUnsigned(ContextSpecificTag(1), saturation);  // Field 1: Saturation (0-254)
      writer.putUnsigned(ContextSpecificTag(2), 0);           // Field 2: TransitionTime (0 = instant)
      writer.putUnsigned(ContextSpecificTag(3), 0);           // Field 3: OptionsMask
      writer.putUnsigned(ContextSpecificTag(4), 0);           // Field 4: OptionsOverride
      writer.endStructure();
      
      final element = InvokeElement.create(
        endpointId,
        0x0300, // ColorControl Cluster
        6,      // Command: MoveToHueAndSaturation
        writer.getEncoded(),
        null,
      );

      debugPrint('Matter: Setting color Node $nodeId, Endpoint $endpointId to RGB($r, $g, $b) -> HSV($hue, $saturation)');
      await controller.invoke(callback, nodeId, element);
      
      final success = await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Color command timed out'),
      );
      
      return MatterResponse.success(success);
    } catch (e) {
      debugPrint('Matter color failed: $e');
      return MatterResponse.failure(e.toString());
    }
  }

  _HSVColor _rgbToHsv(int r, int g, int b) {
    double rf = r / 255.0;
    double gf = g / 255.0;
    double bf = b / 255.0;

    double max = rf;
    if (gf > max) max = gf;
    if (bf > max) max = bf;

    double min = rf;
    if (gf < min) min = gf;
    if (bf < min) min = bf;

    double delta = max - min;
    double h = 0.0;
    double s = max == 0.0 ? 0.0 : delta / max;
    double v = max;

    if (delta != 0.0) {
      if (max == rf) {
        h = (gf - bf) / delta + (gf < bf ? 6.0 : 0.0);
      } else if (max == gf) {
        h = (bf - rf) / delta + 2.0;
      } else {
        h = (rf - gf) / delta + 4.0;
      }
      h /= 6.0;
    }

    return _HSVColor(h, s, v);
  }
}

class _HSVColor {
  final double hue;
  final double saturation;
  final double value;

  _HSVColor(this.hue, this.saturation, this.value);
}

class _MatterCompletionListener implements CompletionListener {
  final Function(int nodeId, int errorCode) onCommissioningCompleteCallback;
  final Function(Exception e) onErrorCallback;

  _MatterCompletionListener({
    required this.onCommissioningCompleteCallback,
    required this.onErrorCallback,
  });

  @override
  void onConnectDeviceComplete() {
    debugPrint('Matter: Connect device complete');
  }

  @override
  void onStatusUpdate(int status) {
    debugPrint('Matter: Status update: $status');
  }

  @override
  void onPairingComplete(int errorCode) {
    debugPrint('Matter: Pairing complete: $errorCode');
  }

  @override
  void onPairingDeleted(int errorCode) {
    debugPrint('Matter: Pairing deleted: $errorCode');
  }

  @override
  void onCommissioningComplete(int? nodeId, int errorCode) {
    debugPrint('Matter: Commissioning complete - Node: $nodeId, Error: $errorCode');
    onCommissioningCompleteCallback(nodeId ?? 1, errorCode);
  }

  @override
  void onReadCommissioningInfo(int vendorId, int productId, int wifiEndpointId, int threadEndpointId) {
    debugPrint('Matter: Read commissioning info - Vendor: $vendorId, Product: $productId');
  }

  @override
  void onCommissioningStatusUpdate(int nodeId, String stage, int errorCode) {
    debugPrint('Matter: Commissioning status update - Stage: $stage, Error: $errorCode');
  }

  @override
  void onNotifyChipConnectionClosed() {
    debugPrint('Matter: Connection closed');
  }

  @override
  void onError(Exception e) {
    debugPrint('Matter: Error: $e');
    onErrorCallback(e);
  }

  @override
  void onOpCSRGenerationComplete(Uint8List csr) {
    debugPrint('Matter: Operational CSR generation complete');
  }

  @override
  void onICDRegistrationInfoRequired() {
    debugPrint('Matter: ICD registration info required');
  }

  @override
  void onICDRegistrationComplete(int errorCode, ICDDeviceInfo? icdDeviceInfo) {
    debugPrint('Matter: ICD registration complete - Error: $errorCode');
  }
}

class _MatterInvokeCallback implements InvokeCallback {
  final Completer<bool> completer;

  _MatterInvokeCallback(this.completer);

  @override
  void onError(Exception e) {
    completer.completeError(e);
  }

  @override
  void onResponse(InvokeElement invokeElement, int successCode) {
    completer.complete(successCode == 0);
  }

  @override
  void onDone() {}
}
