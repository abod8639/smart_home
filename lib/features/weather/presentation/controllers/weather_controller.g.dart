// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WeatherController)
final weatherControllerProvider = WeatherControllerProvider._();

final class WeatherControllerProvider
    extends $NotifierProvider<WeatherController, WeatherState> {
  WeatherControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherControllerHash();

  @$internal
  @override
  WeatherController create() => WeatherController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherState>(value),
    );
  }
}

String _$weatherControllerHash() => r'ee3b25d5d415e7d327082b7a129dfa611243ebca';

abstract class _$WeatherController extends $Notifier<WeatherState> {
  WeatherState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WeatherState, WeatherState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WeatherState, WeatherState>,
              WeatherState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
