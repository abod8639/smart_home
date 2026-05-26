import 'package:get/get.dart';
import 'dashboard_controller.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<SettingsController>(() => SettingsController());
  }
}
