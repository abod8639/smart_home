// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SettingsLocalDatasource].

@ProviderFor(settingsLocalDatasource)
final settingsLocalDatasourceProvider = SettingsLocalDatasourceProvider._();

/// Provider for accessing [SettingsLocalDatasource].

final class SettingsLocalDatasourceProvider
    extends
        $FunctionalProvider<
          SettingsLocalDatasource,
          SettingsLocalDatasource,
          SettingsLocalDatasource
        >
    with $Provider<SettingsLocalDatasource> {
  /// Provider for accessing [SettingsLocalDatasource].
  SettingsLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<SettingsLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SettingsLocalDatasource create(Ref ref) {
    return settingsLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsLocalDatasource>(value),
    );
  }
}

String _$settingsLocalDatasourceHash() =>
    r'cc8c7ede5ddeeaad385788417e190b1e56bc00e5';
