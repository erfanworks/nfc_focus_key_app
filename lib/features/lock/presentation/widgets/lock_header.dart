import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:focus_key/routes/app_routes.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/lock_controller.dart';

class LockHeader extends StatelessWidget {
  final LockController controller;

  const LockHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Focus Key',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF1A1814),
                  letterSpacing: 0.18.w,
                ),
              ),
              GestureDetector(
                onTap: () => Get.toNamed(Routes.notification),
                child: Icon(
                  Icons.notifications_none_outlined,
                  color: const Color(0xFF1A1814),
                  size: 24.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.center,
            child: controller.isOnBreak.value
                ? Container(
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40.w),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EBE2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFF5722),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Flexible(
                          child: Text(
                            'Ethan is also focusing',
                            style: GoogleFonts.dmSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF1A1814),
                              height: 1.2,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  )
                : controller.isLocked.value
                    ? Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40.w),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0EBE2),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_alt_outlined,
                              color: const Color(0xFF8A8278),
                              size: 14.sp,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                'You are focusing with 3 friends',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF1A1814),
                                  height: 1.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GestureDetector(
                        onTap: () => Get.toNamed(Routes.joinFocus),
                        child: Container(
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 40.w),
                          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EBE2),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5722),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  '3 friends are focusing. Join them?',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF1A1814),
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      );
    });
  }
}
