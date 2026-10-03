import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../features/notifications/presentation/controller/notification_controller.dart';
import '../constants/app_api_url.dart';
import '../utils/log_print.dart';
import 'api_service.dart';

/// Must be a top-level (or static) function, registered before runApp(),
/// so the OS can invoke it in a background isolate when the app is
/// terminated or backgrounded. This isolate has no access to any state
/// created inside PushNotificationService — do not reference `this`
/// or any instance members here.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase.initializeApp() is intentionally NOT called here.
  // Background isolates on Android auto-initialize Firebase from the
  // native google-services.json; calling initializeApp() again here
  // only matters if this handler touches other Firebase services
  // (Firestore, etc). We only read the message payload, so nothing
  // further is required.
  appLog("FCM background message ► ${message.messageId}: ${message.data}");
}

class PushNotificationService extends GetxService {
  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _api = ApiServices.instance;

  static const _androidChannel = AndroidNotificationChannel(
    'focus_key_default_channel',
    'Focus Key Notifications',
    description: 'General app notifications',
    importance: Importance.high,
  );

  String? _cachedToken;

  Future<PushNotificationService> init() async {
    try {
      await _requestPermission();
      await _initLocalNotifications();
      await _bindTokenLifecycle();
      _bindForegroundMessages();
      _bindNotificationTapHandling();
      await _handleInitialMessageIfAny();
    } catch (e) {
      errorLog("PushNotificationService.init", e);
    }
    return this;
  }

  // ==================== Permission ====================
  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      appLog(
        "FCM permission status ► ${settings.authorizationStatus}",
      );

