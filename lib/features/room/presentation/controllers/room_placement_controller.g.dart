// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'room_placement_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// State notifier class managing selected device for room placement configuration.

@ProviderFor(RoomPlacementController)
final roomPlacementControllerProvider = RoomPlacementControllerProvider._();

/// State notifier class managing selected device for room placement configuration.
final class RoomPlacementControllerProvider
    extends $NotifierProvider<RoomPlacementController, String?> {
  /// State notifier class managing selected device for room placement configuration.
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

/// State notifier class managing selected device for room placement configuration.

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
