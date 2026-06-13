import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';
import 'package:smart_home/core/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    dotenv.loadFromString(envString: 'MQTT_BROKER_URL=test_broker');
  });

  group('SettingsController Tests', () {
    late ProviderContainer container;
    late MockUser mockUser;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockUser = MockUser(
        isAnonymous: false,
        uid: 'test_uid',
        email: 'test@example.com',
        displayName: 'Test User',
      );
      mockAuth = MockFirebaseAuth();
      when(mockAuth.currentUser).thenReturn(mockUser);

      container = ProviderContainer(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(mockUser)),
          firebaseAuthProvider.overrideWith((ref) => mockAuth),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state has default values', () {
      final state = container.read(settingsControllerProvider);
      expect(state.ipAddress, 'test_broker');
      // Note: microtask runs after build, so we might need to pump or wait
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
