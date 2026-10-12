import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_home/features/settings/domain/entities/settings_entity.dart';
import 'package:smart_home/features/settings/domain/repositories/settings_repository.dart';
import 'package:smart_home/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:smart_home/features/settings/domain/usecases/ping_hub_usecase.dart';
import 'package:smart_home/features/settings/domain/usecases/save_hub_ip_usecase.dart';
import 'package:smart_home/features/settings/domain/usecases/save_settings_usecase.dart';
import 'package:smart_home/features/settings/data/models/settings_model.dart';
import 'package:smart_home/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:smart_home/features/settings/data/repositories/settings_repository_impl.dart';

class FakeSettingsRepository implements SettingsRepository {
  SettingsEntity currentSettings = const SettingsEntity();
  String? savedIp;
  bool isReachable = true;

  @override
  Future<String?> getSavedHubIp() async => savedIp;

  @override
  Future<void> saveHubIp(String ip) async {
    savedIp = ip;
    currentSettings = currentSettings.copyWith(ipAddress: ip);
  }

  @override
  Future<SettingsEntity> getSettings() async => currentSettings;

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    currentSettings = settings;
  }

  @override
  Future<bool> pingHub() async => isReachable;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('SettingsEntity & SettingsModel Tests', () {
    test('SettingsEntity default values and copyWith', () {
      const entity = SettingsEntity();
      expect(entity.userName, 'Dexter');
      expect(entity.userRole, 'Administrator');
      expect(entity.isCelsius, isTrue);
      expect(entity.hubConnectionMode, 'Wi-Fi');

      final updated = entity.copyWith(
        userName: 'Alice',
        isCelsius: false,
        hubConnectionMode: 'Zigbee',
      );

      expect(updated.userName, 'Alice');
      expect(updated.isCelsius, isFalse);
      expect(updated.hubConnectionMode, 'Zigbee');
      expect(updated.userRole, 'Administrator');
    });

    test('SettingsModel toMap and fromMap serialization', () {
      const model = SettingsModel(
        userName: 'Bob',
        userRole: 'Manager',
        isCelsius: false,
        selectedVoiceAssistant: 'Alexa',
        notificationsEnabled: false,
        hubConnectionMode: 'Bluetooth',
        autoBackups: false,
        lockTimeout: 10.0,
        ipAddress: '192.168.1.100',
      );

      final map = model.toMap();
      expect(map['userName'], 'Bob');
      expect(map['isCelsius'], isFalse);
      expect(map['ipAddress'], '192.168.1.100');

      final restored = SettingsModel.fromMap(map);
      expect(restored.userName, model.userName);
      expect(restored.userRole, model.userRole);
      expect(restored.isCelsius, model.isCelsius);
      expect(restored.selectedVoiceAssistant, model.selectedVoiceAssistant);
      expect(restored.notificationsEnabled, model.notificationsEnabled);
      expect(restored.hubConnectionMode, model.hubConnectionMode);
      expect(restored.autoBackups, model.autoBackups);
      expect(restored.lockTimeout, model.lockTimeout);
      expect(restored.ipAddress, model.ipAddress);
    });

    test('SettingsModel fromEntity creates accurate instance', () {
      const entity = SettingsEntity(
        userName: 'Charlie',
        ipAddress: 'broker.test.com',
      );
      final model = SettingsModel.fromEntity(entity);
      expect(model.userName, 'Charlie');
      expect(model.ipAddress, 'broker.test.com');
    });
  });

  group('SettingsLocalDatasource Tests', () {
    test('saveHubIp and getHubIp round-trip', () async {
      final datasource = SettingsLocalDatasource();
      expect(await datasource.getHubIp(), isNull);

      await datasource.saveHubIp('192.168.1.200');
      expect(await datasource.getHubIp(), '192.168.1.200');
    });

    test('saveSettings and loadSettings round-trip', () async {
      final datasource = SettingsLocalDatasource();
      const model = SettingsModel(
        userName: 'Admin',
        userRole: 'Owner',
        isCelsius: true,
        selectedVoiceAssistant: 'Siri',
        notificationsEnabled: true,
        hubConnectionMode: 'Wi-Fi',
        autoBackups: true,
        lockTimeout: 15.0,
        ipAddress: '192.168.1.50',
      );

      await datasource.saveSettings(model);
      final loaded = await datasource.loadSettings();

      expect(loaded.userName, 'Admin');
      expect(loaded.userRole, 'Owner');
      expect(loaded.isCelsius, isTrue);
      expect(loaded.selectedVoiceAssistant, 'Siri');
      expect(loaded.notificationsEnabled, isTrue);
      expect(loaded.hubConnectionMode, 'Wi-Fi');
      expect(loaded.autoBackups, isTrue);
      expect(loaded.lockTimeout, 15.0);
      expect(loaded.ipAddress, '192.168.1.50');
    });
  });

  group('SettingsRepositoryImpl Tests', () {
    test('delegates storage methods to local datasource', () async {
      final datasource = SettingsLocalDatasource();
      final repository = SettingsRepositoryImpl(
        localDatasource: datasource,
        onPingHub: () async => true,
      );

      await repository.saveHubIp('10.0.0.1');
      expect(await repository.getSavedHubIp(), '10.0.0.1');

      const settings = SettingsEntity(userName: 'Tester', ipAddress: '10.0.0.1');
      await repository.saveSettings(settings);

      final loaded = await repository.getSettings();
      expect(loaded.userName, 'Tester');
      expect(loaded.ipAddress, '10.0.0.1');

      final isReachable = await repository.pingHub();
      expect(isReachable, isTrue);
    });
  });

  group('Settings Use Cases Tests', () {
    late FakeSettingsRepository fakeRepo;

    setUp(() {
      fakeRepo = FakeSettingsRepository();
    });

    test('GetSettingsUseCase fetches current settings', () async {
      final usecase = GetSettingsUseCase(fakeRepo);
      final settings = await usecase();
      expect(settings.userName, 'Dexter');
    });

    test('SaveHubIpUseCase saves IP correctly', () async {
      final usecase = SaveHubIpUseCase(fakeRepo);
      await usecase('192.168.1.99');
      expect(fakeRepo.savedIp, '192.168.1.99');
    });

    test('PingHubUseCase returns ping result', () async {
      final usecase = PingHubUseCase(fakeRepo);
      expect(await usecase(), isTrue);

      fakeRepo.isReachable = false;
      expect(await usecase(), isFalse);
    });

    test('SaveSettingsUseCase persists settings', () async {
      final usecase = SaveSettingsUseCase(fakeRepo);
      const newSettings = SettingsEntity(userName: 'Dave', isCelsius: false);
      await usecase(newSettings);

      expect(fakeRepo.currentSettings.userName, 'Dave');
      expect(fakeRepo.currentSettings.isCelsius, isFalse);
    });
  });
}
