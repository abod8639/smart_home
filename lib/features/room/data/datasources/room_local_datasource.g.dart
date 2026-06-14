// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_local_datasource.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(roomLocalDatasource)
final roomLocalDatasourceProvider = RoomLocalDatasourceProvider._();

final class RoomLocalDatasourceProvider
    extends
        $FunctionalProvider<
          RoomLocalDatasource,
          RoomLocalDatasource,
          RoomLocalDatasource
        >
    with $Provider<RoomLocalDatasource> {
  RoomLocalDatasourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomLocalDatasourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomLocalDatasourceHash();

  @$internal
  @override
  $ProviderElement<RoomLocalDatasource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoomLocalDatasource create(Ref ref) {
    return roomLocalDatasource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoomLocalDatasource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoomLocalDatasource>(value),
    );
  }
}

String _$roomLocalDatasourceHash() =>
    r'2eedb78b838a480bd0cdd3ef1c71bee9914faa98';
