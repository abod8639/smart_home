// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'watch_environment_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [WatchEnvironmentUseCase].

@ProviderFor(watchEnvironmentUseCase)
final watchEnvironmentUseCaseProvider = WatchEnvironmentUseCaseProvider._();

/// Riverpod provider for [WatchEnvironmentUseCase].

final class WatchEnvironmentUseCaseProvider
    extends
        $FunctionalProvider<
          WatchEnvironmentUseCase,
          WatchEnvironmentUseCase,
          WatchEnvironmentUseCase
        >
    with $Provider<WatchEnvironmentUseCase> {
  /// Riverpod provider for [WatchEnvironmentUseCase].
  WatchEnvironmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchEnvironmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchEnvironmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<WatchEnvironmentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WatchEnvironmentUseCase create(Ref ref) {
    return watchEnvironmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WatchEnvironmentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WatchEnvironmentUseCase>(value),
    );
  }
}

String _$watchEnvironmentUseCaseHash() =>
    r'cc77bbea61ba1d3d5e9b305fa1f04f3ec19381b8';
