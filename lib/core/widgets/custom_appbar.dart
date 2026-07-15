import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: AppTextStyles.heading2),
      centerTitle: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: leading,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.textDark),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56.h);
}
