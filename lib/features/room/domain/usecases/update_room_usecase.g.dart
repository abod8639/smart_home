// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_room_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [UpdateRoomUseCase].

@ProviderFor(updateRoomUseCase)
final updateRoomUseCaseProvider = UpdateRoomUseCaseProvider._();

/// Provider for accessing [UpdateRoomUseCase].

final class UpdateRoomUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateRoomUseCase,
          UpdateRoomUseCase,
          UpdateRoomUseCase
        >
    with $Provider<UpdateRoomUseCase> {
  /// Provider for accessing [UpdateRoomUseCase].
  UpdateRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateRoomUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateRoomUseCase create(Ref ref) {
    return updateRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateRoomUseCase>(value),
    );
  }
}

String _$updateRoomUseCaseHash() => r'26d9eecf80f56283ec94aac256f56818df22be7e';
