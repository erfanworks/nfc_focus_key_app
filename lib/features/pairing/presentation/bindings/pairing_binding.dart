import 'package:get/get.dart';
import '../controllers/pairing_controller.dart';

class PairingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PairingController>(() => PairingController());
  }
}
