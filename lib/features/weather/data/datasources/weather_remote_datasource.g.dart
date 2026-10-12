// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_remote_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [WeatherRemoteDatasource].

@ProviderFor(weatherRemoteDatasource)
final weatherRemoteDatasourceProvider = WeatherRemoteDatasourceProvider._();

/// Provider for accessing [WeatherRemoteDatasource].

final class WeatherRemoteDatasourceProvider
    extends
        $FunctionalProvider<
          WeatherRemoteDatasource,
          WeatherRemoteDatasource,
          WeatherRemoteDatasource
        >
    with $Provider<WeatherRemoteDatasource> {
  /// Provider for accessing [WeatherRemoteDatasource].
  WeatherRemoteDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherRemoteDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherRemoteDatasourceHash();

  @$internal
  @override
  $ProviderElement<WeatherRemoteDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeatherRemoteDatasource create(Ref ref) {
    return weatherRemoteDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherRemoteDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherRemoteDatasource>(value),
    );
  }
}

String _$weatherRemoteDatasourceHash() =>
    r'35334f340b69cae0f8039ec841305beafd3c57ef';
