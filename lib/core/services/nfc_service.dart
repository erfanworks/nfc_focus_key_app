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

    NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        try {
          String? tagId;

          // Print raw tag data to debug console
          print("====================================");
          print("NFC TAG DISCOVERED!");
          print("Raw Data: ${tag.data}");

          // Parse tag identifier based on tag type
          final identifier = tag.data['ndef']?['identifier'] ?? 
                             tag.data['nfca']?['identifier'] ?? 
                             tag.data['mifare']?['identifier'] ??
                             tag.data['nfcb']?['identifier'] ??
                             tag.data['nfcf']?['identifier'] ??
                             tag.data['nfcv']?['identifier'];

          if (identifier != null) {
            tagId = (identifier as List<int>)
                .map((e) => e.toRadixString(16).padLeft(2, '0'))
                .join(':')
                .toUpperCase();
            print("Parsed Tag ID (HEX): $tagId");
          }
          print("====================================");

          if (tagId != null) {
            onTagScanned(tagId);
          } else {
            onError("NFC tag detected, but could not retrieve unique ID.");
          }

          // Stop scanning session after successful read
          await stopScanning();
        } catch (e) {
          onError("Error reading NFC tag: $e");
          await stopScanning(errorMessage: e.toString());
        }
      },
      onError: (error) async {
        onError("NFC session failed: ${error.message}");
      },
    );
  }

  // Stop NFC scanning
  Future<void> stopScanning({String? errorMessage}) async {
    await NfcManager.instance.stopSession(errorMessage: errorMessage);
  }
}
