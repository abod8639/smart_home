// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_hub_ip_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SaveHubIpUseCase].

@ProviderFor(saveHubIpUseCase)
final saveHubIpUseCaseProvider = SaveHubIpUseCaseProvider._();

/// Provider for accessing [SaveHubIpUseCase].

final class SaveHubIpUseCaseProvider
    extends
        $FunctionalProvider<
          SaveHubIpUseCase,
          SaveHubIpUseCase,
          SaveHubIpUseCase
        >
    with $Provider<SaveHubIpUseCase> {
  /// Provider for accessing [SaveHubIpUseCase].
  SaveHubIpUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveHubIpUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveHubIpUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveHubIpUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveHubIpUseCase create(Ref ref) {
    return saveHubIpUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveHubIpUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveHubIpUseCase>(value),
    );
  }
}

String _$saveHubIpUseCaseHash() => r'1814ac3f0799027e0c8ec6465fb2f89248963da6';
