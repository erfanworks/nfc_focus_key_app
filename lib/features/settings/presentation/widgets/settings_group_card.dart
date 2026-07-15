import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;
  final Color backgroundColor;
  final BoxBorder? border;

  const SettingsGroupCard({
    super.key,
    required this.children,
    this.backgroundColor = const Color(0xFFF0EBE2),
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> itemsWithDividers = [];
    for (int i = 0; i < children.length; i++) {
      itemsWithDividers.add(children[i]);
      if (i < children.length - 1) {
        itemsWithDividers.add(
          Divider(
            height: 1.h,
            thickness: 1.h,
            color: const Color(0xFFE8E3DA),
            indent: 16.w,
            endIndent: 16.w,
          ),
        );
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14.r),
        border: border,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: itemsWithDividers,
      ),
    );
  }
}
