import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'get_settings_usecase.g.dart';

/// Use case for retrieving persisted smart home settings and preferences.
class GetSettingsUseCase {
  final SettingsRepository repository;

  GetSettingsUseCase(this.repository);

  Future<SettingsEntity> call() async {
    return await repository.getSettings();
  }
}

/// Provider for accessing [GetSettingsUseCase].
@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  return GetSettingsUseCase(ref.watch(settingsRepositoryProvider));
}
