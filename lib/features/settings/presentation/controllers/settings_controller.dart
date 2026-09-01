import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../core/widgets/custom_snackbar.dart';

class SettingsController extends GetxController {
  final personalReminder = ''.obs;

  final userName = ''.obs;
  final userContact = ''.obs;
  final userEmail = ''.obs;
  final isProfileLoading = false.obs;
  final isClearingData = false.obs;

  final totalFocusApps = <Map<String, dynamic>>[].obs;
  final isLoadingTotalFocusApps = false.obs;

  Future<void> fetchProfile() async {
    isProfileLoading.value = true;
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.userProfile,
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        userName.value = data["name"] ?? userName.value;
        userEmail.value = data["email"] ?? userEmail.value;
        if (data["phone"] != null) {
          userContact.value = "${data["countryCode"] ?? ''} ${data["phone"]}".trim();
        }
      } else {
        CustomSnackbar.show(
          title: 'Profile Error',
          message: response?['message'] ?? 'Failed to load user profile.',
          isError: true,
        );
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Connection Error',
        message: 'Could not sync profile. Please check your internet.',
        isError: true,
      );
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<bool> updateProfile(String name) async {
    isProfileLoading.value = true;
    try {
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.updateProfile,
        body: {"name": name},
      );

      if (response != null && response["success"] == true) {
        final data = response["data"];
        userName.value = data["name"] ?? name;
        CustomSnackbar.show(
          title: 'Profile Updated',
          message: 'Your information has been successfully saved.',
        );
        await Future.delayed(const Duration(milliseconds: 1000));
        return true;
      } else {
        CustomSnackbar.show(
          title: 'Update Failed',
          message: response?['message'] ?? 'Failed to update profile.',
          isError: true,
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Network Error',
        message: 'Could not connect to server. Please try again.',
        isError: true,
      );
      return false;
    } finally {
      isProfileLoading.value = false;
    }
  }

  Future<bool> clearAllData() async {
    isClearingData.value = true;
    try {
      final response = await ApiServices.instance.deleteServices(
        url: AppApiUrl.instance.clearAllData,
      );
      if (response != null && response["success"] == true) {
        CustomSnackbar.show(
          title: 'All Data Cleared',
          message: 'Your focus history and settings have been reset.',
        );
        await Future.delayed(const Duration(milliseconds: 1200));
        return true;
      } else {
        CustomSnackbar.show(
          title: 'Action Failed',
          message: response?['message'] ?? 'Failed to clear your data.',
          isError: true,
        );
        return false;
      }
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Connection failed. Could not reach server.',
        isError: true,
      );
      return false;
    } finally {
      isClearingData.value = false;
    }
  }

  Future<void> fetchPersonalReminder() async {
    try {
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.getPersonalReminders,
      );

      if (response != null && response["success"] == true) {
        personalReminder.value = response["data"]?["message"] ?? personalReminder.value;
        await Get.find<AppLockNativeService>().cacheReminderMessage(personalReminder.value);
      }
    } catch (_) {}
  }

  Future<bool> savePersonalReminder(String message) async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.createPersonalReminder,
        body: {"message": message},
      );

      if (response != null && response["success"] == true) {
        personalReminder.value = response["data"]?["message"] ?? message;
        await Get.find<AppLockNativeService>().cacheReminderMessage(personalReminder.value);
        CustomSnackbar.show(
          title: 'Reminder Saved',
          message: 'Your personal reminder is now active.',
        );
        await Future.delayed(const Duration(milliseconds: 1000));
        return true;
      } else {
        CustomSnackbar.show(
          title: 'Save Failed',
          message: response?['message'] ?? 'Could not save your reminder.',
          isError: true,
        );
        return false;
      }
    } catch (_) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Failed to save. Check your connection.',
        isError: true,
      );
      return false;
    }
  }

  Future<void> fetchTotalFocusApps() async {
    try {
      isLoadingTotalFocusApps.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.totalFocusApps,
      );

      if (response != null && response["success"] == true) {
        final List<dynamic> data = response["data"] ?? [];
        totalFocusApps.value = data.cast<Map<String, dynamic>>();
      } else if (response != null) {
        CustomSnackbar.show(
          title: 'Load Error',
          message: response['message'] ?? 'Could not load blocked apps.',
          isError: true,
        );
      }
    } catch (_) {
      CustomSnackbar.show(
        title: 'Connection Error',
        message: 'Failed to sync app list.',
        isError: true,
      );
    } finally {
      isLoadingTotalFocusApps.value = false;
    }
  }
}
