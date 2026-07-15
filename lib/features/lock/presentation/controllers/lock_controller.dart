import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/services/nfc_service.dart';
import '../../../../core/services/storage_service.dart';

class LockController extends GetxController {
  final isLocked = false.obs;
  final selectedMode = 'Deep work.'.obs;
  final todayTime = '4m'.obs;
  final thisWeekTime = '2h 14m'.obs;
  final sessionSeconds = 0.obs;

  // Break State Variables
  final isOnBreak = false.obs;
  final breakSeconds = 150.obs;
  final isBreakPaused = false.obs;
  final breaksLeft = 1.obs;
  final isHoldingCancel = false.obs;

  Timer? _timer;
  Timer? _breakTimer;

  @override
  void onInit() {
    super.onInit();
    ever(isLocked, (locked) {
      if (locked) {
        sessionSeconds.value = 252;
        _startTimer();
      } else {
        _stopTimer();
        endBreak();
      }
    });
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
  }

  String get formattedSessionTime {
    final hours = sessionSeconds.value ~/ 3600;
    final minutes = (sessionSeconds.value % 3600) ~/ 60;
    final seconds = sessionSeconds.value % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Break Actions
  void startBreak() {
    if (!isLocked.value) return;
    isOnBreak.value = true;
    isBreakPaused.value = false;
    breakSeconds.value = 150;
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

  void toggleLock() async {
    // If unlocked, lock immediately
    if (!isLocked.value) {
      isLocked.value = true;
      return;
    }

    // If locked, scan NFC key to unlock
    if (isScanningNfc.value) return;
    isScanningNfc.value = true;

    _showAndroidNfcScanner();

    _nfcService.startScanning(
      onTagScanned: (tagId) async {
        isScanningNfc.value = false;
        _dismissAndroidNfcScanner();

        // Get the stored paired key ID
        final pairedId = StorageService.getPairedKeyId();

        if (pairedId == null) {
          Get.snackbar(
            'Unlock Failed',
            'No key is paired. Please pair a key in Settings.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (tagId == pairedId) {
          // Success vibration
          await HapticFeedback.vibrate();
          // Temporarily disabled unlocking on success
          // isLocked.value = false;
          Get.snackbar(
            'Unlocked (Simulated)',
            'NFC Key matched! (Unlock action is temporarily disabled).',
            snackPosition: SnackPosition.BOTTOM,
          );
        } else {
          // Error vibration
          HapticFeedback.heavyImpact();
          Get.snackbar(
            'Access Denied',
            'This NFC card is not paired with this device.',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
      onError: (error) {
        isScanningNfc.value = false;
        _dismissAndroidNfcScanner();
        HapticFeedback.heavyImpact();
        Get.snackbar(
          'Scanning Failed',
          error,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );
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
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8A8278),
                ),
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

  void selectMode(String mode) {
    selectedMode.value = mode;
  }

  @override
  void onClose() {
    _stopTimer();
    _breakTimer?.cancel();
    _nfcService.stopScanning();
    super.onClose();
  }
}
