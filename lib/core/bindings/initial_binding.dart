import 'package:get/get.dart';
import 'package:smart_home/core/services/esp32_service.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SettingsController());
    Get.put(Esp32Service());
    Get.put(DashboardController());
  }
}
