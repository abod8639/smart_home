// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing the [RoomRepository] implementation.

@ProviderFor(roomRepository)
final roomRepositoryProvider = RoomRepositoryProvider._();

/// Provider for accessing the [RoomRepository] implementation.

final class RoomRepositoryProvider
    extends $FunctionalProvider<RoomRepository, RoomRepository, RoomRepository>
    with $Provider<RoomRepository> {
  /// Provider for accessing the [RoomRepository] implementation.
  RoomRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoomRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RoomRepository create(Ref ref) {
    return roomRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoomRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoomRepository>(value),
    );
  }
}

String _$roomRepositoryHash() => r'ef3765ad9ae68f88cff97e127dd2358db863ad11';
