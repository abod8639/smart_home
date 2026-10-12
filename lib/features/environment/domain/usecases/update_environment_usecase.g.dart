// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_environment_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [UpdateEnvironmentUseCase].

@ProviderFor(updateEnvironmentUseCase)
final updateEnvironmentUseCaseProvider = UpdateEnvironmentUseCaseProvider._();

/// Riverpod provider for [UpdateEnvironmentUseCase].

final class UpdateEnvironmentUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateEnvironmentUseCase,
          UpdateEnvironmentUseCase,
          UpdateEnvironmentUseCase
        >
    with $Provider<UpdateEnvironmentUseCase> {
  /// Riverpod provider for [UpdateEnvironmentUseCase].
  UpdateEnvironmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateEnvironmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateEnvironmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateEnvironmentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateEnvironmentUseCase create(Ref ref) {
    return updateEnvironmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateEnvironmentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateEnvironmentUseCase>(value),
    );
  }
}

String _$updateEnvironmentUseCaseHash() =>
    r'e121d1d3f7a4abd63394b43449673454c71329a5';
