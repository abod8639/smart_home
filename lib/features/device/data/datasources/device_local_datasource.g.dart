// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceLocalDatasource)
final deviceLocalDatasourceProvider = DeviceLocalDatasourceProvider._();

final class DeviceLocalDatasourceProvider
    extends
        $FunctionalProvider<
          DeviceLocalDatasource,
          DeviceLocalDatasource,
          DeviceLocalDatasource
        >
    with $Provider<DeviceLocalDatasource> {
  DeviceLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<DeviceLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeviceLocalDatasource create(Ref ref) {
    return deviceLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceLocalDatasource>(value),
    );
  }
}

String _$deviceLocalDatasourceHash() =>
    r'b2462a7679fd0a730cc130ee8d7b17ed5ff0d49c';
