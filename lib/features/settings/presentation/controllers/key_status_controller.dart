import 'package:get/get.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class KeyStatusController extends GetxController {
  final RxBool isPaired = false.obs;
  final RxBool showConfirmUnpair = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isUnpairing = false.obs;

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
    if (isUnpairing.value) return;
    showConfirmUnpair.value = false;

    try {
      isUnpairing.value = true;

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.unpairing,
        body: {},
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Unpair failed",
          message: response?["message"] ?? "Could not unpair the key. Try again.",
          isError: true,
        );
        return;
      }

      await StorageServices.instance.clearPairedKeyId();
      isPaired.value = false;
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    } finally {
      isUnpairing.value = false;
    }
  }
}