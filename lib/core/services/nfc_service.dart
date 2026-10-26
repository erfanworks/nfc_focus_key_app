import 'dart:io';
import 'package:nfc_manager/nfc_manager.dart';

class NfcService {
  // Check if NFC is available on the device
  Future<bool> isNfcAvailable() async {
    return await NfcManager.instance.isAvailable();
  }

  // Start NFC scanning
  void startScanning({
    required Function(String tagId) onTagScanned,
    required Function(String error) onError,
  }) async {
    bool available = await isNfcAvailable();
    if (!available) {
      onError("NFC is not supported or enabled on this device.");
      return;
    }

    // Stop any active session before starting a new one
    try {
      await stopScanning();
    } catch (_) {}

    // iOS requires a slight delay if a session was just closed
    await Future.delayed(const Duration(milliseconds: 200));

    NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443,
        NfcPollingOption.iso15693,
      },
      onDiscovered: (NfcTag tag) async {
        try {
          print("NFC Tag Discovered: ${tag.data}");
          String? tagId;

          final identifier = tag.data['ndef']?['identifier'] ??
              tag.data['nfca']?['identifier'] ??
              tag.data['mifare']?['identifier'] ??
              tag.data['nfcb']?['identifier'] ??
              tag.data['nfcf']?['identifier'] ??
              tag.data['nfcv']?['identifier'];

          if (identifier != null) {
            // Plain hex, no separator — matches backend UID format
            tagId = (identifier as List<int>)
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join()
                .toUpperCase();
          }

          if (tagId != null) {
            onTagScanned(tagId);
          } else {
            onError("NFC tag detected, but could not retrieve unique ID.");
          }

          // On Android, delay stopping session briefly so the user can pull the NFC key away
          // before ReaderMode turns off, preventing System TagDispatcher popup ("New tag collected")
          if (Platform.isAndroid) {
            await Future.delayed(const Duration(milliseconds: 1500));
          }
          await stopScanning();
        } catch (e) {
          print("Error reading NFC tag: $e");
          await stopScanning(errorMessage: e.toString());
          onError("Error reading NFC tag: $e");
        }
      },
      onError: (error) async {
        print("NFC session failed: ${error.message} (${error.details})");
        onError("NFC session failed: ${error.message}");
      },
    );
  }

  // Stop NFC scanning
  Future<void> stopScanning({String? errorMessage}) async {
    try {
      await NfcManager.instance.stopSession(errorMessage: errorMessage);
    } catch (e) {
      print("Error stopping NFC session: $e");
    }
  }
}
