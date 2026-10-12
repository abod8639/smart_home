import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'ping_hub_usecase.g.dart';

/// Use case for verifying network reachability to the central ESP32 hub.
class PingHubUseCase {
  final SettingsRepository repository;

  PingHubUseCase(this.repository);

  Future<bool> call() async {
    return await repository.pingHub();
  }
}

/// Provider for accessing [PingHubUseCase].
@riverpod
PingHubUseCase pingHubUseCase(Ref ref) {
  return PingHubUseCase(ref.watch(settingsRepositoryProvider));
}
