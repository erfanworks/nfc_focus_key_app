import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationItemModel {
  final String avatarInitials;
  final String title;
  final String subtitle;
  final bool hasUnreadDot;
  final Widget? trailingWidget;
  final String? trailingText;
  final Color? trailingTextColor;
  final bool isExpired;

  NotificationItemModel({
    required this.avatarInitials,
    required this.title,
    required this.subtitle,
    this.hasUnreadDot = false,
    this.trailingWidget,
    this.trailingText,
    this.trailingTextColor,
    this.isExpired = false,
  });
}

class NotificationItem extends StatelessWidget {
  final NotificationItemModel data;
  final VoidCallback? onTap;

  const NotificationItem({super.key, required this.data, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: onTap,
        child: Opacity(
          opacity: data.isExpired ? 0.4 : 1.0,
          child: Padding(
        padding: EdgeInsets.only(
          top: 12.h,
          right: 16.w,
          bottom: 12.h,
          left: 16.w,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: Stack(
                children: [
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8E3DA),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        data.avatarInitials,
                        style: GoogleFonts.dmSans(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1814),
                        ),
                      ),
                    ),
                  ),
                  if (data.hasUnreadDot)
                    Positioned(
                      right: 2.w,
                      bottom: 2.w,
                      child: Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE67124),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF0EBE2),
                            width: 2.w,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF1A1814),
                      height: 16.25 / 13,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    data.subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF8A8278),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            if (data.trailingWidget != null) ...[
              SizedBox(width: 12.w),
              data.trailingWidget!,
            ] else if (data.trailingText != null) ...[
              SizedBox(width: 12.w),
              Text(
                data.trailingText!,
                style: GoogleFonts.dmSans(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: data.trailingTextColor ?? const Color(0xFF8A8278),
                ),
              ),
            ],
          ],
        ),
      ),
    ));
  }
}
