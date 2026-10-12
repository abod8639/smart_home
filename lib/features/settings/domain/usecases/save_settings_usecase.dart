import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';
import '../../data/repositories/settings_repository_impl.dart';

part 'save_settings_usecase.g.dart';

/// Use case for saving updated smart home preferences.
class SaveSettingsUseCase {
  final SettingsRepository repository;

  SaveSettingsUseCase(this.repository);

  Future<void> call(SettingsEntity settings) async {
    await repository.saveSettings(settings);
  }
}

/// Provider for accessing [SaveSettingsUseCase].
@riverpod
SaveSettingsUseCase saveSettingsUseCase(Ref ref) {
  return SaveSettingsUseCase(ref.watch(settingsRepositoryProvider));
}
