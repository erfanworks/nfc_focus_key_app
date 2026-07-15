import 'package:get/get.dart';
import '../controllers/lets_unlock_controller.dart';

class LetsUnlockBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LetsUnlockController>(() => LetsUnlockController());
  }
}
