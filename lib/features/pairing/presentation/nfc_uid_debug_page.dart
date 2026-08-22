// TEMPORARY DEBUG TOOL — NOT part of the production pairing flow.
// Purpose: read a real NFC tag's UID so it can be shared with the backend
// developer for API testing against the whitelist database.
// Delete this file (and its route, if you add one) once no longer needed.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart' as platform_tags;

class NfcUidDebugPage extends StatefulWidget {
  const NfcUidDebugPage({super.key});

  @override
  State<NfcUidDebugPage> createState() => _NfcUidDebugPageState();
}

class _NfcUidDebugPageState extends State<NfcUidDebugPage> {
  String _status = 'Tap "Start Scan" then hold your key to the phone.';
  String? _uidHex;

  Future<void> _startScan() async {
    final isAvailable = await NfcManager.instance.isAvailable();
    if (!isAvailable) {
      setState(() {
        _status = 'NFC is not available on this device.';
      });
      return;
    }

    setState(() {
      _status = 'Scanning... hold the key near the phone.';
      _uidHex = null;
    });

    await NfcManager.instance.startSession(
      pollingOptions: {
        NfcPollingOption.iso14443, // NTAG215 is ISO14443A
      },
      onDiscovered: (NfcTag tag) async {
        try {
          // Extract raw UID bytes from the platform-specific tag data.
          final identifier = _extractUid(tag);

          if (identifier == null) {
            setState(() {
              _status = 'Could not read UID from this tag.';
            });
            await NfcManager.instance.stopSession(errorMessage: 'Could not read UID.');
            return;
          }

          final uidHex = identifier
              .map((b) => b.toRadixString(16).padLeft(2, '0'))
              .join()
              .toUpperCase();

          setState(() {
            _uidHex = uidHex;
            _status = 'UID read successfully.';
          });

          await HapticFeedback.vibrate();
          await NfcManager.instance.stopSession();
        } catch (e) {
          setState(() {
            _status = 'Error reading tag: $e';
          });
          await NfcManager.instance.stopSession(errorMessage: 'Error reading tag.');
        }
      },
    );
  }

  /// Pulls the raw UID byte array out of the tag depending on platform.
  List<int>? _extractUid(NfcTag tag) {
    final nfca = platform_tags.NfcA.from(tag);
    if (nfca != null) return nfca.identifier;

    final isoDep = platform_tags.IsoDep.from(tag);
    if (isoDep != null) return isoDep.identifier;

    final miFare = platform_tags.MiFare.from(tag);
    if (miFare != null) return miFare.identifier;

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('NFC UID Debug Tool')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_status, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            if (_uidHex != null) ...[
              const Text('UID (hex):', style: TextStyle(fontWeight: FontWeight.bold)),
              SelectableText(
                _uidHex!,
                style: const TextStyle(fontSize: 20, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: _startScan,
              child: const Text('Start Scan'),
            ),
          ],
        ),
      ),
    );
  }
}
