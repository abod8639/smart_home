// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'save_rooms_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(saveRoomsUseCase)
final saveRoomsUseCaseProvider = SaveRoomsUseCaseProvider._();

final class SaveRoomsUseCaseProvider
    extends
        $FunctionalProvider<
          SaveRoomsUseCase,
          SaveRoomsUseCase,
          SaveRoomsUseCase
        >
    with $Provider<SaveRoomsUseCase> {
  SaveRoomsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'saveRoomsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$saveRoomsUseCaseHash();

  @$internal
  @override
  $ProviderElement<SaveRoomsUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SaveRoomsUseCase create(Ref ref) {
    return saveRoomsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SaveRoomsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SaveRoomsUseCase>(value),
    );
  }
}

String _$saveRoomsUseCaseHash() => r'ce207f43f33a6b92d30d804a4f42782710fa4335';
