import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'MQTT_BROKER_URL=test_broker');
  });

  group('SettingsController Tests', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default values', () {
      final state = container.read(settingsControllerProvider);
      expect(state.ipAddress, 'test_broker');
      expect(state.userName, 'Dexter');
      expect(state.isCelsius, isTrue);
    });

    test('updateUserName updates state correctly', () {
      final controller = container.read(settingsControllerProvider.notifier);
      controller.updateUserName('New Name');
      expect(container.read(settingsControllerProvider).userName, 'New Name');
    });

    test('updateUserName ignores empty string', () {
      final controller = container.read(settingsControllerProvider.notifier);
      controller.updateUserName('');
      expect(container.read(settingsControllerProvider).userName, 'Dexter');
    });

    test('toggleTempUnit flips isCelsius', () {
      final controller = container.read(settingsControllerProvider.notifier);
      final initial = container.read(settingsControllerProvider).isCelsius;
      controller.toggleTempUnit();
      expect(container.read(settingsControllerProvider).isCelsius, !initial);
    });

    test('selectVoiceAssistant updates state', () {
      final controller = container.read(settingsControllerProvider.notifier);
      controller.selectVoiceAssistant('Alexa');
      expect(container.read(settingsControllerProvider).selectedVoiceAssistant, 'Alexa');
    });

    test('selectConnectionMode updates state', () {
      final controller = container.read(settingsControllerProvider.notifier);
      controller.selectConnectionMode('Zigbee');
      expect(container.read(settingsControllerProvider).hubConnectionMode, 'Zigbee');
    });

    test('toggleNotifications flips state', () {
      final controller = container.read(settingsControllerProvider.notifier);
      final initial = container.read(settingsControllerProvider).notificationsEnabled;
      controller.toggleNotifications();
      expect(container.read(settingsControllerProvider).notificationsEnabled, !initial);
    });
  });
}
