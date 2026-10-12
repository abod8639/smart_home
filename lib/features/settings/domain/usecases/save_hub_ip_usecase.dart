import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'save_hub_ip_usecase.g.dart';

/// Use case for persisting the MQTT broker URL or hub IP address.
class SaveHubIpUseCase {
  final SettingsRepository repository;

  SaveHubIpUseCase(this.repository);

  Future<void> call(String ip) async {
    await repository.saveHubIp(ip);
  }
}

/// Provider for accessing [SaveHubIpUseCase].
@riverpod
SaveHubIpUseCase saveHubIpUseCase(Ref ref) {
  return SaveHubIpUseCase(ref.watch(settingsRepositoryProvider));
}
