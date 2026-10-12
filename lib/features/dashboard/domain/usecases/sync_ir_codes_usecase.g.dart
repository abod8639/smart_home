// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_ir_codes_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SyncIrCodesUseCase].

@ProviderFor(syncIrCodesUseCase)
final syncIrCodesUseCaseProvider = SyncIrCodesUseCaseProvider._();

/// Provider for accessing [SyncIrCodesUseCase].

final class SyncIrCodesUseCaseProvider
    extends
        $FunctionalProvider<
          SyncIrCodesUseCase,
          SyncIrCodesUseCase,
          SyncIrCodesUseCase
        >
    with $Provider<SyncIrCodesUseCase> {
  /// Provider for accessing [SyncIrCodesUseCase].
  SyncIrCodesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncIrCodesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncIrCodesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncIrCodesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncIrCodesUseCase create(Ref ref) {
    return syncIrCodesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncIrCodesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncIrCodesUseCase>(value),
    );
  }
}

String _$syncIrCodesUseCaseHash() =>
    r'ad956118191901a94024cbff4f76dd8ed25e5e7b';
