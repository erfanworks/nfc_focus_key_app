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

  // Currently active mode's backend id — sourced from lock-status response.
  // Needed to call toggle-activation on unlock. Populated on load / after lock.
  String? activeModeId;

  // Mode the user picks to START a session with. Must be set with a real
  // backend mode id (from ModesController once it fetches real /modes data)
  // before toggleLock() can activate it.
  final Rxn<String> selectedModeIdRx = Rxn<String>();
  String? get selectedModeId => selectedModeIdRx.value;

  // Break State Variables — kept local; startBreak() branches between the
  // personal (per-mode) and nudge break endpoints depending on session type.
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

  // Public so other controllers (e.g. Settings' BreakController after a
  // config save) can force this to re-sync — otherwise the Lock screen's
  // break card silently goes stale.
  Future<void> refreshPersonalBreakSettings() async {
    print('🔄 [BREAK REFRESH] Called — before: minutes=${personalBreakLengthMinutes.value}, breaksLeft=${breaksLeft.value}');
    await _fetchPersonalBreakLength();
    await fetchLockStatus();
    print('✅ [BREAK REFRESH] Done — after: minutes=${personalBreakLengthMinutes.value}, breaksLeft=${breaksLeft.value}');
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
      // Non-critical for display — keep default.
    } finally {
      isLoadingBreakSettings.value = false;
    }
  }

  // ==================== Lock Status ====================
  Future<void> fetchLockStatus() async {
    try {
      isLoadingStatus.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.lockStatus,
      );

      if (response == null || response["success"] != true) return;

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
        title: "Couldn't load status",
        message: "Failed to fetch your current focus status.",
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

  // NOTE: activeSession's exact start-time field name isn't confirmed in the
  // API docs (only ever seen as null so far). Tries common field names;
  // falls back to a fresh timer at 0 if the shape doesn't match — confirm
  // the real field name with backend dev once activeSession is populated.
  void _resumeOrStartTimer(dynamic activeSession) {
    if (activeSession is Map<String, dynamic>) {
      // Backend provides this directly — confirmed reliable, prefer it
      // over calculating from startTime.
      final elapsedMinutes = activeSession['elapsedMinutes'];
      if (elapsedMinutes is int) {
        sessionSeconds.value = elapsedMinutes * 60;
        _startTimer();
        return;
      }

      // Fallback if elapsedMinutes isn't present for some reason.
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

  // ==================== Break Actions ====================
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
          title: "Couldn't start break",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }

      final data = response["data"];
      _applyBreakDuration(data["startTime"], data["endTime"]);
      if (breaksLeft.value > 0) breaksLeft.value -= 1;
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
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
          title: "Couldn't start break",
          message: response?["message"] ?? "Please try again.",
          isError: true,
        );
        return;
      }

      final data = response["data"];
      final breakInfo = data["break"] ?? {};
      _applyBreakDuration(breakInfo["startTime"], breakInfo["endTime"]);
      // Refresh from server rather than guessing locally — keeps
      // breaksRemaining/streak/participants all consistent in one place.
      await friendsController.fetchCurrentNudgeStatus();
    } catch (e) {
      CustomSnackbar.show(
        title: "Something went wrong",
        message: "Please check your connection and try again.",
        isError: true,
      );
    }
  }

  // Shared by both break paths — computes actual duration from the real
  // start/end timestamps rather than the (previously observed buggy)
  // durationMinutes field, then starts the countdown.
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

  // NOTE: no "cancel/end break early" endpoint provided yet — this stays
  // local-only for now. Backend won't know the break ended early until it
  // naturally expires at its endTime. Ask backend dev for a break-cancel
  // endpoint to keep this in sync.
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

  // ==================== Lock / Unlock ====================
  final NfcService _nfcService = NfcService();
  final isScanningNfc = false.obs;
  final isTogglingLock = false.obs;

  void toggleLock() async {
    if (isTogglingLock.value) return;

    // Currently unlocked -> start a session with the selected mode.
    if (!isLocked.value) {
      if (selectedModeId == null || selectedModeId!.isEmpty) {
        CustomSnackbar.show(
          title: 'Select a mode',
          message: 'Pick a mode before locking.',
          isError: true,
        );
        return;
      }
      await _activateMode(selectedModeId!);
      return;
    }

    // Currently locked -> require NFC key match to unlock.
    if (isScanningNfc.value) return;
    isScanningNfc.value = true;
    _showAndroidNfcScanner();

    _nfcService.startScanning(
      onTagScanned: (tagId) async {
        isScanningNfc.value = false;
        _dismissAndroidNfcScanner();

        final pairedId = await StorageServices.instance.getPairedKeyId();

        // Normal, fully-offline path — matches locally, no backend call.
        if (tagId == pairedId) {
          await HapticFeedback.vibrate();
          if (activeModeId == null || activeModeId!.isEmpty) {
            CustomSnackbar.show(
              title: "Couldn't unlock",
              message: 'No active mode found on the server.',
              isError: true,
            );
            return;
          }
          await _deactivateMode(activeModeId!);
          return;
        }

        // Local pairing data missing (cleared storage / new device) —
        // fall back to backend verification instead of an immediate
        // Access Denied, so a legitimate key still works.
        if (pairedId == null || pairedId.isEmpty) {
          final verified = await _verifyKeyWithBackend(tagId);
          if (verified) {
            await HapticFeedback.vibrate();
            if (activeModeId == null || activeModeId!.isEmpty) {
              CustomSnackbar.show(
                title: "Couldn't unlock",
                message: 'No active mode found on the server.',
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
          message: 'This NFC card is not paired with this device.',
          isError: true,
        );
      },
      onError: (error) {
        isScanningNfc.value = false;
        _dismissAndroidNfcScanner();
        HapticFeedback.heavyImpact();
        CustomSnackbar.show(title: 'Scanning Failed', message: error, isError: true);
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

      // Restore local pairing so future taps go back to fully-offline.
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
          title: 'Could not lock',
          message: response?["message"] ?? 'Please try again.',
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
    } catch (e) {
      CustomSnackbar.show(
        title: 'Something went wrong',
        message: 'Please check your connection and try again.',
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
          title: 'Could not unlock',
          message: response?["message"] ?? 'Please try again.',
          isError: true,
        );
        return;
      }

      isLocked.value = false;
      activeModeId = null;
      _stopTimer();
      endBreak();
      CustomSnackbar.show(title: 'Unlocked', message: 'Welcome back.');
    } catch (e) {
      CustomSnackbar.show(
        title: 'Something went wrong',
        message: 'Please check your connection and try again.',
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
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D6A4F)),
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
              const SizedBox(height: 24),
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