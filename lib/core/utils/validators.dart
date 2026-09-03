import '../constants/app_strings.dart';

class Validators {
  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    return null;
  }

  static String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return AppStrings.errorInvalidEmail;
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.errorEmptyField;
    }
    if (value.length < 6) {
      return AppStrings.errorShortPassword;
    }
    return null;
  }
}
