import 'dart:async';
import 'dart:io';
import 'dart:math';
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
  final breaksLeft = 1.obs;
  final personalBreakLengthMinutes = 5.obs;
  final isLoadingBreakSettings = true.obs;
  final isHoldingCancel = false.obs;

  final isLoadingStatus = false.obs;
  final isSyncing = false.obs;

  Timer? _timer;
  Timer? _breakTimer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Phase 1: Immediate hydration from local cache to prevent UI lag/flicker
    _hydrateFromLocalCache();

    // Phase 2: Background sync with server
    unawaited(_syncPendingStateOnResume());
    _fetchPersonalBreakLength();
    _checkPermissionsOnResume();
  }

  Future<void> _hydrateFromLocalCache() async {
    try {
      final localLockActive = await StorageServices.instance.isLockActive();
      final localModeId = await StorageServices.instance.getActiveModeId();
      final localModeName = await StorageServices.instance.getActiveModeName();

      // Load last selected mode regardless of lock status
      final lastSelected = await StorageServices.instance.getLastSelectedMode();
      if (lastSelected["id"] != null) {
        selectedModeIdRx.value = lastSelected["id"];
      }
      if (lastSelected["name"] != null) {
        selectedMode.value = lastSelected["name"]!;
      }

      if (!localLockActive) return;

      isLocked.value = true;
      if (localModeId != null) activeModeId = localModeId;
      if (localModeName != null) selectedMode.value = localModeName;

      // Restore the session elapsed count from its real start timestamp
      // (value only — the ticking Timer is started further below, once
      // we know whether a break is/was active, so it doesn't tick during
      // a break that turns out to still be running).
      final startTimeStr = await StorageServices.instance.getValue("session_start_time");
      if (startTimeStr != null && startTimeStr.isNotEmpty) {
        try {
          final start = DateTime.parse(startTimeStr);
          sessionSeconds.value = DateTime.now().toUtc().difference(start.toUtc()).inSeconds;
        } catch (e) {
          errorLog("LockController._hydrateFromLocalCache", e);
        }
      }

      // Restore break state from its real end timestamp. This covers the
      // app being fully killed and relaunched while on an offline break —
      // Timer.periodic obviously doesn't survive a process kill, so
      // without this the break/lock state would be lost entirely on
      // relaunch instead of reflecting real elapsed wall-clock time.
      final breakEndStr = await StorageServices.instance.getValue("break_end_time");
      if (breakEndStr != null && breakEndStr.isNotEmpty) {
        try {
          final end = DateTime.parse(breakEndStr);
          final remaining = end.difference(DateTime.now().toUtc()).inSeconds;
          if (remaining > 0) {
            isOnBreak.value = true;
            breakSeconds.value = remaining;
            _startBreakTimer();
          } else {
            // The break fully elapsed while the app was killed — finalize
            // it now (re-locks apps, marks any pending offline record
            // completed) rather than leaving it in a stale "active" state.
            await endBreak();
          }
        } catch (e) {
          errorLog("LockController._hydrateFromLocalCache", e);
        }
      }

      // Safe to call even if endBreak() above already started it —
      // _startTimer() just (re)starts the ticker from the current
      // sessionSeconds value, it never resets it.
      if (isLocked.value && !isOnBreak.value) {
        _startTimer();
      }
    } catch (e) {
      errorLog("LockController._hydrateFromLocalCache", e);
      // Hydration should never crash the app
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_resumeFlow());
      _checkPermissionsOnResume();
    }
  }

  Future<void> _resumeFlow() async {
    // Local, network-independent correction runs FIRST so the UI shows
    // the true elapsed/remaining time immediately on foreground, even
    // while fully offline (Timer.periodic does not tick while the app is
    // backgrounded/suspended, so without this the timers would otherwise
    // resume from whatever stale value they had before backgrounding).
    await _resyncFromLocalTimestamps();
    await _syncPendingStateOnResume();
  }

  /// Recomputes sessionSeconds/breakSeconds from real, persisted
  /// timestamps rather than trusting Timer.periodic's in-memory count,
  /// which pauses while the app is backgrounded/suspended on both iOS
  /// and Android. Safe to call with no network — purely local.
  Future<void> _resyncFromLocalTimestamps() async {
    try {
      if (isOnBreak.value) {
        final endStr = await StorageServices.instance.getValue("break_end_time");
        if (endStr != null && endStr.isNotEmpty) {
          final end = DateTime.parse(endStr);
          final remaining = end.difference(DateTime.now().toUtc()).inSeconds;
          if (remaining > 0) {
            breakSeconds.value = remaining;
            _startBreakTimer();
          } else {
            // The break's real end time already passed while the app was
            // backgrounded — end it now rather than showing a stale
            // "still on break" state until the next network sync.
            await endBreak();
          }
        }
        return;
      }

      if (isLocked.value) {
        final startStr = await StorageServices.instance.getValue("session_start_time");
        if (startStr != null && startStr.isNotEmpty) {
          final start = DateTime.parse(startStr);
          final elapsed = DateTime.now().toUtc().difference(start.toUtc()).inSeconds;
          if (elapsed >= 0) {
            sessionSeconds.value = elapsed;
            _startTimer();
          }
        }
      }
    } catch (e) {
      errorLog("LockController._resyncFromLocalTimestamps", e);
      // Non-fatal — the subsequent network sync (when online) will
      // still correct state via fetchLockStatus().
    }
  }

  /// Runs the offline-reconcile + status-refresh sequence strictly in
  /// order (not in parallel). Parallel calls let a lock-status GET race
  /// ahead of a pending session/break reconcile, observe activeSession as
  /// null (not yet created server-side), and wrongly reset local state
  /// (e.g. wiping the session timer) before the reconcile catches up.
  Future<void> _syncPendingStateOnResume() async {
    // Must run strictly in sequence — parallel calls let a lock-status
    // GET race ahead of the session reconcile, see activeSession: null
    // (session not yet created server-side), and wrongly wipe the timer.
    await _attemptPendingReconcile();
    await _attemptPendingBreakReconcile();
    await fetchLockStatus();
  }

  /// Pushes a lock session that was started/ended while offline to the
  /// backend via POST /focus-sessions/reconcile. Safe to call anytime —
  /// no-ops if there's nothing pending, and idempotent per clientSessionId
  /// on the backend side, so calling this more than once (app resume +
  /// onInit both firing) can never create duplicate sessions.
  Future<void> _attemptPendingReconcile() async {
    try {
      final pending = await StorageServices.instance
          .getPendingReconcileSession();
      if (pending == null) return;

      final body = {
        "clientSessionId": pending["clientSessionId"],
        "modeId": pending["modeId"],
        "startedAt": pending["startedAt"],
        "status": pending["status"],
        if (pending["endedAt"] != null) "endedAt": pending["endedAt"],
      };

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.reconcile,
        body: body,
      );

      final bool isNetworkError =
          response is Map && response["isNetworkError"] == true;
      if (isNetworkError) {
        // Still offline — leave the pending record as-is, try again on
        // the next resume/init.
        return;
      }

      if (response == null || response["success"] != true) {
        // Server actively rejected this reconcile attempt (e.g. the
        // session/mode no longer exists). Nothing local to safely retry
        // with — drop it rather than retry forever.
        errorLog(
          "LockController._attemptPendingReconcile",
          "Reconcile rejected: ${response?["message"]}",
        );
        await StorageServices.instance.clearPendingReconcileSession();
        return;
      }

      // Reconciled successfully — pull the server's authoritative state
      // (breaksLeft, isLocked, active mode) through the existing,
      // already-tested fetchLockStatus() path rather than duplicating
      // its parsing logic here.
      await fetchLockStatus();
      await StorageServices.instance.clearPendingReconcileSession();
    } catch (e) {
      errorLog("LockController._attemptPendingReconcile", e);
      // Leave the pending record in place — will retry on next
      // resume/init rather than losing the offline session's data.
    }
  }

  /// Break equivalent of _attemptPendingReconcile() — pushes a personal
  /// break that was started/cancelled while offline to the backend via
  /// POST /breaks/reconcile. Same idempotent, safe-to-call-anytime
  /// contract as the lock reconcile above.
  Future<void> _attemptPendingBreakReconcile() async {
    try {
      final pending = await StorageServices.instance.getPendingReconcileBreak();
      if (pending == null) return;

      final body = {
        "clientBreakId": pending["clientBreakId"],
        "modeId": pending["modeId"],
        "startedAt": pending["startedAt"],
        "status": pending["status"],
        if (pending["endedAt"] != null) "endedAt": pending["endedAt"],
      };

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.breakReconcile,
        body: body,
      );

      final bool isNetworkError =
          response is Map && response["isNetworkError"] == true;
      if (isNetworkError) {
        // Still offline — retry on the next resume/init.
        return;
      }

      if (response == null || response["success"] != true) {
        // Server actively rejected this reconcile attempt — nothing
        // local to safely retry with, drop it rather than retry forever.
        errorLog(
          "LockController._attemptPendingBreakReconcile",
          "Reconcile rejected: ${response?["message"]}",
        );
        await StorageServices.instance.clearPendingReconcileBreak();
        return;
      }

      // Reconciled (or already-synced, per the backend's own dedup) —
      // pull the authoritative breaksLeft/state through the existing
      // fetchLockStatus() path rather than parsing it out here.
      await fetchLockStatus();
      await StorageServices.instance.clearPendingReconcileBreak();
    } catch (e) {
      errorLog("LockController._attemptPendingBreakReconcile", e);
      // Leave the pending record in place — retried on next resume/init.
    }
  }

  Future<void> _checkPermissionsOnResume() async {
    if (!Platform.isAndroid) return;

    final nativeService = Get.find<AppLockNativeService>();
    final accessibility = await nativeService
        .isAccessibilityPermissionGranted();
    final overlay = await nativeService.isOverlayPermissionGranted();
    final battery = await nativeService.isBatteryOptimizationIgnored();
    final usage = await nativeService.isUsageAccessPermissionGranted();

    if (!accessibility || !overlay || !battery || !usage) {
      Get.dialog(
        AlertDialog(
          backgroundColor: const Color(0xFFF7F4EE),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Permissions Required',
            style: TextStyle(
              color: Color(0xFF1A1814),
              fontWeight: FontWeight.bold,
            ),
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
                style: TextStyle(
                  color: Color(0xFFC4A97D),
                  fontWeight: FontWeight.bold,
                ),
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
      // isLocked here means "focus session is active" (persists through a
      // break), not "apps are physically locked at this instant" — the
      // backend's own isLocked field means the latter (it's false while on
      // a break) and must NOT be used to drive this. Deriving from
      // activeSession presence (the FocusSession stays "active" in the DB
      // for the whole session, break included) is correct.
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

      final activeBreak =
          breakStats["activeBreak"] ?? breakStats["activeNudgeBreak"];
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
      } else {}
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
          await StorageServices.instance.setValue(
            "session_start_time",
            raw.toString(),
          );
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
    if (breaksLeft.value <= 0) {
      CustomSnackbar.show(
        title: "Break Error",
        message: "You have no breaks left today.",
        isError: true,
      );
      return;
    }

    final modeId = activeModeId!;
    final clientBreakId = _generateUuidV4();
    final startedAt = DateTime.now().toUtc().toIso8601String();

    try {
      isLoadingStatus.value = true;
      await HapticFeedback.mediumImpact();

      // Recorded before the network call so an offline start (or a kill
      // mid-flight) still has enough info for the next reconcile pass.
      await StorageServices.instance.savePendingReconcileBreak(
        clientBreakId: clientBreakId,
        modeId: modeId,
        startedAt: startedAt,
        status: "active",
      );

      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.breakStart,
        body: {
          "modeId": modeId,
          "clientBreakId": clientBreakId,
          "startedAt": startedAt,
        },
      );

      final bool isNetworkError =
          response is Map && response["isNetworkError"] == true;

      if (response == null || response["success"] != true) {
        if (isNetworkError) {
          // Offline — start the break locally using the cached break
          // length, since the server can't tell us startTime/endTime
          // right now. _attemptPendingBreakReconcile() will true-up
          // breaksLeft with the server once connectivity returns.
          final durationSeconds = personalBreakLengthMinutes.value * 60;
          final start = DateTime.parse(startedAt);
          final end = start.add(Duration(seconds: durationSeconds));
          await _applyBreakDuration(
            start.toIso8601String(),
            end.toIso8601String(),
          );
          breaksLeft.value -= 1;

          CustomSnackbar.show(
            title: "Break Started",
            message: "Your apps are now available.",
          );
          return;
        }

        // Real rejection from the server (e.g. quota already exhausted
        // server-side) — nothing local was changed, just surface it.
        await StorageServices.instance.clearPendingReconcileBreak();
        CustomSnackbar.show(
          title: "Break Error",
          message: response?["message"] ?? "Could not start your break.",
          isError: true,
        );
        return;
      }

      final data = response["data"];
      await _applyBreakDuration(data["startTime"], data["endTime"]);
      breaksLeft.value -= 1;

      CustomSnackbar.show(
        title: "Break Started",
        message: "Your apps are now available.",
      );
    } catch (e) {
      errorLog("LockController._startPersonalBreak", e);
      CustomSnackbar.show(
        title: "Error",
        message: "A network error occurred. Please try again.",
        isError: true,
      );
    } finally {
      isLoadingStatus.value = false;
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
    DateTime? resolvedEnd;
    try {
      if (startTime != null && endTime != null) {
        final start = DateTime.parse(startTime);
        final end = DateTime.parse(endTime);
        seconds = end.difference(start).inSeconds;
        resolvedEnd = end;
      }
    } catch (e) {
      errorLog("LockController._ensureNativeLockApplied", e);
    }
    // Fallback anchor if we couldn't parse a real end time from the
    // server/local data — still gives _resyncFromLocalTimestamps() a
    // real wall-clock moment to recompute against later.
    resolvedEnd ??= DateTime.now().toUtc().add(Duration(seconds: seconds));

    isOnBreak.value = true;
    breakSeconds.value = seconds;

    // Persisted so a later app resume (especially while still offline,
    // where no server round-trip is available to self-correct) can
    // recompute the true remaining time from this real timestamp instead
    // of relying on Timer.periodic, which does not tick while the app is
    // backgrounded/suspended — see _resyncFromLocalTimestamps().
    await StorageServices.instance.setValue(
      "break_end_time",
      resolvedEnd.toIso8601String(),
    );

    _startBreakTimer();

    await Get.find<AppLockNativeService>().deactivateLock();
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
    await StorageServices.instance.setValue("break_end_time", "");

    // Finalize any pending offline break record here (not in stopBreak())
    // so BOTH the natural end-of-break path (countdown reaching 0 inside
    // _startBreakTimer()) and the manual cancel path (stopBreak() calls
    // this) correctly mark it "completed". Previously only the manual
    // cancel path did this — a break that ended naturally while offline
    // stayed marked "active" forever, so the next reconcile re-activated
    // it on the server, restarting the break after reconnecting.
    final pendingBreak = await StorageServices.instance.getPendingReconcileBreak();
    if (pendingBreak != null && pendingBreak["status"] == "active") {
      await StorageServices.instance.savePendingReconcileBreak(
        clientBreakId: pendingBreak["clientBreakId"],
        modeId: pendingBreak["modeId"],
        startedAt: pendingBreak["startedAt"],
        status: "completed",
        endedAt: DateTime.now().toUtc().toIso8601String(),
      );
    }

    if (isLocked.value) {
      _startTimer();
      await Get.find<AppLockNativeService>().activateLock(
        modeId: activeModeId ?? '',
        androidPackageNames: _activePackageNames,
      );
    }
  }

  Future<void> stopBreak() async {
    // Optimistic cancel — apps must go back to locked immediately, without
    // waiting on the network. This mirrors _deactivateMode()'s pattern and
    // fixes the "stuck on break" bug: previously endBreak() only ran after
    // the breakCancel API call resolved, so any network hiccup left the
    // user's apps unlocked with no way to cancel.
    //
    // endBreak() itself now finalizes the pending offline break record
    // (marks it "completed"), so there's no separate step needed here —
    // this keeps the natural-end and manual-cancel paths on one shared,
    // single source of truth instead of duplicating the same logic twice.
    await endBreak();

    CustomSnackbar.show(
      title: "Break Stopped",
      message: "Apps are now locked again.",
    );

    try {
      final response = await ApiServices.instance.postServices(
        url: AppApiUrl.instance.breakCancel,
      );

      if (response != null && response["success"] == true) {
        await StorageServices.instance.clearPendingReconcileBreak();
      } else {
        errorLog(
          "LockController.stopBreak",
          "breakCancel API did not confirm success: ${response?["message"]}",
        );
        // Apps are already re-locked locally (fail-safe default). The
        // "completed" pending record saved above will sync via
        // _attemptPendingBreakReconcile() once connectivity allows.
      }
    } catch (e) {
      errorLog("LockController.stopBreak", e);
      // Same fail-safe reasoning: local state already correct, server
      // sync will catch up on the next reconcile pass.
    }

    // Sync remaining breaks and state from server (best-effort, non-blocking
    // for the user's already-completed local cancel).
    unawaited(fetchLockStatus());
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
        final lockedAppsJson =
            (modeDetails["data"]?["lockedApps"] as List?) ?? [];
        packageNames = lockedAppsJson
            .map((e) => e["packageName"] as String)
            .toList();
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

    final startedAt = DateTime.now().toUtc().toIso8601String();
    final clientSessionId = _generateUuidV4();

    // Persist for offline resilience and lag-free loading
    await StorageServices.instance.setLockActive(true);
    await StorageServices.instance.setActiveModeId(modeId);
    await StorageServices.instance.setActiveModeName(selectedMode.value);
    await StorageServices.instance.setValue("session_start_time", startedAt);

    // Recorded up front so that even if the app is killed before the
    // network call below resolves, the next launch's reconcile pass can
    // still push this session to the backend.
    await StorageServices.instance.savePendingReconcileSession(
      clientSessionId: clientSessionId,
      modeId: modeId,
      startedAt: startedAt,
      status: "active",
    );

    try {
      isTogglingLock.value = true;
      final response = await ApiServices.instance.patchServices(
        url: AppApiUrl.instance.toggleModeActivation(modeId),
      );

      final bool isNetworkError =
          response is Map && response["isNetworkError"] == true;

      if (response == null || response["success"] != true) {
        if (!isNetworkError) {
          // The server actually responded and rejected this — revert.
          isLocked.value = false;
          activeModeId = null;
          unawaited(_stopTimer());
          await StorageServices.instance.setLockActive(false);
          await StorageServices.instance.clearPendingReconcileSession();
          CustomSnackbar.show(
            title: 'Session Failed',
            message: response?["message"] ?? 'Could not start focus session.',
            isError: true,
          );
          return;
        }
        // Network error — keep the optimistic local lock. The pending
        // reconcile record saved above will sync this once connectivity
        // returns (see _attemptPendingReconcile()).
      }
      // Note: pendingReconcileSession is intentionally NOT cleared here
      // even on a successful online activation. It must stay alive for
      // the lifetime of the session so that if the user later unlocks
      // while offline, _deactivateMode() has a record to mark
      // "completed" and reconcile once connectivity returns. It's only
      // cleared once the session is confirmed ended (see
      // _deactivateMode()'s success branch).

      unawaited(_ensureNativeLockApplied(modeId));

      CustomSnackbar.show(
        title: 'Locked',
        message: 'Your device is now locked. Scan your NFC key to unlock.',
      );
    } catch (e) {
      errorLog("LockController._activateMode", e);
      // On network exception, we keep the local lock active (Offline Mode).
      // pendingReconcileSession is already saved above.
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
      final isNudgeActive =
          nudge != null && nudge.isActive && nudge.nudgeId != null;

      if (isNudgeActive) {
        // If it's a nudge session, we need to leave/unlock the nudge
        await friendsController.leaveNudge(nudge.nudgeId!);
        await StorageServices.instance.clearPendingReconcileSession();
      } else {
        // Regular session sync
        final response = await ApiServices.instance.patchServices(
          url: AppApiUrl.instance.toggleModeActivation(modeId),
        );

        final bool isNetworkError =
            response is Map && response["isNetworkError"] == true;

        if (response != null && response["success"] == true) {
          await StorageServices.instance.clearPendingReconcileSession();
        } else if (isNetworkError) {
          // Couldn't reach the server — record this unlock so the next
          // reconcile pass tells the backend the session is over.
          final pending = await StorageServices.instance
              .getPendingReconcileSession();
          if (pending != null && pending["modeId"] == modeId) {
            await StorageServices.instance.savePendingReconcileSession(
              clientSessionId: pending["clientSessionId"],
              modeId: modeId,
              startedAt: pending["startedAt"],
              status: "completed",
              endedAt: DateTime.now().toUtc().toIso8601String(),
            );
          }
        }

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
    if (mode.id != null) {
      StorageServices.instance.setLastSelectedMode(mode.id!, mode.title);
    }
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

/// Minimal RFC-4122 v4 UUID generator — avoids pulling in the `uuid`
/// package just for client-generated session IDs used by the offline
/// lock reconciliation flow.
String _generateUuidV4() {
  final rand = Random.secure();
  final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
  bytes[6] = (bytes[6] & 0x0F) | 0x40; // version 4
  bytes[8] = (bytes[8] & 0x3F) | 0x80; // variant 10
  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((b) => b.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}