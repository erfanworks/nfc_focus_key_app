import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../custom_text.dart';

class ErrorSnackBarMessageWidget extends StatelessWidget {
  final String errorMessage;

  const ErrorSnackBarMessageWidget({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    // --- Error Message Column ---
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          title: "Error!",
          textColor: Colors.white,
          textSize: 18.sp, // ScreenUtil for text size
          fontWeight: FontWeight.w900,
        ),
        SizedBox(height: 5.h), // ScreenUtil for height spacing
        CustomText(
          title: errorMessage,
          textColor: Colors.white,
          textSize: 14.sp, // Added responsive text size
          textAlign: TextAlign.left, // Left aligned looks better in columns
        ),
      ],
    );
  }
}