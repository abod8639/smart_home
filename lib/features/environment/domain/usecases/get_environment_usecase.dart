import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../entities/environment_entity.dart';
import '../repositories/environment_repository.dart';
import '../../data/repositories/environment_repository_impl.dart';

part 'get_environment_usecase.g.dart';

/// Use case to retrieve the current snapshot of environment metrics.
class GetEnvironmentUseCase {
  final EnvironmentRepository repository;

  GetEnvironmentUseCase(this.repository);

  EnvironmentEntity call() {
    return repository.getEnvironment();
  }
}

/// Riverpod provider for [GetEnvironmentUseCase].
@riverpod
GetEnvironmentUseCase getEnvironmentUseCase(Ref ref) {
  return GetEnvironmentUseCase(ref.watch(environmentRepositoryProvider));
}
