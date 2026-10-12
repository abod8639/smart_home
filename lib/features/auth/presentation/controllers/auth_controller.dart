import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';

part 'auth_controller.g.dart';

/// State representation for authentication operations.
class AuthState extends Equatable {
  final UserEntity? user;
  final bool isLoading;
  final String? errorMessage;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.errorMessage,
  });

  AuthState copyWith({
    UserEntity? user,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [user, isLoading, errorMessage];
}

/// Controller managing login/logout state and error notifications.
@riverpod
class AuthController extends _$AuthController {
  @override
  AuthState build() {
    // Listen to background auth state changes
    ref.listen(authUserStateProvider, (_, next) {
      if (next.hasValue) {
        state = state.copyWith(user: next.value);
      }
    });

    final currentUser = ref.read(getCurrentUserUseCaseProvider).call();
    return AuthState(user: currentUser);
  }

  /// Initiates Google Sign-In with loading and error handling.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await ref.read(signInWithGoogleUseCaseProvider).call();
      if (user == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Sign-in cancelled or failed.',
        );
        return false;
      }
      state = state.copyWith(
        user: user,
        isLoading: false,
        clearError: true,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred during sign-in.',
      );
      return false;
    }
  }

  /// Signs out the user.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await ref.read(signOutUseCaseProvider).call();
      state = const AuthState(user: null, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to sign out.',
      );
    }
  }

  /// Clears active error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
