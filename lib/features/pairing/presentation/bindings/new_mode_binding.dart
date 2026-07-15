import 'package:get/get.dart';
import '../controllers/new_mode_controller.dart';

class NewModeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewModeController>(() => NewModeController());
  }
}
