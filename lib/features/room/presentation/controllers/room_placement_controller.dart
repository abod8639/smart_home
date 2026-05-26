import 'package:get/get.dart';

class RoomPlacementController extends GetxController {
  // Observables
  var selectedDeviceId = RxnString();

  // Actions
  void selectDevice(String? id) {
    selectedDeviceId.value = id;
  }
}
