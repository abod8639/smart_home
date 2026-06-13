// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matter_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(MatterService)
final matterServiceProvider = MatterServiceProvider._();

final class MatterServiceProvider
    extends $NotifierProvider<MatterService, void> {
  MatterServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matterServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matterServiceHash();

  @$internal
  @override
  MatterService create() => MatterService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$matterServiceHash() => r'114c1e1c20616f832f50efdf8e4417dd1d80a143';

abstract class _$MatterService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
