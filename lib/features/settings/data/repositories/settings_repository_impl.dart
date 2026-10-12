import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';
import '../models/settings_model.dart';

part 'settings_repository_impl.g.dart';

/// Concrete implementation of [SettingsRepository] managing local persistence and hub pinging.
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource localDatasource;
  final Future<bool> Function()? onPingHub;

  SettingsRepositoryImpl({
    required this.localDatasource,
    this.onPingHub,
  });

  @override
  Future<String?> getSavedHubIp() async {
    return await localDatasource.getHubIp();
  }

  @override
  Future<void> saveHubIp(String ip) async {
    await localDatasource.saveHubIp(ip);
  }

  @override
  Future<SettingsEntity> getSettings() async {
    return await localDatasource.loadSettings();
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    await localDatasource.saveSettings(SettingsModel.fromEntity(settings));
  }

  @override
  Future<bool> pingHub() async {
    if (onPingHub != null) {
      return await onPingHub!();
    }
    return false;
  }
}

/// Provider for accessing [SettingsRepository].
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  return SettingsRepositoryImpl(
    localDatasource: ref.watch(settingsLocalDatasourceProvider),
    onPingHub: () async {
      try {
        final response = await ref.read(esp32ServiceProvider.notifier).pingHub();
        return response.isSuccess;
      } catch (_) {
        return false;
      }
    },
  );
}
