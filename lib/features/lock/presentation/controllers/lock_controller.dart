import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/services/nfc_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';

class LockController extends GetxController {
  final isLocked = false.obs;
  final selectedMode = 'Deep work.'.obs;
  final todayTime = '0m'.obs;
  final thisWeekTime = '0m'.obs;
  final sessionSeconds = 0.obs;
  final totalBlockedApps = 0.obs;

  String? activeModeId;
  final Rxn<String> selectedModeIdRx = Rxn<String>();
  String? get selectedModeId => selectedModeIdRx.value;

  final isOnBreak = false.obs;
  final breakSeconds = 150.obs;
  final isBreakPaused = false.obs;
  final breaksLeft = 1.obs;
  final personalBreakLengthMinutes = 5.obs;
  final isLoadingBreakSettings = true.obs;
  final isHoldingCancel = false.obs;

  final isLoadingStatus = false.obs;

  Timer? _timer;
  Timer? _breakTimer;

  @override
  void onInit() {
    super.onInit();
    fetchLockStatus();
    _fetchPersonalBreakLength();
  }

  Future<void> refreshPersonalBreakSettings() async {
    await _fetchPersonalBreakLength();
    await fetchLockStatus();
  }

  Future<void> _fetchPersonalBreakLength() async {
    try {
      isLoadingBreakSettings.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.breakConfig,
      );
      if (response == null || response["success"] != true) return;
      personalBreakLengthMinutes.value = response["data"]?["breakDurationMinutes"] ?? 5;
    } catch (_) {
    } finally {
      isLoadingBreakSettings.value = false;
    }
  }

  Future<void> fetchLockStatus() async {
    try {
      isLoadingStatus.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.lockStatus,
      );

      if (response == null || response["success"] != true) {
         if (response != null) {
            CustomSnackbar.show(
              title: "Sync Failed",
              message: response["message"] ?? "Could not update focus status.",
              isError: true,
            );
         }
         return;
      }

      final data = response["data"];
      if (data == null) return;

      final lockStatus = data["lockStatus"] ?? {};
      final activeMode = data["activeMode"];
      final focusStats = data["focusStats"] ?? {};
      final breakStats = data["breakStats"] ?? {};

      isLocked.value = lockStatus["isLocked"] == true;
      if (lockStatus["activeModeName"] != null) {
        selectedMode.value = lockStatus["activeModeName"];
      }
      activeModeId = activeMode != null ? activeMode["_id"] as String? : null;

      todayTime.value = _formatMinutes(focusStats["todayMinutes"] ?? 0);
      thisWeekTime.value = _formatMinutes(focusStats["weekMinutes"] ?? 0);
      breaksLeft.value = breakStats["remainingToday"] ?? 0;
      totalBlockedApps.value = data["totalBlockedApps"] ?? 0;

      final activeBreak = breakStats["activeBreak"];
      if (activeBreak != null) {
        try {
          final end = DateTime.parse(activeBreak["endTime"]);
          final remaining = end.difference(DateTime.now()).inSeconds;
          if (remaining > 0) {
            isOnBreak.value = true;
            breakSeconds.value = remaining;
            _startBreakTimer();
          }
        } catch (_) {}
      }

      if (isLocked.value) {
        _resumeOrStartTimer(data["activeSession"]);
      } else {
        _stopTimer();
      }
    } catch (e) {
      CustomSnackbar.show(
        title: "Connection Issue",
        message: "Failed to fetch focus status. Check your internet.",
        isError: true,
      );
    } finally {
      isLoadingStatus.value = false;
    }
  }

  String _formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  void _resumeOrStartTimer(dynamic activeSession) {
    if (activeSession is Map<String, dynamic>) {
      final elapsedMinutes = activeSession['elapsedMinutes'];
      if (elapsedMinutes is int) {
        sessionSeconds.value = elapsedMinutes * 60;
        _startTimer();
        return;
      }
      final raw = activeSession['startTime'] ??
          activeSession['startedAt'] ??
          activeSession['createdAt'];
      if (raw != null) {
        try {
          final start = DateTime.parse(raw as String);
          final elapsed = DateTime.now().difference(start).inSeconds;
          if (elapsed >= 0) {
            sessionSeconds.value = elapsed;
            _startTimer();
            return;
          }
        } catch (_) {}
      }
    }
    sessionSeconds.value = 0;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isOnBreak.value) {
        sessionSeconds.value++;
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
    sessionSeconds.value = 0;
  }

  String get formattedSessionTime {
    final hours = sessionSeconds.value ~/ 3600;
    final minutes = (sessionSeconds.value % 3600) ~/ 60;
    final seconds = sessionSeconds.value % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> startBreak() async {
    if (!isLocked.value) return;

    final friendsController = Get.find<FriendsController>();
    final nudge = friendsController.currentNudge.value;
    final isNudgeSession = nudge != null && nudge.isActive && nudge.nudgeId != null;

    if (isNudgeSession) {
      await _startNudgeBreak(friendsController, nudge!.nudgeId!);
    } else {
      await _startPersonalBreak();
    }
  }

  Future<void> _startPersonalBreak() async {
    if (activeModeId == null) return;
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.breakStart,
        body: {"modeId": activeModeId},
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Break Error",
          message: response?["message"] ?? "Could not start your break.",
          isError: true,
        );
        return;
      }

      final data = response["data"];
      _applyBreakDuration(data["startTime"], data["endTime"]);
      if (breaksLeft.value > 0) breaksLeft.value -= 1;
      
      CustomSnackbar.show(
        title: "Break Started",
        message: "Your apps are now available.",
      );
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "A network error occurred. Please try again.",
        isError: true,
      );
    }
  }

  Future<void> _startNudgeBreak(FriendsController friendsController, String nudgeId) async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.takeNudgeBreak(nudgeId),
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Break Error",
          message: response?["message"] ?? "Could not start nudge break.",
          isError: true,
        );
        return;
      }

      final data = response["data"];
      final breakInfo = data["break"] ?? {};
      _applyBreakDuration(breakInfo["startTime"], breakInfo["endTime"]);
      await friendsController.fetchCurrentNudgeStatus();

      CustomSnackbar.show(
        title: "Shared Break",
        message: "Focus session paused for the team.",
      );
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "Failed to sync shared break. Check your connection.",
        isError: true,
      );
    }
  }

  void _applyBreakDuration(String? startTime, String? endTime) {
    int seconds = 150;
    try {
      if (startTime != null && endTime != null) {
        final start = DateTime.parse(startTime);
        final end = DateTime.parse(endTime);
        seconds = end.difference(start).inSeconds;
      }
    } catch (_) {}

    isOnBreak.value = true;
    isBreakPaused.value = false;
    breakSeconds.value = seconds;
    _stopTimer();
    _startBreakTimer();
  }

  void toggleBreakPause() {
    isBreakPaused.value = !isBreakPaused.value;
    if (isBreakPaused.value) {
      _breakTimer?.cancel();
    } else {
      _startBreakTimer();
    }
  }

  void _startBreakTimer() {
    _breakTimer?.cancel();
    _breakTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (breakSeconds.value > 0) {
        breakSeconds.value--;
      } else {
        endBreak();
      }
    });
  }

  void endBreak() {
    _breakTimer?.cancel();
    _breakTimer = null;
    isOnBreak.value = false;
    isBreakPaused.value = false;
    if (isLocked.value) {
      _startTimer();
    }
  }

  String get formattedBreakTime {
    final minutes = breakSeconds.value ~/ 60;
    final seconds = breakSeconds.value % 60;
    return '${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  final NfcService _nfcService = NfcService();
  final isScanningNfc = false.obs;
  final isTogglingLock = false.obs;

  void toggleLock() async {
    if (isTogglingLock.value) return;

    if (!isLocked.value) {
      if (selectedModeId == null || selectedModeId!.isEmpty) {
        CustomSnackbar.show(
          title: 'Pick a Mode',
          message: 'Select a focus mode before starting your session.',
          isError: true,
        );
        return;
      }
      await _activateMode(selectedModeId!);
      return;
    }

    if (isScanningNfc.value) return;
    isScanningNfc.value = true;
    _showAndroidNfcScanner();

    _nfcService.startScanning(
      onTagScanned: (tagId) async {
        isScanningNfc.value = false;
        _dismissAndroidNfcScanner();

        final pairedId = await StorageServices.instance.getPairedKeyId();

        if (tagId == pairedId) {
          await HapticFeedback.vibrate();
          if (activeModeId == null || activeModeId!.isEmpty) {
            CustomSnackbar.show(
              title: "Unlock Error",
              message: 'No active mode session found.',
              isError: true,
            );
            return;
          }
          await _deactivateMode(activeModeId!);
          return;
        }

        if (pairedId == null || pairedId.isEmpty) {
          final verified = await _verifyKeyWithBackend(tagId);
          if (verified) {
            await HapticFeedback.vibrate();
            if (activeModeId == null || activeModeId!.isEmpty) {
              CustomSnackbar.show(
                title: "Unlock Error",
                message: 'Session data not available on server.',
                isError: true,
              );
              return;
            }
            await _deactivateMode(activeModeId!);
            return;
          }
        }

        HapticFeedback.heavyImpact();
        CustomSnackbar.show(
          title: 'Access Denied',
          message: 'This key is not paired with your device.',
          isError: true,
        );
      },
      onError: (error) {
        isScanningNfc.value = false;
        _dismissAndroidNfcScanner();
        HapticFeedback.heavyImpact();
        CustomSnackbar.show(title: 'Scan Failed', message: error, isError: true);
      },
    );
  }

  Future<bool> _verifyKeyWithBackend(String tagId) async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String deviceModel = '';
      String deviceFingerprint = '';

      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        deviceModel = info.model;
        deviceFingerprint = info.id;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        deviceModel = info.utsname.machine;
        deviceFingerprint = info.identifierForVendor ?? '';
      }

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.pairing,
        body: {
          "uid": tagId,
          "device_model": deviceModel,
          "platform": Platform.isIOS ? "ios" : "android",
          "deviceFingerprint": deviceFingerprint,
        },
      );

      if (response == null || response["success"] != true) return false;
      await StorageServices.instance.savePairedKeyId(tagId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _activateMode(String modeId) async {
    try {
      isTogglingLock.value = true;
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.toggleModeActivation(modeId),
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: 'Session Failed',
          message: response?["message"] ?? 'Could not start focus session.',
          isError: true,
        );
        return;
      }

      activeModeId = modeId;
      isLocked.value = true;
      sessionSeconds.value = 0;
      _startTimer();
      CustomSnackbar.show(
        title: 'Locked',
        message: 'Your device is now locked. Scan your NFC key to unlock.',
      );
      
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      CustomSnackbar.show(
        title: 'Network Error',
        message: 'Failed to activate focus. Check your connection.',
        isError: true,
      );
    } finally {
      isTogglingLock.value = false;
    }
  }

  Future<void> _deactivateMode(String modeId) async {
    try {
      isTogglingLock.value = true;
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.toggleModeActivation(modeId),
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: 'Unlock Failed',
          message: response?["message"] ?? 'Could not end focus session.',
          isError: true,
        );
        return;
      }

      isLocked.value = false;
      activeModeId = null;
      _stopTimer();
      endBreak();
      
      CustomSnackbar.show(
        title: 'Session Ended', 
        message: 'Welcome back! You made great progress.',
      );
      
      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Connection issue. Failed to end session on server.',
        isError: true,
      );
    } finally {
      isTogglingLock.value = false;
    }
  }

  void _showAndroidNfcScanner() {
    if (GetPlatform.isAndroid) {
      Get.bottomSheet(
        Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Color(0xFFF7F4EE),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
                strokeWidth: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ready to Scan',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1814),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hold your Focus Key against the back of your phone',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF8A8278)),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        isDismissible: true,
        enableDrag: true,
      );
    }
  }

  void _dismissAndroidNfcScanner() {
    if (GetPlatform.isAndroid && Get.isBottomSheetOpen == true) {
      Get.back();
    }
  }

  void selectMode(ModeItem mode) {
    selectedMode.value = mode.title;
    selectedModeIdRx.value = mode.id;
  }

  @override
  void onClose() {
    _stopTimer();
    _breakTimer?.cancel();
    _nfcService.stopScanning();
    super.onClose();
  }
}
