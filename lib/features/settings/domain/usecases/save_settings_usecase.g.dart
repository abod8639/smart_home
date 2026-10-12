// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_settings_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SaveSettingsUseCase].

@ProviderFor(saveSettingsUseCase)
final saveSettingsUseCaseProvider = SaveSettingsUseCaseProvider._();

/// Provider for accessing [SaveSettingsUseCase].

final class SaveSettingsUseCaseProvider
    extends
        $FunctionalProvider<
          SaveSettingsUseCase,
          SaveSettingsUseCase,
          SaveSettingsUseCase
        >
    with $Provider<SaveSettingsUseCase> {
  /// Provider for accessing [SaveSettingsUseCase].
  SaveSettingsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveSettingsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveSettingsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveSettingsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveSettingsUseCase create(Ref ref) {
    return saveSettingsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveSettingsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveSettingsUseCase>(value),
    );
  }
}

String _$saveSettingsUseCaseHash() =>
    r'deebc3301db604f50375ca72b371f0ca2bdd8f89';
