import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class FriendListItem extends StatelessWidget {
  final String name;
  final String initials;
  final bool isDarkAvatar;
  final String status;
  final bool isFocusing;
  final VoidCallback? onTap;
  final VoidCallback? onSelectToggle;
  final bool isSelected;

  const FriendListItem({
    super.key,
    required this.name,
    required this.initials,
    required this.isDarkAvatar,
    required this.status,
    required this.isFocusing,
    this.onTap,
    this.onSelectToggle,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE8E3DA), width: 1.0),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkAvatar
                    ? const Color(0xFF1A1814)
                    : const Color(0xFFE8E3DA),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDarkAvatar
                        ? const Color(0xFFF7F4EE)
                        : const Color(0xFF1A1814),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1A1814),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isFocusing
                              ? const Color(0xFFE67124)
                              : const Color(0xFF8A8278),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        status,
                        style: GoogleFonts.dmSans(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w400,
                          color: isFocusing
                              ? const Color(0xFFE67124)
                              : const Color(0xFF8A8278),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            onSelectToggle != null
                ? GestureDetector(
              onTap: onSelectToggle,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? const Color(0xFF1A1814)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1A1814)
                        : const Color(0xFFB5AFA5),
                    width: 1.2,
                  ),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check_rounded,
                  size: 14.sp,
                  color: const Color(0xFFF7F4EE),
                )
                    : null,
              ),
            )
                : Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFB5AFA5),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}