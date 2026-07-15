import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../constants/app_constants.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final bool usePadding;

  const AppScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.usePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: appBar,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: usePadding ? AppConstants.paddingMedium : 0,
          ),
          child: body,
        ),
      ),
    );
  }
}
