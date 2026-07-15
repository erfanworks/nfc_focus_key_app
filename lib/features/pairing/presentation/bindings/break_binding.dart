import 'package:get/get.dart';
import '../controllers/break_controller.dart';

class BreakBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BreakController>(() => BreakController());
  }
}
