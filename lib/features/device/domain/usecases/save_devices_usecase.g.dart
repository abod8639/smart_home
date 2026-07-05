// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_devices_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [SaveDevicesUseCase].

@ProviderFor(saveDevicesUseCase)
final saveDevicesUseCaseProvider = SaveDevicesUseCaseProvider._();

/// Riverpod provider for [SaveDevicesUseCase].

final class SaveDevicesUseCaseProvider
    extends
        $FunctionalProvider<
          SaveDevicesUseCase,
          SaveDevicesUseCase,
          SaveDevicesUseCase
        >
    with $Provider<SaveDevicesUseCase> {
  /// Riverpod provider for [SaveDevicesUseCase].
  SaveDevicesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveDevicesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveDevicesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveDevicesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SaveDevicesUseCase create(Ref ref) {
    return saveDevicesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveDevicesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveDevicesUseCase>(value),
    );
  }
}

String _$saveDevicesUseCaseHash() =>
    r'ab1ea4db49f28a4c6f2be978992c72724ce99fc7';
