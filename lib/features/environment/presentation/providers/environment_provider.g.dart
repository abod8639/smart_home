// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EnvironmentController)
final environmentControllerProvider = EnvironmentControllerProvider._();

final class EnvironmentControllerProvider
    extends $NotifierProvider<EnvironmentController, EnvironmentState> {
  EnvironmentControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentControllerHash();

  @$internal
  @override
  EnvironmentController create() => EnvironmentController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvironmentState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvironmentState>(value),
    );
  }
}

String _$environmentControllerHash() =>
    r'78f12dd8c1b31bc10bb33c0097163b807096c856';

abstract class _$EnvironmentController extends $Notifier<EnvironmentState> {
  EnvironmentState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<EnvironmentState, EnvironmentState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EnvironmentState, EnvironmentState>,
              EnvironmentState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
