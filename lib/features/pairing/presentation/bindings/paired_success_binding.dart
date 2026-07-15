import 'package:get/get.dart';
import '../controllers/paired_success_controller.dart';

class PairedSuccessBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PairedSuccessController>(() => PairedSuccessController());
  }
}
