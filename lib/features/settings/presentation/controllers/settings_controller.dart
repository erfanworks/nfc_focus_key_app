import 'package:get/get.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/services/api_service.dart';

class SettingsController extends GetxController {
  final personalReminder = 'I want to stay focused for..'.obs;

  final userName = 'Jhon Lura'.obs;
  final userContact = '+88 9999 9999'.obs;
  final userEmail = 'jhon@mail.com'.obs;
  final isProfileLoading = false.obs;
  final isClearingData = false.obs;

  // Total Focus apps — real list, fetched on demand.
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
      }
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
        return true;
      }
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
      return response != null && response["success"] == true;
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
        return true;
      }
      return false;
    } catch (_) {
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
      }
    } catch (_) {
      // Silent — list stays empty/cached; not critical enough to alarm the user.
    } finally {
      isLoadingTotalFocusApps.value = false;
    }
  }
}