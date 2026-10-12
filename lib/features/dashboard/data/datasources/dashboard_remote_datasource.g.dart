// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [DashboardRemoteDataSource].

@ProviderFor(dashboardRemoteDataSource)
final dashboardRemoteDataSourceProvider = DashboardRemoteDataSourceProvider._();

/// Provider for accessing [DashboardRemoteDataSource].

final class DashboardRemoteDataSourceProvider
    extends
        $FunctionalProvider<
          DashboardRemoteDataSource,
          DashboardRemoteDataSource,
          DashboardRemoteDataSource
        >
    with $Provider<DashboardRemoteDataSource> {
  /// Provider for accessing [DashboardRemoteDataSource].
  DashboardRemoteDataSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardRemoteDataSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardRemoteDataSourceHash();

  @$internal
  @override
  $ProviderElement<DashboardRemoteDataSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardRemoteDataSource create(Ref ref) {
    return dashboardRemoteDataSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardRemoteDataSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardRemoteDataSource>(value),
    );
  }
}

String _$dashboardRemoteDataSourceHash() =>
    r'30b34b4483b75608979e9a8fe2b46e875479a3de';
