import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class FocusMessageController extends GetxController {
  final TextEditingController messageController = TextEditingController();

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }

  void saveMessage() {
    // Save logic here
    _navigateToNext();
  }

  void skip() {
    _navigateToNext();
  }

  void _navigateToNext() {
    Get.offAllNamed(Routes.login);
  }
}
