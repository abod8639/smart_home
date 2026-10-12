// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_dashboard_rooms_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SyncDashboardRoomsUseCase].

@ProviderFor(syncDashboardRoomsUseCase)
final syncDashboardRoomsUseCaseProvider = SyncDashboardRoomsUseCaseProvider._();

/// Provider for accessing [SyncDashboardRoomsUseCase].

final class SyncDashboardRoomsUseCaseProvider
    extends
        $FunctionalProvider<
          SyncDashboardRoomsUseCase,
          SyncDashboardRoomsUseCase,
          SyncDashboardRoomsUseCase
        >
    with $Provider<SyncDashboardRoomsUseCase> {
  /// Provider for accessing [SyncDashboardRoomsUseCase].
  SyncDashboardRoomsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'syncDashboardRoomsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$syncDashboardRoomsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SyncDashboardRoomsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SyncDashboardRoomsUseCase create(Ref ref) {
    return syncDashboardRoomsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncDashboardRoomsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncDashboardRoomsUseCase>(value),
    );
  }
}

String _$syncDashboardRoomsUseCaseHash() =>
    r'3fdba47d7c1c6e0be6cf8b6487dfeb8f70d1208e';
