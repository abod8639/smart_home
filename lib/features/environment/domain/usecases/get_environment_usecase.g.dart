// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_environment_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [GetEnvironmentUseCase].

@ProviderFor(getEnvironmentUseCase)
final getEnvironmentUseCaseProvider = GetEnvironmentUseCaseProvider._();

/// Riverpod provider for [GetEnvironmentUseCase].

final class GetEnvironmentUseCaseProvider
    extends
        $FunctionalProvider<
          GetEnvironmentUseCase,
          GetEnvironmentUseCase,
          GetEnvironmentUseCase
        >
    with $Provider<GetEnvironmentUseCase> {
  /// Riverpod provider for [GetEnvironmentUseCase].
  GetEnvironmentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getEnvironmentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getEnvironmentUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetEnvironmentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetEnvironmentUseCase create(Ref ref) {
    return getEnvironmentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetEnvironmentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetEnvironmentUseCase>(value),
    );
  }
}

String _$getEnvironmentUseCaseHash() =>
    r'd69ea75e5b1561b658fde83d5d5afc27673faaa1';
