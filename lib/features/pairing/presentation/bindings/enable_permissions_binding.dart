import 'package:get/get.dart';
import '../controllers/enable_permissions_controller.dart';

class EnablePermissionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => EnablePermissionsController());
  }
}