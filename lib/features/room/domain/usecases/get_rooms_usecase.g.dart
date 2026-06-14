// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_rooms_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [GetRoomsUseCase].

@ProviderFor(getRoomsUseCase)
final getRoomsUseCaseProvider = GetRoomsUseCaseProvider._();

/// Provider for accessing [GetRoomsUseCase].

final class GetRoomsUseCaseProvider
    extends
        $FunctionalProvider<GetRoomsUseCase, GetRoomsUseCase, GetRoomsUseCase>
    with $Provider<GetRoomsUseCase> {
  /// Provider for accessing [GetRoomsUseCase].
  GetRoomsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getRoomsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getRoomsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetRoomsUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetRoomsUseCase create(Ref ref) {
    return getRoomsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetRoomsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetRoomsUseCase>(value),
    );
  }
}

String _$getRoomsUseCaseHash() => r'1ad5675c72a123c49436834ff97291a016468ce1';
