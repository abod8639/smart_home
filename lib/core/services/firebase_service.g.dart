// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FirebaseService)
final firebaseServiceProvider = FirebaseServiceProvider._();

final class FirebaseServiceProvider
    extends $NotifierProvider<FirebaseService, void> {
  FirebaseServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'firebaseServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$firebaseServiceHash();

  @$internal
  @override
  FirebaseService create() => FirebaseService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$firebaseServiceHash() => r'78a56a72c9b59b0dce293142ae9ea4755767e1e4';

abstract class _$FirebaseService extends $Notifier<void> {
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
