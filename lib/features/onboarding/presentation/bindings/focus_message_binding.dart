import 'package:get/get.dart';
import '../controllers/focus_message_controller.dart';

class FocusMessageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => FocusMessageController());
  }
}
