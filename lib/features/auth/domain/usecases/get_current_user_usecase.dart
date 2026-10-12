import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

part 'get_current_user_usecase.g.dart';

/// Use case for retrieving the currently cached/signed-in user entity.
class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase(this.repository);

  UserEntity? call() {
    return repository.currentUser;
  }
}

/// Provider for accessing [GetCurrentUserUseCase].
@riverpod
GetCurrentUserUseCase getCurrentUserUseCase(Ref ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
}
