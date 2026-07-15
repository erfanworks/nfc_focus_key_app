import 'package:get/get.dart';
import '../controllers/user_verify_controller.dart';

class UserVerifyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserVerifyController>(() => UserVerifyController());
  }
}
