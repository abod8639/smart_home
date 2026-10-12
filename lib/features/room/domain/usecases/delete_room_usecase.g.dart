// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_room_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [DeleteRoomUseCase].

@ProviderFor(deleteRoomUseCase)
final deleteRoomUseCaseProvider = DeleteRoomUseCaseProvider._();

/// Provider for accessing [DeleteRoomUseCase].

final class DeleteRoomUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteRoomUseCase,
          DeleteRoomUseCase,
          DeleteRoomUseCase
        >
    with $Provider<DeleteRoomUseCase> {
  /// Provider for accessing [DeleteRoomUseCase].
  DeleteRoomUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteRoomUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteRoomUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteRoomUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteRoomUseCase create(Ref ref) {
    return deleteRoomUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteRoomUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteRoomUseCase>(value),
    );
  }
}

String _$deleteRoomUseCaseHash() => r'1aaaa6fbcaf53ff5c142979c38645690e1200536';
