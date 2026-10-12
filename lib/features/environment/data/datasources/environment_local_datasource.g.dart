// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [EnvironmentLocalDatasource].

@ProviderFor(environmentLocalDatasource)
final environmentLocalDatasourceProvider =
    EnvironmentLocalDatasourceProvider._();

/// Riverpod provider for [EnvironmentLocalDatasource].

final class EnvironmentLocalDatasourceProvider
    extends
        $FunctionalProvider<
          EnvironmentLocalDatasource,
          EnvironmentLocalDatasource,
          EnvironmentLocalDatasource
        >
    with $Provider<EnvironmentLocalDatasource> {
  /// Riverpod provider for [EnvironmentLocalDatasource].
  EnvironmentLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentLocalDatasourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<EnvironmentLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnvironmentLocalDatasource create(Ref ref) {
    return environmentLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvironmentLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvironmentLocalDatasource>(value),
    );
  }
}

String _$environmentLocalDatasourceHash() =>
    r'14dcef64328944d653752e1c1a8d9dc5ef852da4';
