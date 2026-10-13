import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../../../lock/presentation/controllers/lock_controller.dart';
import '../../../history/presentation/controllers/history_controller.dart';
import '../../../settings/presentation/controllers/settings_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<LockController>(() => LockController());
    Get.lazyPut<HistoryController>(() => HistoryController());
    Get.put<SettingsController>(SettingsController());
  }
}
