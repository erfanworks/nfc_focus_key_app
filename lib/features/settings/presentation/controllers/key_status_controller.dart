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
    loadPairedStatus();
  }

  Future<void> loadPairedStatus() async {
    try {
      isLoading.value = true;
      isPaired.value = await StorageServices.instance.hasPairedKey();
    } catch (_) {
    } finally {
      isLoading.value = false;
    }
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
          title: "Unpair Failed",
          message: response?["message"] ?? "Could not unpair the key. Try again.",
          isError: true,
        );
        return;
      }

      await StorageServices.instance.clearPairedKeyId();
      isPaired.value = false;
      CustomSnackbar.show(
        title: 'Successfully Unpaired',
        message: 'Your Focus Key has been removed.',
      );
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to communicate with server. Check your internet.",
        isError: true,
      );
    } finally {
      isUnpairing.value = false;
    }
  }
}
