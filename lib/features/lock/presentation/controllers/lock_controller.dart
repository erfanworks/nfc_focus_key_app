import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../../../../core/services/app_lock_native_service.dart';
import '../../../../core/services/nfc_service.dart';
import '../../../../core/services/storage_services.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/constants/app_api_url.dart';
import '../../../../core/utils/log_print.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../routes/app_routes.dart';
import '../../../pairing/presentation/controllers/modes_controller.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';

class LockController extends GetxController with WidgetsBindingObserver {
  final isLocked = false.obs;
  final selectedMode = 'Deep work.'.obs;
  final todayTime = '0m'.obs;
  final thisWeekTime = '0m'.obs;
  final sessionSeconds = 0.obs;
  final totalBlockedApps = 0.obs;

  final activeModeIdRx = RxnString();
  String? get activeModeId => activeModeIdRx.value;
  set activeModeId(String? value) => activeModeIdRx.value = value;
  List<String> _activePackageNames = [];
  String? _nativeLockAppliedForModeId;
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
    WidgetsBinding.instance.addObserver(this);

    // Phase 1: Immediate hydration from local cache to prevent UI lag/flicker
    _hydrateFromLocalCache();

    // Phase 2: Background sync with server
    fetchLockStatus();
    _fetchPersonalBreakLength();
    _checkPermissionsOnResume();
  }

  Future<void> _hydrateFromLocalCache() async {
    try {
      final localLockActive = await StorageServices.instance.isLockActive();
      final localModeId = await StorageServices.instance.getActiveModeId();
      final localModeName = await StorageServices.instance.getActiveModeName();

      if (localLockActive) {
        isLocked.value = true;
        if (localModeId != null) activeModeId = localModeId;
        if (localModeName != null) selectedMode.value = localModeName;

        // Restore timer if we have a start time cached
        final startTimeStr = await StorageServices.instance.getValue("session_start_time");
        if (startTimeStr != null && startTimeStr.isNotEmpty) {
          try {
            final start = DateTime.parse(startTimeStr);
            sessionSeconds.value = DateTime.now().difference(start).inSeconds;
            _startTimer();
          } catch (e) {
      errorLog("LockController._ensureNativeLockApplied", e);
    }
        }
      }
    } catch (e) {
      errorLog("LockController._hydrateFromLocalCache", e);
      // Hydration should never crash the app
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      fetchLockStatus();
      _checkPermissionsOnResume();
    }
  }

  Future<void> _checkPermissionsOnResume() async {
    if (!Platform.isAndroid) return;

    final nativeService = Get.find<AppLockNativeService>();
    final accessibility = await nativeService.isAccessibilityPermissionGranted();
    final overlay = await nativeService.isOverlayPermissionGranted();
    final battery = await nativeService.isBatteryOptimizationIgnored();
    final usage = await nativeService.isUsageAccessPermissionGranted();

    if (!accessibility || !overlay || !battery || !usage) {
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFFF7F4EE),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Permissions Required',
            style: TextStyle(color: Color(0xFF1A1814), fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Focus Key needs Accessibility, Overlay, Battery, and Usage Access permissions to guard your locked apps properly. Please enable them to continue.',
            style: TextStyle(color: const Color(0xFF1A1814).withOpacity(0.7)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
                Get.toNamed(Routes.enablePermissions);
              },
              child: const Text(
                'Go to Settings',
                style: TextStyle(color: Color(0xFFC4A97D), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
    }
  }

  Future<void> refreshPersonalBreakSettings() async {
    await _fetchPersonalBreakLength();
    await fetchLockStatus();
  }

  Future<void> _fetchPersonalBreakLength() async {
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return;

      isLoadingBreakSettings.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.breakConfig,
      );
      if (response == null || response["success"] != true) return;
      personalBreakLengthMinutes.value =
          response["data"]?["breakDurationMinutes"] ?? 5;
    } catch (e) {
      errorLog("LockController._fetchPersonalBreakLength", e);
    } finally {
      isLoadingBreakSettings.value = false;
    }
  }

  Future<void> fetchLockStatus() async {
    try {
      final token = await StorageServices.instance.getToken();
      if (token.isEmpty) return;

      isLoadingStatus.value = true;
      final response = await ApiServices.instance.getServices(
        AppApiUrl.instance.lockStatus,
      );

      if (response == null || response["success"] != true) {
        // Keep local state on sync failure
        return;
      }

      final data = response["data"];
      if (data == null) return;

      final lockStatus = data["lockStatus"] ?? {};
      final activeMode = data["activeMode"];
      final focusStats = data["focusStats"] ?? {};
      final breakStats = data["breakStats"] ?? {};

      final activeSessionData = data["activeSession"];
      final serverLocked = activeSessionData != null;
      isLocked.value = serverLocked;

      // Sync local cache with server truth
      await StorageServices.instance.setLockActive(serverLocked);

      if (lockStatus["activeModeName"] != null) {
        selectedMode.value = lockStatus["activeModeName"];
        await StorageServices.instance.setActiveModeName(selectedMode.value);
      }
      activeModeId = activeMode != null ? activeMode["_id"]?.toString() : null;
      await StorageServices.instance.setActiveModeId(activeModeId);

      todayTime.value = _formatMinutes(focusStats["todayMinutes"] ?? 0);
      thisWeekTime.value = _formatMinutes(focusStats["weekMinutes"] ?? 0);
      breaksLeft.value = breakStats["remainingToday"] ?? 0;
      totalBlockedApps.value = data["totalBlockedApps"] ?? 0;

      final activeBreak = breakStats["activeBreak"] ?? breakStats["activeNudgeBreak"];
      if (activeBreak != null) {
        try {
          final end = DateTime.parse(activeBreak["endTime"]);
          final remaining = end.difference(DateTime.now()).inSeconds;
          if (remaining > 0) {
            isOnBreak.value = true;
            breakSeconds.value = remaining;
            _startBreakTimer();
          } else {
            isOnBreak.value = false;
          }
        } catch (e) {
      errorLog("LockController._ensureNativeLockApplied", e);
    }
      } else {
        isOnBreak.value = false;
      }

      if (isLocked.value && activeModeId != null && !isOnBreak.value) {
        await _ensureNativeLockApplied(activeModeId!);
      }

      if (isLocked.value && !isOnBreak.value) {
        unawaited(_resumeOrStartTimer(data["activeSession"]));
      } else if (!isLocked.value) {
        unawaited(_stopTimer());
      }
    } catch (e) {
      errorLog("LockController.fetchLockStatus", e);
      // Keep local state on error
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

  Future<void> _resumeOrStartTimer(dynamic activeSession) async {
    if (activeSession is Map<String, dynamic>) {
      final raw =
          activeSession['startTime'] ??
          activeSession['startedAt'] ??
          activeSession['createdAt'];
      if (raw != null) {
        try {
          final start = DateTime.parse(raw.toString());
          await StorageServices.instance.setValue("session_start_time", raw.toString());
          final elapsed = DateTime.now().difference(start).inSeconds;
          if (elapsed >= 0) {
            sessionSeconds.value = elapsed;
            _startTimer();
            return;
          }
        } catch (e) {
      errorLog("LockController._ensureNativeLockApplied", e);
    }
      }
      final elapsedMinutes = activeSession['elapsedMinutes'];
      if (elapsedMinutes is int) {
        sessionSeconds.value = elapsedMinutes * 60;
        _startTimer();
        return;
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

  Future<void> _stopTimer() async {
    _timer?.cancel();
    _timer = null;
    sessionSeconds.value = 0;
    await StorageServices.instance.setValue("session_start_time", "");
  }

  String get formattedSessionTime {
    final hours = sessionSeconds.value ~/ 3600;
    final minutes = (sessionSeconds.value % 3600) ~/ 60;
    final seconds = sessionSeconds.value % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> startBreak() async {
    if (!isLocked.value) return;
    await HapticFeedback.lightImpact();

    final friendsController = Get.find<FriendsController>();
    final nudge = friendsController.currentNudge.value;
    final isNudgeSession =
        nudge != null && nudge.isActive && nudge.nudgeId != null;

    if (isNudgeSession) {
      await _startNudgeBreak(friendsController, nudge.nudgeId!);
    } else {
      await _startPersonalBreak();
    }
  }

  Future<void> _startPersonalBreak() async {
    if (activeModeId == null) return;
    try {
      isLoadingStatus.value = true;
      await HapticFeedback.mediumImpact();
      
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.breakStart,
        body: {"modeId": activeModeId},
      );
      // ... rest of logic

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Break Error",
          message: response?["message"] ?? "Could not start your break.",
          isError: true,
        );
        return;
      }

      final data = response["data"];
      await _applyBreakDuration(data["startTime"], data["endTime"]);
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

  Future<void> _startNudgeBreak(
    FriendsController friendsController,
    String nudgeId,
  ) async {
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
      await _applyBreakDuration(breakInfo["startTime"], breakInfo["endTime"]);
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

  Future<void> _applyBreakDuration(String? startTime, String? endTime) async {
    int seconds = 150;
    try {
      if (startTime != null && endTime != null) {
        final start = DateTime.parse(startTime);
        final end = DateTime.parse(endTime);
        seconds = end.difference(start).inSeconds;
      }
    } catch (e) {
      errorLog("LockController._ensureNativeLockApplied", e);
    }

    isOnBreak.value = true;
    isBreakPaused.value = false;
    breakSeconds.value = seconds;


    _startBreakTimer();

    await Get.find<AppLockNativeService>().deactivateLock();
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

  Future<void> endBreak() async {
    _breakTimer?.cancel();
    _breakTimer = null;
    isOnBreak.value = false;
    isBreakPaused.value = false;
    if (isLocked.value) {
      _startTimer();
      await Get.find<AppLockNativeService>().activateLock(
        modeId: activeModeId ?? '',
        androidPackageNames: _activePackageNames,
      );
    }
  }

  Future<void> stopBreak() async {
    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.breakCancel,
      );

      if (response == null || response["success"] != true) {
        CustomSnackbar.show(
          title: "Break Error",
          message: response?["message"] ?? "Could not stop your break.",
          isError: true,
        );
        return;
      }

      await endBreak();

      CustomSnackbar.show(
        title: "Break Stopped",
        message: "Apps are now locked again.",
      );

      // Sync remaining breaks and state from server
      fetchLockStatus();
    } catch (e) {
      CustomSnackbar.show(
        title: "Error",
        message: "A network error occurred. Please try again.",
        isError: true,
      );
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

          // CRITICAL: Always deactivate locally first if key matches,
          // regardless of internet status.
          await _deactivateMode(activeModeId ?? 'offline_fallback');
          return;
        }

        if (pairedId == null || pairedId.isEmpty) {
          final verified = await _verifyKeyWithBackend(tagId);
          if (verified) {
            await HapticFeedback.vibrate();
            await _deactivateMode(activeModeId ?? 'offline_fallback');
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
        CustomSnackbar.show(
          title: 'Scan Failed',
          message: error,
          isError: true,
        );
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
    } catch (e) {
      errorLog("LockController._verifyKeyWithBackend", e);
      return false;
    }
  }

  Future<void> _ensureNativeLockApplied(String modeId) async {
    if (_nativeLockAppliedForModeId == modeId) return;
    try {
      // Try fetching mode details
      final modeDetails = await ApiServices.instance.getServices(
        AppApiUrl.instance.updateMoodById(modeId),
      );

      List<String> packageNames = [];
      if (modeDetails != null && modeDetails["success"] == true) {
        final lockedAppsJson = (modeDetails["data"]?["lockedApps"] as List?) ?? [];
        packageNames = lockedAppsJson.map((e) => e["packageName"] as String).toList();
        _activePackageNames = packageNames;
      } else {
        // Offline: Try to use cached package names
        packageNames = await StorageServices.instance.getLockedApps();
      }

      await Get.find<AppLockNativeService>().activateLock(
        modeId: modeId,
        androidPackageNames: packageNames,
      );
      _nativeLockAppliedForModeId = modeId;
    } catch (e) {
      errorLog("LockController._ensureNativeLockApplied", e);
    }
  }

  Future<void> _activateMode(String modeId) async {
    // Optimistic UI — instant visual feedback, no waiting on network
    activeModeId = modeId;
    isLocked.value = true;
    sessionSeconds.value = 0;
    _startTimer();

    // Persist for offline resilience and lag-free loading
    await StorageServices.instance.setLockActive(true);
    await StorageServices.instance.setActiveModeId(modeId);
    await StorageServices.instance.setActiveModeName(selectedMode.value);
    await StorageServices.instance.setValue("session_start_time", DateTime.now().toIso8601String());

    try {
      isTogglingLock.value = true;
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.toggleModeActivation(modeId),
      );

      if (response == null || response["success"] != true) {
        // If not a network error (e.g. invalid mode), revert.
        if (response != null && response["message"] != "Check your internet connection.") {
          isLocked.value = false;
          activeModeId = null;
          unawaited(_stopTimer());
          await StorageServices.instance.setLockActive(false);
          CustomSnackbar.show(
            title: 'Session Failed',
            message: response["message"] ?? 'Could not start focus session.',
            isError: true,
          );
          return;
        }
      }

      unawaited(_ensureNativeLockApplied(modeId));

      CustomSnackbar.show(
        title: 'Locked',
        message: 'Your device is now locked. Scan your NFC key to unlock.',
      );
    } catch (e) {
      errorLog("LockController._activateMode", e);
      // On network exception, we keep the local lock active (Offline Mode)
    } finally {
      isTogglingLock.value = false;
    }
  }

  Future<void> _deactivateMode(String modeId) async {
    // Optimistic local unlock — prevents stuck state on poor connection
    isLocked.value = false;
    activeModeId = null;
    unawaited(_stopTimer());
    endBreak();

    // Update local storage first
    await StorageServices.instance.setLockActive(false);
    await StorageServices.instance.setActiveModeId(null);
    await StorageServices.instance.setActiveModeName(null);

    // Deactivate native shield immediately
    await Get.find<AppLockNativeService>().deactivateLock();
    _nativeLockAppliedForModeId = null;

    try {
      isTogglingLock.value = true;
      
      // Check if we are in a Nudge session
      final friendsController = Get.find<FriendsController>();
      final nudge = friendsController.currentNudge.value;
      final isNudgeActive = nudge != null && nudge.isActive && nudge.nudgeId != null;

      if (isNudgeActive) {
        // If it's a nudge session, we need to leave/unlock the nudge
        await friendsController.leaveNudge(nudge.nudgeId!);
      } else {
        // Regular session sync
        final response = await ApiServices.instance.patchServices(
          url: AppApiUrl.instance.toggleModeActivation(modeId),
        );
        
        // Extra fallback: if server still says it's a nudge session via message
        if (response != null && 
            response["success"] == false && 
            (response["message"]?.toString().contains("Nudge") ?? false)) {
          if (nudge?.nudgeId != null) {
            await friendsController.leaveNudge(nudge!.nudgeId!);
          }
        }
      }

      CustomSnackbar.show(
        title: 'Session Ended',
        message: 'Welcome back! You made great progress.',
      );

      await Future.delayed(const Duration(milliseconds: 1000));
    } catch (e) {
      errorLog("LockController._deactivateMode", e);
      
      // If we got a 403 via exception, try to handle nudge exit as a last resort
      if (e.toString().contains("403")) {
        try {
          final friendsController = Get.find<FriendsController>();
          final nudgeId = friendsController.currentNudge.value?.nudgeId;
          if (nudgeId != null) {
            await friendsController.leaveNudge(nudgeId);
          }
        } catch (_) {}
      }

      // Even if server sync fails, the user is already unlocked locally.
      CustomSnackbar.show(
        title: 'Unlocked',
        message: 'Session ended locally. Will sync with server when online.',
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
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    _breakTimer?.cancel();
    _nfcService.stopScanning();
    super.onClose();
  }
}
