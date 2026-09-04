import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/services/app_lock_native_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/storage_services.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Background/terminated-state FCM messages must be handled by a
  // top-level function registered before runApp().
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await Get.putAsync(() => AppLockNativeService().init());
  await Get.putAsync(() => PushNotificationService().init());

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final initialRoute = await _resolveInitialRoute();

  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder: (context) => MyApp(initialRoute: initialRoute),
    ),
  );
}

Future<String> _resolveInitialRoute() async {
  final hasCompletedOnboarding = await StorageServices.instance
      .hasCompletedOnboarding();
  if (!hasCompletedOnboarding) return Routes.splash;

  final token = await StorageServices.instance.getToken();
  if (token.isEmpty) return Routes.login;

  final isPaired = await StorageServices.instance.hasPairedKey();
  return isPaired ? Routes.lock : Routes.pairing;
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: 'Smart Lock',
          debugShowCheckedModeBanner: false,

          theme: AppTheme.light,

          initialRoute: initialRoute,
          getPages: AppPages.pages,

          // Device Preview Support
          useInheritedMediaQuery: true,
          locale: DevicePreview.locale(context),
          builder: DevicePreview.appBuilder,
        );
      },
    );
  }
}

// import 'package:device_preview/device_preview.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
//
// import 'core/services/app_lock_native_service.dart';
// import 'core/services/push_notification_service.dart';
// import 'core/theme/app_theme.dart';
// import 'firebase_options.dart';
// import 'routes/app_pages.dart';
// import 'routes/app_routes.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   //// Test
//   // await StorageServices.instance.savePairedKeyId("TEST_DEBUG_UID");
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   // Background/terminated-state FCM messages must be handled by a
//   // top-level function registered before runApp().
//   FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
//
//   await Get.putAsync(() => AppLockNativeService().init());
//   await Get.putAsync(() => PushNotificationService().init());
//
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//
//   runApp(
//     DevicePreview(enabled: kDebugMode, builder: (context) => const MyApp()),
//   );
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(430, 932),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return GetMaterialApp(
//           title: 'Smart Lock',
//           debugShowCheckedModeBanner: false,
//
//           theme: AppTheme.light,
//
//           initialRoute: Routes.splash,
//           getPages: AppPages.pages,
//
//           // Device Preview Support
//           useInheritedMediaQuery: true,
//           locale: DevicePreview.locale(context),
//           builder: DevicePreview.appBuilder,
//         );
//       },
//     );
//   }
// }
