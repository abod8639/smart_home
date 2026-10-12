// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ping_hub_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [PingHubUseCase].

@ProviderFor(pingHubUseCase)
final pingHubUseCaseProvider = PingHubUseCaseProvider._();

/// Provider for accessing [PingHubUseCase].

final class PingHubUseCaseProvider
    extends $FunctionalProvider<PingHubUseCase, PingHubUseCase, PingHubUseCase>
    with $Provider<PingHubUseCase> {
  /// Provider for accessing [PingHubUseCase].
  PingHubUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pingHubUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pingHubUseCaseHash();

  @$internal
  @override
  $ProviderElement<PingHubUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  PingHubUseCase create(Ref ref) {
    return pingHubUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PingHubUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PingHubUseCase>(value),
    );
  }
}

String _$pingHubUseCaseHash() => r'64a84bc0b7dc7a4f0a13003c4596398f570fd8da';
