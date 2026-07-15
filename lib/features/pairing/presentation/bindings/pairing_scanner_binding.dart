import 'package:get/get.dart';
import '../controllers/pairing_scanner_controller.dart';

class PairingScannerBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PairingScannerController>(() => PairingScannerController());
  }
}
