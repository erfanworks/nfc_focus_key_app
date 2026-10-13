import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsRowItem extends StatelessWidget {
  final String title;
  final String? trailingText;
  final Widget? trailingWidget;
  final Color? titleColor;
  final Color? trailingTextColor;
  final bool showChevron;
  final VoidCallback? onTap;

  const SettingsRowItem({
    super.key,
    required this.title,
    this.trailingText,
    this.trailingWidget,
    this.titleColor,
    this.trailingTextColor,
    this.showChevron = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget? rightWidget;

    if (trailingWidget != null) {
      rightWidget = trailingWidget;
    } else if (trailingText != null || showChevron) {
      rightWidget = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (trailingText != null) ...[
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 160.w),
              child: Text(
                trailingText!,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.dmSans(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w300,
                  color: trailingTextColor ?? const Color(0xFF8A8278),
                  height: 1.5,
                ),
              ),
            ),
            if (showChevron) SizedBox(width: 4.w),
          ],
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              size: 18.sp,
              color: const Color(0xFF8A8278),
            ),
        ],
      );
    }

    final content = Container(
      height: 49.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: titleColor ?? const Color(0xFF1A1814),
                height: 1.43,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          rightWidget ?? const SizedBox.shrink(),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }
}
