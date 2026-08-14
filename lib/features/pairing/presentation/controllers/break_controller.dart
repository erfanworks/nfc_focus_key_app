import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../lock/presentation/controllers/lock_controller.dart';

class BreakController extends GetxController {
  final breaksPerDay = RxnInt(2); // null = "None"
  final breakLengthMinutes = 5.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  final breakLengthOptions = [1, 3, 5, 10];

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    final isNudgeFlow = args?['isNudgeFlow'] == true;
    if (!isNudgeFlow) {
      _fetchBreakConfig();
    }
  }

  Future<void> _fetchBreakConfig() async {
    try {
      isLoading.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.breakConfig,
      );

      if (response == null || response["success"] != true) return;

      final data = response["data"];
      if (data == null) return;

      final perDay = data["breaksPerDay"];
      breaksPerDay.value = (perDay == null || perDay == 0) ? null : perDay;
      breakLengthMinutes.value = data["breakDurationMinutes"] ?? 5;
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  void selectBreaksPerDay(int? value) {
    breaksPerDay.value = value;
  }

  void selectBreakLength(int minutes) {
    breakLengthMinutes.value = minutes;
  }

  Future<void> onContinue() async {
    if (isSaving.value) return;

    final args = Get.arguments as Map<String, dynamic>?;
    final isNudgeFlow = args?['isNudgeFlow'] == true;

    if (isNudgeFlow) {
      Get.toNamed(
        Routes.friendDetails,
        arguments: {
          'selectedFriends': args?['participantIds'],
          'modeId': args?['modeId'],
          'breaksPerDay': breaksPerDay.value ?? 0,
          'breakDurationMinutes': breakLengthMinutes.value,
        },
      );
      return;
    }

    try {
      isSaving.value = true;
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.breakCreateOrUpdateGlobally,
        body: {
          "breaksPerDay": breaksPerDay.value ?? 0,
          "breakDurationMinutes": breakLengthMinutes.value,
        },
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Save Failed",
          message: response?["message"] ?? "Could not update break settings.",
          isError: true,
        );
        return;
      }

      CustomSnackbar.show(title: "Settings Saved", message: "Your break limits have been updated.");
      
      if (Get.isRegistered<LockController>()) {
        Get.find<LockController>().refreshPersonalBreakSettings();
      }

      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (Get.previousRoute == Routes.customizeModes) {
        Get.toNamed(Routes.modes);
      } else {
        Get.back();
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Error",
        message: "Failed to reach server. Please try again.",
        isError: true,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
