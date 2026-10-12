// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'send_hardware_command_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [SendHardwareCommandUseCase].

@ProviderFor(sendHardwareCommandUseCase)
final sendHardwareCommandUseCaseProvider =
    SendHardwareCommandUseCaseProvider._();

/// Provider for accessing [SendHardwareCommandUseCase].

final class SendHardwareCommandUseCaseProvider
    extends
        $FunctionalProvider<
          SendHardwareCommandUseCase,
          SendHardwareCommandUseCase,
          SendHardwareCommandUseCase
        >
    with $Provider<SendHardwareCommandUseCase> {
  /// Provider for accessing [SendHardwareCommandUseCase].
  SendHardwareCommandUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sendHardwareCommandUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sendHardwareCommandUseCaseHash();

  @$internal
  @override
  $ProviderElement<SendHardwareCommandUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SendHardwareCommandUseCase create(Ref ref) {
    return sendHardwareCommandUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SendHardwareCommandUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SendHardwareCommandUseCase>(value),
    );
  }
}

String _$sendHardwareCommandUseCaseHash() =>
    r'bab1318237648a66ecd33a1cbf11c9b7df06590e';
