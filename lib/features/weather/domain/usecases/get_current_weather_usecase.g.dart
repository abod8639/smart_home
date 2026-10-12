// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_current_weather_usecase.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for accessing [GetCurrentWeatherUseCase].

@ProviderFor(getCurrentWeatherUseCase)
final getCurrentWeatherUseCaseProvider = GetCurrentWeatherUseCaseProvider._();

/// Provider for accessing [GetCurrentWeatherUseCase].

final class GetCurrentWeatherUseCaseProvider
    extends
        $FunctionalProvider<
          GetCurrentWeatherUseCase,
          GetCurrentWeatherUseCase,
          GetCurrentWeatherUseCase
        >
    with $Provider<GetCurrentWeatherUseCase> {
  /// Provider for accessing [GetCurrentWeatherUseCase].
  GetCurrentWeatherUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getCurrentWeatherUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getCurrentWeatherUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetCurrentWeatherUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetCurrentWeatherUseCase create(Ref ref) {
    return getCurrentWeatherUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetCurrentWeatherUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetCurrentWeatherUseCase>(value),
    );
  }
}

String _$getCurrentWeatherUseCaseHash() =>
    r'10ee4bd557faac9d2ee60348b1b4c43a83142568';