      if (Platform.isIOS) {
        // Keep true: this is what makes iOS auto-display the push banner
        // while in foreground. (The duplicate-banner fix lives in
        // _bindForegroundMessages below, not here — this option governs
        // ALL foreground notifications, local ones included, so setting it
        // false had silently suppressed our own local banner too.)
        await _messaging.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      errorLog("PushNotificationService._requestPermission", e);
    }
  }

  // ==================== Local notifications (foreground banner) ====================
  Future<void> _initLocalNotifications() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true, // Requesting here specifically for iOS
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _localNotifications.initialize(
        settings: const InitializationSettings(android: androidInit, iOS: iosInit),
        onDidReceiveNotificationResponse: (response) {
          appLog("Local notification tapped ► payload=${response.payload}");
        },
      );

      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_androidChannel);
      }
    } catch (e) {
      errorLog("PushNotificationService._initLocalNotifications", e);
    }
  }

  void _bindForegroundMessages() {
    FirebaseMessaging.onMessage.listen((message) {
      appLog("FCM foreground message ► ${message.messageId}: ${message.data}");

      // [NUDGE-FIX] iOS already auto-displays the push as a native banner
      // (see setForegroundNotificationPresentationOptions above). Only
      // Android needs this manual local-notification call, since Android's
      // FCM does not auto-display a banner while the app is foregrounded.
      // Calling it on both platforms was producing two banners on iOS.
      if (Platform.isAndroid) {
        _showForegroundBanner(message);
      }

      try {
        final controller = Get.isRegistered<NotificationController>()
            ? Get.find<NotificationController>()
            : Get.put(NotificationController());
        controller.fetchNotifications();
      } catch (e) {
        errorLog("PushNotificationService._bindForegroundMessages.refreshBadge", e);
      }
    });
  }

  Future<void> _showForegroundBanner(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    try {
      await _localNotifications.show(
        id: message.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      errorLog("PushNotificationService._showForegroundBanner", e);
    }
  }

  // ==================== Tap handling (background → foreground) ====================
  void _bindNotificationTapHandling() {
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      appLog("FCM opened from background tap ► ${message.data}");
      _routeFromMessage(message);
    });
  }

  /// App was fully terminated and opened via a notification tap.
  Future<void> _handleInitialMessageIfAny() async {
    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        appLog("FCM opened from terminated state ► ${initialMessage.data}");
        _routeFromMessage(initialMessage);
      }
    } catch (e) {
      errorLog("PushNotificationService._handleInitialMessageIfAny", e);
    }
  }

  /// Central place to translate a push payload into in-app navigation.
  /// Left intentionally minimal — wire this up to Get.toNamed(...) once
  /// the backend confirms what `data` keys (e.g. notification id/type)
  /// will be sent with each push.
  void _routeFromMessage(RemoteMessage message) {
    // Example once backend contract is confirmed:
    // final notificationId = message.data['notificationId'];
    // if (notificationId != null) Get.toNamed(Routes.notificationDetail, ...);
  }

  // ==================== Token lifecycle ====================
  Future<void> _bindTokenLifecycle() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        int retry = 0;
        while (apnsToken == null && retry < 3) {
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
          retry++;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) {
        await _syncToken(token);
      }
    } catch (e) {
      errorLog("PushNotificationService._bindTokenLifecycle.getToken", e);
    }

    _messaging.onTokenRefresh.listen(
          (newToken) => _syncToken(newToken),
      onError: (e) => errorLog("PushNotificationService.onTokenRefresh", e),
    );
  }

  Future<void> _syncToken(String token) async {
    if (_cachedToken == token) return; // avoid redundant network calls

    try {
      final deviceId = await _resolveDeviceId();

      final response = await _api.postServices(
        url: AppApiUrl.instance.saveFcmToken,
        body: {
          "fcmToken": token,
          "deviceId": deviceId,
          "deviceType": Platform.isAndroid ? "android" : "ios",
        },
      );

      if (response is Map && response["success"] == true) {
        // [NUDGE-FIX] Only remember this token as "synced" once the backend
        // actually confirms it. Previously this was set before the network
        // call, so a pre-login failure (no auth token yet) permanently
        // blocked all future retries since the token itself never changes.
        _cachedToken = token;
        appLog("FCM token synced with backend successfully");
      } else {
        final message = response is Map ? response["message"] : response;
        appLog("FCM token sync failed ► $message");
      }
    } catch (e) {
      errorLog("PushNotificationService._syncToken", e);
    }
  }

  /// [NUDGE-FIX] Call this right after a successful login. `init()` runs at
  /// app startup before any user is authenticated, so the very first
  /// `_syncToken` call can fail silently (no Authorization header yet).
  /// This re-fetches the current FCM token and retries the sync now that a
  /// valid auth token exists. Safe to call even if already synced.
  Future<void> resyncTokenAfterLogin() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) await _syncToken(token);
    } catch (e) {
      errorLog("PushNotificationService.resyncTokenAfterLogin", e);
    }
  }

  /// Stable per-install device identifier.
  /// Android: ANDROID_ID (survives app reinstall, resets on factory reset).
  /// iOS: identifierForVendor (resets if ALL apps from the vendor are removed).
  Future<String> _resolveDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final info = await deviceInfo.androidInfo;
        return info.id;
      } else if (Platform.isIOS) {
        final info = await deviceInfo.iosInfo;
        return info.identifierForVendor ?? _fallbackDeviceId();
      }
    } catch (e) {
      errorLog("PushNotificationService._resolveDeviceId", e);
    }
    return _fallbackDeviceId();
  }

  String _fallbackDeviceId() =>
      "unknown_${DateTime.now().millisecondsSinceEpoch}";

  /// Call this after logout so the next login (possibly a different
  /// user on the same device) re-syncs the token under the new account.
  Future<void> resetSyncState() async {
    _cachedToken = null;
  }

  @visibleForTesting
  String? get debugCachedToken => _cachedToken;

  /// Trigger a local notification for testing sound and UI.
  Future<void> showTestNotification() async {
    try {
      // Ensure channel is created before showing (Android specific)
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
            ?.createNotificationChannel(_androidChannel);
      }

      await _localNotifications.show(
        id: 999,
        title: "Test Notification 🔔",
        body: "If you see this and hear a sound, it works perfectly!",
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.max,
            ticker: 'ticker',
            // Sometimes @mipmap/ic_launcher causes issues in debug if not found
            // This fallback helps ensure it shows something
            icon: Platform.isAndroid ? '@mipmap/ic_launcher' : null,
            playSound: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
      appLog("Test notification triggered successfully");
    } catch (e) {
      appLog("Test notification error: $e");
    }
  }
}