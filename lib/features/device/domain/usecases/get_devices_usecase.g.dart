// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_devices_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [GetDevicesUseCase].

@ProviderFor(getDevicesUseCase)
final getDevicesUseCaseProvider = GetDevicesUseCaseProvider._();

/// Riverpod provider for [GetDevicesUseCase].

final class GetDevicesUseCaseProvider
    extends
        $FunctionalProvider<
          GetDevicesUseCase,
          GetDevicesUseCase,
          GetDevicesUseCase
        >
    with $Provider<GetDevicesUseCase> {
  /// Riverpod provider for [GetDevicesUseCase].
  GetDevicesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getDevicesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getDevicesUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetDevicesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetDevicesUseCase create(Ref ref) {
    return getDevicesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetDevicesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetDevicesUseCase>(value),
    );
  }
}

String _$getDevicesUseCaseHash() => r'8c8e2f69f8f9be50fd4dcd49adc35d6ec92c7634';
