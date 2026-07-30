import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'core/services/storage_service.dart';
import 'core/services/storage_services.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    DevicePreview(enabled: kDebugMode, builder: (context) => const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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

          initialRoute: Routes.signup,
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'core/services/storage_service.dart';
// import 'core/theme/app_theme.dart';
// import 'routes/app_pages.dart';
// import 'routes/app_routes.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await StorageService.init();
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(430, 932),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (context, child) {
//         return GetMaterialApp(
//           title: 'Smart Lock',
//           theme: AppTheme.light,
//           initialRoute: Routes.onboarding,
//           getPages: AppPages.pages,
//           debugShowCheckedModeBanner: false,
//         );
//       },
//     );
//   }
// }
