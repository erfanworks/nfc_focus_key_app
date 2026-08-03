import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class BreakController extends GetxController {
  final breaksPerDay = RxnInt(2); // null = "None"
  final breakLengthMinutes = 5.obs;
  final isLoading = false.obs;
  final isSaving = false.obs;

  final breakLengthOptions = [1, 3, 5, 10];

  @override
  void onInit() {
    super.onInit();
    _fetchBreakConfig();
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
      // Silent — fall back to defaults if offline; not a user-facing error.
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
          title: "Couldn't save",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }

      if (Get.previousRoute == Routes.customizeModes) {
        Get.toNamed(Routes.modes);
      } else {
        Get.back();
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    } finally {
      isSaving.value = false;
    }
  }
}