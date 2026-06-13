// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'esp32_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Professional and flexible control service for ESP32 microcontrollers using MQTT

@ProviderFor(Esp32Service)
final esp32ServiceProvider = Esp32ServiceProvider._();

/// Professional and flexible control service for ESP32 microcontrollers using MQTT
final class Esp32ServiceProvider extends $NotifierProvider<Esp32Service, void> {
  /// Professional and flexible control service for ESP32 microcontrollers using MQTT
  Esp32ServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'esp32ServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$esp32ServiceHash();

  @$internal
  @override
  Esp32Service create() => Esp32Service();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$esp32ServiceHash() => r'a8ae595397f8849c81a2ec446638e5af47614ab4';

/// Professional and flexible control service for ESP32 microcontrollers using MQTT

abstract class _$Esp32Service extends $Notifier<void> {
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
