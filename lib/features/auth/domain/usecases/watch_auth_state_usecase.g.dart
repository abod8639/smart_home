// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_auth_state_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [WatchAuthStateUseCase].

@ProviderFor(watchAuthStateUseCase)
final watchAuthStateUseCaseProvider = WatchAuthStateUseCaseProvider._();

/// Provider for accessing [WatchAuthStateUseCase].

final class WatchAuthStateUseCaseProvider
    extends
        $FunctionalProvider<
          WatchAuthStateUseCase,
          WatchAuthStateUseCase,
          WatchAuthStateUseCase
        >
    with $Provider<WatchAuthStateUseCase> {
  /// Provider for accessing [WatchAuthStateUseCase].
  WatchAuthStateUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAuthStateUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAuthStateUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchAuthStateUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchAuthStateUseCase create(Ref ref) {
    return watchAuthStateUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchAuthStateUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchAuthStateUseCase>(value),
    );
  }
}

String _$watchAuthStateUseCaseHash() =>
    r'bb87135ca277fb045a27412d2e037c680ad850e1';

/// StreamProvider emitting current [UserEntity?] stream.

@ProviderFor(authUserState)
final authUserStateProvider = AuthUserStateProvider._();

/// StreamProvider emitting current [UserEntity?] stream.

final class AuthUserStateProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserEntity?>,
          UserEntity?,
          Stream<UserEntity?>
        >
    with $FutureModifier<UserEntity?>, $StreamProvider<UserEntity?> {
  /// StreamProvider emitting current [UserEntity?] stream.
  AuthUserStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authUserStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authUserStateHash();

  @$internal
  @override
  $StreamProviderElement<UserEntity?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<UserEntity?> create(Ref ref) {
    return authUserState(ref);
  }
}

String _$authUserStateHash() => r'99bc9097fbd9f4c8435517ca6a2bbc58fb936833';
