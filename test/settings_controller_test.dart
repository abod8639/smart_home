import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/core/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'MQTT_BROKER_URL=broker.hivemq.com');
  });

  group('SettingsController Unit Tests', () {
    test('Initial configuration values are loaded correctly', () {
      final controller = Get.put(SettingsController());
      expect(controller.userName.value, 'Dexter');
      expect(controller.userRole.value, 'Administrator');
      expect(controller.isCelsius.value, isTrue);
      expect(controller.notificationsEnabled.value, isTrue);
      expect(controller.lockTimeout.value, 5.0);
      expect(controller.autoBackups.value, isTrue);
    });

    test('updateUserName updates user name correctly', () {
      final controller = Get.put(SettingsController());
      controller.updateUserName('Sarah Connor');
      expect(controller.userName.value, 'Sarah Connor');

      // Empty names should be ignored
      controller.updateUserName('');
      expect(controller.userName.value, 'Sarah Connor');
    });

    test('toggleTempUnit switches unit correctly', () {
      final controller = Get.put(SettingsController());
      expect(controller.isCelsius.value, isTrue);
      controller.toggleTempUnit();
      expect(controller.isCelsius.value, isFalse);
      controller.toggleTempUnit();
      expect(controller.isCelsius.value, isTrue);
    });

    test('updateLockTimeout clamps values within limits', () {
      final controller = Get.put(SettingsController());
      
      // Under minimum limit (1.0)
      controller.updateLockTimeout(0.5);
      expect(controller.lockTimeout.value, 1.0);

      // Over maximum limit (30.0)
      controller.updateLockTimeout(40.0);
      expect(controller.lockTimeout.value, 30.0);

      // Within limit
      controller.updateLockTimeout(12.5);
      expect(controller.lockTimeout.value, 12.5);
    });

    test('selectVoiceAssistant only accepts valid voice assistants', () {
      final controller = Get.put(SettingsController());
      
      // Valid voice assistant
      controller.selectVoiceAssistant('Alexa');
      expect(controller.selectedVoiceAssistant.value, 'Alexa');

      // Invalid assistant should be ignored (keep the previous one)
      controller.selectVoiceAssistant('Cortana');
      expect(controller.selectedVoiceAssistant.value, 'Alexa');
    });

    test('selectConnectionMode only accepts valid connection modes', () {
      final controller = Get.put(SettingsController());
      
      // Valid connection mode
      controller.selectConnectionMode('Zigbee');
      expect(controller.hubConnectionMode.value, 'Zigbee');

      // Invalid mode should be ignored
      controller.selectConnectionMode('Ethernet');
      expect(controller.hubConnectionMode.value, 'Zigbee');
    });

    test('toggleNotifications flips notification preference', () {
      final controller = Get.put(SettingsController());
      expect(controller.notificationsEnabled.value, isTrue);
      controller.toggleNotifications();
      expect(controller.notificationsEnabled.value, isFalse);
    });

    test('toggleAutoBackups flips auto backup preference', () {
      final controller = Get.put(SettingsController());
      expect(controller.autoBackups.value, isTrue);
      controller.toggleAutoBackups();
      expect(controller.autoBackups.value, isFalse);
    });

    test('updateIpAddress saves and updates IP address correctly', () async {
      final controller = Get.put(SettingsController());
      
      await controller.updateIpAddress('192.168.1.100');
      expect(controller.ipAddress.value, '192.168.1.100');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('hub_ip_address'), '192.168.1.100');

      // Empty IP address should be ignored
      await controller.updateIpAddress('');
      expect(controller.ipAddress.value, '192.168.1.100');
    });

    test('checkHubConnection updates reachable state when Esp32Service registered', () async {
      final mockEsp = Get.put<Esp32Service>(MockEsp32Service());
      final controller = Get.put(SettingsController());

      // Success scenario
      (mockEsp as MockEsp32Service).pingSuccess = true;
      await controller.checkHubConnection();
      expect(controller.isHubReachable.value, isTrue);

      // Failure scenario
      mockEsp.pingSuccess = false;
      await controller.checkHubConnection();
      expect(controller.isHubReachable.value, isFalse);
    });

    test('AuthService binding updates user details in controller', () async {
      final mockAuth = Get.put<AuthService>(MockAuthService());
      final controller = Get.put(SettingsController());

      expect(controller.isGoogleLinked.value, isFalse);
      expect(controller.googleEmail.value, isEmpty);

      // Sign in
      await mockAuth.signInWithGoogle();
      expect(controller.isGoogleLinked.value, isTrue);
      expect(controller.googleEmail.value, 'test@gmail.com');
      expect(controller.userName.value, 'Test User');

      // Sign out
      await mockAuth.signOut();
      expect(controller.isGoogleLinked.value, isFalse);
      expect(controller.googleEmail.value, isEmpty);
    });
  });
}

class MockEsp32Service extends Esp32Service {
  bool pingSuccess = true;

  @override
  Future<EspResponse<bool>> pingHub() async {
    return pingSuccess ? EspResponse.success(true) : EspResponse.failure('error');
  }
}

class MockAuthService extends AuthService {
  @override
  Future<UserCredential?> signInWithGoogle() async {
    currentUser.value = MockUser();
    return null;
  }

  @override
  Future<void> signOut() async {
    currentUser.value = null;
  }
}

class MockUser implements User {
  @override
  String get email => 'test@gmail.com';

  @override
  String get displayName => 'Test User';

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
