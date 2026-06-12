import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

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
  });
}
