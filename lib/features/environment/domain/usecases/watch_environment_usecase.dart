import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/environment_entity.dart';
import '../repositories/environment_repository.dart';
import '../../data/repositories/environment_repository_impl.dart';

part 'watch_environment_usecase.g.dart';

/// Use case to observe continuous environment updates from sensors/hardware.
class WatchEnvironmentUseCase {
  final EnvironmentRepository repository;

  WatchEnvironmentUseCase(this.repository);

  Stream<EnvironmentEntity> call() {
    return repository.watchEnvironment();
  }
}

/// Riverpod provider for [WatchEnvironmentUseCase].
@riverpod
WatchEnvironmentUseCase watchEnvironmentUseCase(Ref ref) {
  return WatchEnvironmentUseCase(ref.watch(environmentRepositoryProvider));
}
