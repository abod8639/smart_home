import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_home/features/auth/domain/entities/user_entity.dart';
import 'package:smart_home/features/auth/domain/repositories/auth_repository.dart';
import 'package:smart_home/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:smart_home/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import 'package:smart_home/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:smart_home/features/auth/domain/usecases/watch_auth_state_usecase.dart';
import 'package:smart_home/features/auth/presentation/controllers/auth_controller.dart';

class FakeAuthRepository implements AuthRepository {
  UserEntity? _currentUser;
  final StreamController<UserEntity?> _controller =
      StreamController<UserEntity?>.broadcast();

  bool throwOnSignIn = false;

  @override
  Stream<UserEntity?> get authStateChanges => _controller.stream;

  @override
  UserEntity? get currentUser => _currentUser;

  @override
  Future<UserEntity?> signInWithGoogle() async {
    if (throwOnSignIn) {
      throw Exception('Sign in failed');
    }
    _currentUser = const UserEntity(
      id: 'mock_uid',
      email: 'mock@google.com',
      displayName: 'Mock User',
    );
    _controller.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}

void main() {
  late FakeAuthRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeAuthRepository();
  });

  tearDown(() {
    fakeRepo.dispose();
  });

  group('Auth Use Cases Tests', () {
    test('SignInWithGoogleUseCase calls repository successfully', () async {
      final useCase = SignInWithGoogleUseCase(fakeRepo);
      final user = await useCase();

      expect(user, isNotNull);
      expect(user?.email, 'mock@google.com');
      expect(fakeRepo.currentUser, equals(user));
    });

    test('SignOutUseCase resets user in repository', () async {
      final signInUseCase = SignInWithGoogleUseCase(fakeRepo);
      final signOutUseCase = SignOutUseCase(fakeRepo);

      await signInUseCase();
      expect(fakeRepo.currentUser, isNotNull);

      await signOutUseCase();
      expect(fakeRepo.currentUser, isNull);
    });

    test('GetCurrentUserUseCase returns current user', () async {
      final useCase = GetCurrentUserUseCase(fakeRepo);
      expect(useCase(), isNull);

      await fakeRepo.signInWithGoogle();
      expect(useCase()?.id, 'mock_uid');
    });

    test('WatchAuthStateUseCase emits user state transitions', () async {
      final useCase = WatchAuthStateUseCase(fakeRepo);

      expectLater(
        useCase(),
        emitsInOrder([
          const UserEntity(
            id: 'mock_uid',
            email: 'mock@google.com',
            displayName: 'Mock User',
          ),
          null,
        ]),
      );

      await fakeRepo.signInWithGoogle();
      await fakeRepo.signOut();
    });
  });

  group('AuthController Tests', () {
    test('initial state reads current user', () {
      final containerRef = ProviderContainer(
        overrides: [
          getCurrentUserUseCaseProvider.overrideWithValue(
            GetCurrentUserUseCase(fakeRepo),
          ),
          signInWithGoogleUseCaseProvider.overrideWithValue(
            SignInWithGoogleUseCase(fakeRepo),
          ),
          signOutUseCaseProvider.overrideWithValue(
            SignOutUseCase(fakeRepo),
          ),
          authUserStateProvider.overrideWith((ref) => fakeRepo.authStateChanges),
        ],
      );

      final state = containerRef.read(authControllerProvider);
      expect(state.isLoading, isFalse);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });

    test('signInWithGoogle updates state on success', () async {
      final containerRef = ProviderContainer(
        overrides: [
          getCurrentUserUseCaseProvider.overrideWithValue(
            GetCurrentUserUseCase(fakeRepo),
          ),
          signInWithGoogleUseCaseProvider.overrideWithValue(
            SignInWithGoogleUseCase(fakeRepo),
          ),
          signOutUseCaseProvider.overrideWithValue(
            SignOutUseCase(fakeRepo),
          ),
          authUserStateProvider.overrideWith((ref) => fakeRepo.authStateChanges),
        ],
      );

      final controller = containerRef.read(authControllerProvider.notifier);
      final success = await controller.signInWithGoogle();

      expect(success, isTrue);
      final state = containerRef.read(authControllerProvider);
      expect(state.user?.email, 'mock@google.com');
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNull);
    });

    test('signInWithGoogle handles failure gracefully', () async {
      fakeRepo.throwOnSignIn = true;

      final containerRef = ProviderContainer(
        overrides: [
          getCurrentUserUseCaseProvider.overrideWithValue(
            GetCurrentUserUseCase(fakeRepo),
          ),
          signInWithGoogleUseCaseProvider.overrideWithValue(
            SignInWithGoogleUseCase(fakeRepo),
          ),
          signOutUseCaseProvider.overrideWithValue(
            SignOutUseCase(fakeRepo),
          ),
          authUserStateProvider.overrideWith((ref) => fakeRepo.authStateChanges),
        ],
      );

      final controller = containerRef.read(authControllerProvider.notifier);
      final success = await controller.signInWithGoogle();

      expect(success, isFalse);
      final state = containerRef.read(authControllerProvider);
      expect(state.user, isNull);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, isNotNull);
    });
  });
}
