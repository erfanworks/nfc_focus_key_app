import 'package:focus_key/features/lock/presentation/controllers/lock_controller.dart';
import 'package:get/get.dart';

class LockPageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LockController>(() => LockController());
  }
}