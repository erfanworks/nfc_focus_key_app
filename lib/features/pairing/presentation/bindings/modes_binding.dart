import 'package:get/get.dart';
import '../controllers/modes_controller.dart';

class ModesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModesController>(() => ModesController());
  }
}
