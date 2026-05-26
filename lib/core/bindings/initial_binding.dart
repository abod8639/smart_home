import 'package:get/get.dart';
import 'package:smart_home/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:smart_home/features/settings/presentation/controllers/settings_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DashboardController());
    Get.put(SettingsController());
  }
}
