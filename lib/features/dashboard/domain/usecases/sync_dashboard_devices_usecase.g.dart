// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dashboard_devices_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SyncDashboardDevicesUseCase].

@ProviderFor(syncDashboardDevicesUseCase)
final syncDashboardDevicesUseCaseProvider =
    SyncDashboardDevicesUseCaseProvider._();

/// Provider for accessing [SyncDashboardDevicesUseCase].

final class SyncDashboardDevicesUseCaseProvider
    extends
        $FunctionalProvider<
          SyncDashboardDevicesUseCase,
          SyncDashboardDevicesUseCase,
          SyncDashboardDevicesUseCase
        >
    with $Provider<SyncDashboardDevicesUseCase> {
  /// Provider for accessing [SyncDashboardDevicesUseCase].
  SyncDashboardDevicesUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDashboardDevicesUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDashboardDevicesUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncDashboardDevicesUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncDashboardDevicesUseCase create(Ref ref) {
    return syncDashboardDevicesUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncDashboardDevicesUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncDashboardDevicesUseCase>(value),
    );
  }
}

String _$syncDashboardDevicesUseCaseHash() =>
    r'8d89ea13b867f37c5fc0b18877f3ec67dedfa6d8';
