// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clear_devices_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [ClearDevicesUseCase].

@ProviderFor(clearDevicesUseCase)
final clearDevicesUseCaseProvider = ClearDevicesUseCaseProvider._();

/// Riverpod provider for [ClearDevicesUseCase].

final class ClearDevicesUseCaseProvider
    extends
        $FunctionalProvider<
          ClearDevicesUseCase,
          ClearDevicesUseCase,
          ClearDevicesUseCase
        >
    with $Provider<ClearDevicesUseCase> {
  /// Riverpod provider for [ClearDevicesUseCase].
  ClearDevicesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clearDevicesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clearDevicesUseCaseHash();

  @$internal
  @override
  $ProviderElement<ClearDevicesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ClearDevicesUseCase create(Ref ref) {
    return clearDevicesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClearDevicesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClearDevicesUseCase>(value),
    );
  }
}

String _$clearDevicesUseCaseHash() =>
    r'2d3f67844ca7ac755b20d50388fdf8eb9571f1ad';
