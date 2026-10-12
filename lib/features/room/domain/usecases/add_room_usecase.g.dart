// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_room_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [AddRoomUseCase].

@ProviderFor(addRoomUseCase)
final addRoomUseCaseProvider = AddRoomUseCaseProvider._();

/// Provider for accessing [AddRoomUseCase].

final class AddRoomUseCaseProvider
    extends $FunctionalProvider<AddRoomUseCase, AddRoomUseCase, AddRoomUseCase>
    with $Provider<AddRoomUseCase> {
  /// Provider for accessing [AddRoomUseCase].
  AddRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddRoomUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AddRoomUseCase create(Ref ref) {
    return addRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddRoomUseCase>(value),
    );
  }
}

String _$addRoomUseCaseHash() => r'91ce706a2c5d0280ab856f4e242e17145e383016';
