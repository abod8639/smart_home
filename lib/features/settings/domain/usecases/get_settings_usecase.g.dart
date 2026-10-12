// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_settings_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [GetSettingsUseCase].

@ProviderFor(getSettingsUseCase)
final getSettingsUseCaseProvider = GetSettingsUseCaseProvider._();

/// Provider for accessing [GetSettingsUseCase].

final class GetSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          GetSettingsUseCase,
          GetSettingsUseCase,
          GetSettingsUseCase
        >
    with $Provider<GetSettingsUseCase> {
  /// Provider for accessing [GetSettingsUseCase].
  GetSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getSettingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetSettingsUseCase create(Ref ref) {
    return getSettingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetSettingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetSettingsUseCase>(value),
    );
  }
}

String _$getSettingsUseCaseHash() =>
    r'09c503ca87f7a3fdda8750ca6f256cd5ef800f73';
