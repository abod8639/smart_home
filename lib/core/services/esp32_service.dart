import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:smart_home/features/device/domain/entities/ir_code_entity.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

/// Generic response wrapper for ESP32 operations
class EspResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;

  EspResponse.success(this.data) : isSuccess = true, errorMessage = null;
  EspResponse.failure(this.errorMessage) : isSuccess = false, data = null;

  @override
  String toString() {
    if (isSuccess) return 'EspResponse: Success(data: $data)';
    return 'EspResponse: Failure(error: $errorMessage)';
  }
}

/// Professional and flexible control service for ESP32 microcontrollers
class Esp32Service extends GetxService {
  late final Dio _dio;
  
  // Retrieves SettingsController which holds the current reactive IP Address
  SettingsController get _settings => Get.find<SettingsController>();

  // Base URL computed dynamically from settings IP
  String get baseUrl => 'http://${_settings.ipAddress.value}';

  @override
  void onInit() { 
    super.onInit();
    
    // Configure Dio with appropriate timeouts for local hardware connections
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 4),
        receiveTimeout: const Duration(seconds: 4),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging interceptors for real-time ESP32 HTTP debugging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('--> ESP32 REQUEST: ${options.method} ${options.path}');
          debugPrint('Headers: ${options.headers}');
          debugPrint('Body data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('<-- ESP32 RESPONSE [${response.statusCode}] from ${response.requestOptions.path}');
          debugPrint('Response data: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('x-- ESP32 ERROR: ${e.message} from ${e.requestOptions.path}');
          return handler.next(e);
        },
      ),
    );
  }

  /// Ping ESP32 to test host reachability
  Future<EspResponse<bool>> pingHub() async {
    try {
      final response = await _dio.get('$baseUrl/ping');
      if (response.statusCode == 200) {
        return EspResponse.success(true);
      }
      return EspResponse.failure('Server returned status: ${response.statusCode}');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Read real-time sensor metrics (temperature, humidity, relays status, etc.)
  Future<EspResponse<Map<String, dynamic>>> getSensorData() async {
    try {
      final response = await _dio.get('$baseUrl/sensors');
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return EspResponse.success(response.data as Map<String, dynamic>);
      }
      return EspResponse.failure('Invalid sensor payload received');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Toggle a digital pin state / relay channel
  /// [pin] represents the GPIO number or pin name (e.g. 5 or "GPIO_5")
  /// [state] true/false state to output
  Future<EspResponse<bool>> setDigitalOutput(dynamic pin, bool state) async {
    try {
      final response = await _dio.post(
        '$baseUrl/control/digital',
        data: {
          'pin': pin,
          'value': state ? 1 : 0,
        },
      );
      if (response.statusCode == 200) {
        return EspResponse.success(true);
      }
      return EspResponse.failure('Digital control rejected by ESP32');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Write an analog/PWM duty cycle value (e.g. lamp dimming, AC speed)
  /// [pin] represents the PWM output channel/pin
  /// [value] integer value from 0 (off) to 255 (maximum duty cycle)
  Future<EspResponse<bool>> setAnalogOutput(dynamic pin, int value) async {
    try {
      final response = await _dio.post(
        '$baseUrl/control/analog',
        data: {
          'pin': pin,
          'value': value.clamp(0, 255),
        },
      );
      if (response.statusCode == 200) {
        return EspResponse.success(true);
      }
      return EspResponse.failure('PWM control rejected by ESP32');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Execute dynamic raw endpoints / payloads to support custom routes on your ESP32
  Future<EspResponse<dynamic>> sendRawCommand(
    String path, {
    String method = 'POST',
    dynamic data,
  }) async {
    try {
      final response = await _dio.request(
        '$baseUrl/$path',
        data: data,
        options: Options(method: method),
      );
      if (response.statusCode == 200) {
        return EspResponse.success(response.data);
      }
      return EspResponse.failure('Custom endpoint returned: ${response.statusCode}');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Starts IR remote code learning on the ESP32.
  /// Returns a typed [IrCodeEntity] on success.
  Future<EspResponse<IrCodeEntity>> learnIrCode() async {
    try {
      final response = await _dio.get(
        '$baseUrl/control/ir/learn',
        options: Options(
          receiveTimeout: const Duration(seconds: 12),
        ),
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        final code = IrCodeEntity.fromMap(data);
        return EspResponse.success(code);
      }
      return EspResponse.failure('IR learning rejected by ESP32');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Sends a recorded IR code via the ESP32 transmitter.
  Future<EspResponse<bool>> sendIrCode(IrCodeEntity irCode) async {
    try {
      final response = await _dio.post(
        '$baseUrl/control/ir/send',
        data: irCode.toEsp32Payload(),
      );
      if (response.statusCode == 200) {
        return EspResponse.success(true);
      }
      return EspResponse.failure('IR transmission rejected by ESP32');
    } on DioException catch (e) {
      return EspResponse.failure(_handleDioError(e));
    } catch (e) {
      return EspResponse.failure(e.toString());
    }
  }

  /// Convert Dio errors to clean user-friendly messages for debugging hardware networks
  String _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return 'Timeout connecting to ESP32. Verify device IP address and local router routing.';
      case DioExceptionType.receiveTimeout:
        return 'ESP32 failed to return response payload within timeout parameters.';
      case DioExceptionType.sendTimeout:
        return 'Upload request timeout while contacting ESP32.';
      case DioExceptionType.badResponse:
        return 'ESP32 returned error status: ${error.response?.statusCode}';
      case DioExceptionType.connectionError:
        return 'Host unreachable. Ensure the ESP32 is powered on and connected to the same local Wi-Fi.';
      case DioExceptionType.cancel:
        return 'Network transaction cancelled.';
      default:
        return 'Hardware network error: ${error.message}';
    }
  }
  
}
