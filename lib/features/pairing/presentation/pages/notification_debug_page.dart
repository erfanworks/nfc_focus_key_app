// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import '../../../../core/services/push_notification_service.dart';
// import '../../../../core/theme/app_colors.dart';
//
// class NotificationDebugPage extends StatefulWidget {
//   const NotificationDebugPage({super.key});
//
//   @override
//   State<NotificationDebugPage> createState() => _NotificationDebugPageState();
// }
//
// class _NotificationDebugPageState extends State<NotificationDebugPage> {
//   String? _token;
//   bool _isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchToken();
//   }
//
//   Future<void> _fetchToken() async {
//     setState(() => _isLoading = true);
//     try {
//       String? token = await FirebaseMessaging.instance.getToken();
//       setState(() => _token = token);
//     } catch (e) {
//       setState(() => _token = "Error fetching token: $e");
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _copyToken() {
//     if (_token != null) {
//       Clipboard.setData(ClipboardData(text: _token!));
//       Get.snackbar(
//         "Copied!",
//         "FCM Token copied to clipboard",
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: AppColors.primary,
//         colorText: Colors.white,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: AppBar(
//         title: Text(
//           "Notification Debug",
//           style: GoogleFonts.cormorantGaramond(
//             fontWeight: FontWeight.w600,
//             fontSize: 20.sp,
//           ),
//         ),
//         backgroundColor: AppColors.background,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(20.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildSection(
//               "FCM Device Token",
//               child: Column(
//                 children: [
//                   Container(
//                     padding: EdgeInsets.all(12.w),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12.r),
//                       border: Border.all(color: AppColors.textFieldBorder),
//                     ),
//                     child: _isLoading
//                         ? const Center(child: CircularProgressIndicator())
//                         : Text(
//                             _token ?? "No token found",
//                             style: GoogleFonts.dmSans(fontSize: 12.sp),
//                           ),
//                   ),
//                   SizedBox(height: 12.h),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton.icon(
//                       onPressed: _token != null ? _copyToken : null,
//                       icon: const Icon(Icons.copy, size: 18),
//                       label: const Text("Copy Token"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: AppColors.primary,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 32.h),
//             _buildSection(
//               "Test Local Notification",
//               child: Column(
//                 children: [
//                   Text(
//                     "This will trigger a notification immediately to test sounds, icons, and banners.",
//                     style: GoogleFonts.dmSans(
//                       fontSize: 14.sp,
//                       color: AppColors.textBody,
//                     ),
//                   ),
//                   SizedBox(height: 16.h),
//                   SizedBox(
//                     width: double.infinity,
//                     child: OutlinedButton.icon(
//                       onPressed: () {
//                         Get.find<PushNotificationService>().showTestNotification();
//                       },
//                       icon: const Icon(Icons.notifications_active_outlined),
//                       label: const Text("Trigger Test Notification"),
//                       style: OutlinedButton.styleFrom(
//                         foregroundColor: AppColors.primary,
//                         side: const BorderSide(color: AppColors.primary),
//                         padding: EdgeInsets.symmetric(vertical: 14.h),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const Spacer(),
//             Center(
//               child: Text(
//                 "Use the token above to send a real push from Firebase Console.",
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.dmSans(
//                   fontSize: 12.sp,
//                   color: AppColors.textHelper,
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection(String title, {required Widget child}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: GoogleFonts.dmSans(
//             fontWeight: FontWeight.w700,
//             fontSize: 16.sp,
//             color: AppColors.textDark,
//           ),
//         ),
//         SizedBox(height: 12.h),
//         child,
//       ],
//     );
//   }
// }
