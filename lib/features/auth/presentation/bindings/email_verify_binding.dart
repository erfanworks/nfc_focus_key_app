import 'package:get/get.dart';
import '../controllers/email_verify_controller.dart';

class EmailVerifyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailVerifyController>(() => EmailVerifyController());
  }
}
