// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod controller managing ambient environment state.

@ProviderFor(EnvironmentController)
final environmentControllerProvider = EnvironmentControllerProvider._();

/// Riverpod controller managing ambient environment state.
final class EnvironmentControllerProvider
    extends $NotifierProvider<EnvironmentController, EnvironmentState> {
  /// Riverpod controller managing ambient environment state.
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
    r'1e4c408b51e8ed93dad7e31f54866b18eaffcdfa';

/// Riverpod controller managing ambient environment state.

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
