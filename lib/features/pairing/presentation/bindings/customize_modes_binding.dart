import 'package:get/get.dart';
import '../controllers/customize_modes_controller.dart';

class CustomizeModesBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CustomizeModesController>(() => CustomizeModesController());
  }
}
