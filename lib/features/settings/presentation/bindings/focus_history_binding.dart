import 'package:get/get.dart';
import '../controllers/focus_history_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FocusHistoryController(), permanent: true);
  }
}
