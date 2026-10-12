// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'environment_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod provider for [EnvironmentRepository].

@ProviderFor(environmentRepository)
final environmentRepositoryProvider = EnvironmentRepositoryProvider._();

/// Riverpod provider for [EnvironmentRepository].

final class EnvironmentRepositoryProvider
    extends
        $FunctionalProvider<
          EnvironmentRepository,
          EnvironmentRepository,
          EnvironmentRepository
        >
    with $Provider<EnvironmentRepository> {
  /// Riverpod provider for [EnvironmentRepository].
  EnvironmentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'environmentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$environmentRepositoryHash();

  @$internal
  @override
  $ProviderElement<EnvironmentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EnvironmentRepository create(Ref ref) {
    return environmentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EnvironmentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EnvironmentRepository>(value),
    );
  }
}

String _$environmentRepositoryHash() =>
    r'253ac6d6d616e92f3d6bcf9836bc8d64672d3376';
