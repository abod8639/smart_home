import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

part 'watch_auth_state_usecase.g.dart';

/// Use case for listening to auth changes as a stream.
class WatchAuthStateUseCase {
  final AuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}

/// Provider for accessing [WatchAuthStateUseCase].
@riverpod
WatchAuthStateUseCase watchAuthStateUseCase(Ref ref) {
  return WatchAuthStateUseCase(ref.watch(authRepositoryProvider));
}

/// StreamProvider emitting current [UserEntity?] stream.
@riverpod
Stream<UserEntity?> authUserState(Ref ref) {
  return ref.watch(watchAuthStateUseCaseProvider).call();
}
