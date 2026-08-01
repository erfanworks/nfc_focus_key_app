import 'dart:io';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../../../../core/services/nfc_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';

class PairingScannerController extends GetxController {
  final isPairing = false.obs;
  final statusMessage =
      'Hold your key against the front camera of your phone'.obs;

  final NfcService _nfcService = NfcService();

  @override
  void onReady() {
    super.onReady();
    startPairing();
  }

  void startPairing() {
    if (isPairing.value) return;

    isPairing.value = true;
    statusMessage.value =
    'Hold your key against the front camera of your phone';

    _nfcService.startScanning(
      onTagScanned: _onTagScanned,
      onError: _onScanError,
    );
  }

  Future<void> _onTagScanned(String uid) async {
    try {
      statusMessage.value = 'Key Found! Verifying...';
      await HapticFeedback.vibrate();

      final deviceModel = await _getDeviceModel();
      final deviceFingerprint = await _getDeviceFingerprint();

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.pairing,
        body: {
          "uid": uid,
          "device_model": deviceModel,
          "platform": Platform.isIOS ? "ios" : "android",
          "deviceFingerprint": deviceFingerprint,
        },
      );

      if (response == null || response["success"] != true) {
        _resetAfterFailure(
          response?["message"] ?? "Pairing failed. Please try again.",
        );
        return;
      }

      await StorageServices.instance.savePairedKeyId(uid);

      CustomSnackbar.show(
        title: "Paired",
        message: "Your key has been paired successfully.",
      );
      Get.offNamed(Routes.paired);
    } catch (e) {
      _resetAfterFailure("Something went wrong while pairing.");
    } finally {
      isPairing.value = false;
    }
  }

  void _onScanError(String error) {
    isPairing.value = false;
    statusMessage.value = 'Hold your key against the front camera of your phone';
    CustomSnackbar.show(title: "Scan failed", message: error, isError: true);
  }

  void _resetAfterFailure(String message) {
    statusMessage.value = 'Hold your key against the front camera of your phone';
    CustomSnackbar.show(title: "Pairing failed", message: message, isError: true);
  }

  Future<String> _getDeviceModel() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        return (await deviceInfo.androidInfo).model;
      } else if (Platform.isIOS) {
        return (await deviceInfo.iosInfo).utsname.machine;
      }
    } catch (_) {}
    return "";
  }

  Future<String> _getDeviceFingerprint() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        return (await deviceInfo.androidInfo).id;
      } else if (Platform.isIOS) {
        return (await deviceInfo.iosInfo).identifierForVendor ?? "";
      }
    } catch (_) {}
    return "";
  }

  @override
  void onClose() {
    _nfcService.stopScanning();
    super.onClose();
  }
}