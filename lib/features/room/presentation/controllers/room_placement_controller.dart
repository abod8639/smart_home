import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_placement_controller.g.dart';

/// State notifier class managing selected device for room placement configuration.
@riverpod
class RoomPlacementController extends _$RoomPlacementController {
  @override
  String? build() {
    return null;
  }

  /// Sets the currently selected device by [id].
  void selectDevice(String? id) {
    state = id;
  }
}
