import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../repositories/auth_repository.dart';

part 'sign_out_usecase.g.dart';

/// Use case for terminating the current authenticated session.
class SignOutUseCase {
  final AuthRepository repository;

  SignOutUseCase(this.repository);

  Future<void> call() async {
    await repository.signOut();
  }
}

/// Provider for accessing [SignOutUseCase].
@riverpod
SignOutUseCase signOutUseCase(Ref ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
}
