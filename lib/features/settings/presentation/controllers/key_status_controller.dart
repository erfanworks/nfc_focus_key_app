import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';

class KeyStatusController extends GetxController {
  final RxBool isPaired = false.obs;
  final RxBool showConfirmUnpair = false.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPairedStatus();
  }

  Future<void> _loadPairedStatus() async {
    isLoading.value = true;
    isPaired.value = await StorageServices.instance.hasPairedKey();
    isLoading.value = false;
  }

  void requestUnpairConfirmation() {
    showConfirmUnpair.value = true;
  }

  void cancelUnpair() {
    showConfirmUnpair.value = false;
  }

  Future<void> confirmUnpair() async {
    showConfirmUnpair.value = false;
    await StorageServices.instance.clearPairedKeyId();
    isPaired.value = false;
  }
}