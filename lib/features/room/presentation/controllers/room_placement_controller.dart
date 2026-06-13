import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'room_placement_controller.g.dart';

@riverpod
class RoomPlacementController extends _$RoomPlacementController {
  @override
  String? build() {
    return null;
  }

  void selectDevice(String? id) {
    state = id;
  }
}
