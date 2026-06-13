// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_placement_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RoomPlacementController)
final roomPlacementControllerProvider = RoomPlacementControllerProvider._();

final class RoomPlacementControllerProvider
    extends $NotifierProvider<RoomPlacementController, String?> {
  RoomPlacementControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roomPlacementControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roomPlacementControllerHash();

  @$internal
  @override
  RoomPlacementController create() => RoomPlacementController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$roomPlacementControllerHash() =>
    r'961908243921e2b7a58d3ecd16c8c89537b6f86d';

abstract class _$RoomPlacementController extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
