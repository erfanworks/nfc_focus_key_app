import 'package:flutter/cupertino.dart';
import 'package:focus_key/features/pairing/presentation/bindings/new_mode_binding.dart';
import 'package:focus_key/features/pairing/presentation/nfc_uid_debug_page.dart';
import 'package:focus_key/features/pairing/presentation/pages/notification_debug_page.dart';
import 'package:focus_key/features/pairing/presentation/pages/customize_modes_page.dart';
import 'package:get/get.dart';
import '../features/pairing/presentation/bindings/enable_permissions_binding.dart';
import '../features/pairing/presentation/pages/enable_permissions_page.dart';
import '../features/pairing/presentation/pages/shield_page.dart';
import '../features/settings/presentation/pages/total_focus_apps_page.dart';
import 'app_routes.dart';
import '../features/auth/presentation/bindings/auth_binding.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/onboarding/presentation/bindings/splash_binding.dart';
import '../features/onboarding/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/bindings/onboarding_binding.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/onboarding/presentation/bindings/focus_message_binding.dart';
import '../features/onboarding/presentation/pages/focus_message_page.dart';
import '../features/auth/presentation/bindings/forgot_password_binding.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/bindings/email_verify_binding.dart';
import '../features/auth/presentation/pages/email_verify_page.dart';
import '../features/auth/presentation/bindings/reset_password_binding.dart';
import '../features/auth/presentation/pages/reset_password_page.dart';
import '../features/auth/presentation/bindings/signup_binding.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/bindings/user_verify_binding.dart';
import '../features/auth/presentation/pages/user_verify_page.dart';
import '../features/pairing/presentation/bindings/pairing_binding.dart';
import '../features/pairing/presentation/pages/pairing_page.dart';
import '../features/pairing/presentation/bindings/pairing_scanner_binding.dart';
import '../features/pairing/presentation/pages/pairing_scanner_page.dart';
import '../features/pairing/presentation/bindings/paired_success_binding.dart';
import '../features/pairing/presentation/pages/paired_success_page.dart';
import '../features/pairing/presentation/bindings/lets_unlock_binding.dart';
import '../features/pairing/presentation/pages/lets_unlock_page.dart';
import '../features/pairing/presentation/bindings/customize_modes_binding.dart';
import '../features/pairing/presentation/pages/new_mode_page.dart';
import '../features/pairing/presentation/bindings/app_selection_binding.dart';
import '../features/pairing/presentation/pages/app_selection_page.dart';
import '../features/pairing/presentation/pages/select_mode_page.dart';
import '../features/pairing/presentation/bindings/modes_binding.dart';
import '../features/pairing/presentation/pages/modes_page.dart';
import '../features/pairing/presentation/bindings/break_binding.dart';
import '../features/pairing/presentation/pages/break_page.dart';
import '../features/pairing/presentation/bindings/dashboard_binding.dart';
import '../features/pairing/presentation/pages/dashboard_page.dart';
import 'package:focus_key/features/notifications/presentation/binding/notification_binding.dart';
import 'package:focus_key/features/settings/presentation/bindings/export_data_dinding.dart';
import 'package:focus_key/features/settings/presentation/pages/personal_reminder_page.dart';
import 'package:focus_key/features/settings/presentation/pages/focus_history_page.dart';
import 'package:focus_key/features/settings/presentation/pages/export_data_page.dart';
import 'package:focus_key/features/settings/presentation/pages/key_status_page.dart';
import 'package:focus_key/features/friends/presentation/pages/add_partner_page.dart';
import 'package:focus_key/features/friends/presentation/pages/friend_details_page.dart';
import 'package:focus_key/features/notifications/presentation/pages/notification_page.dart';
import 'package:focus_key/features/notifications/presentation/pages/join_focus_page.dart';
import 'package:focus_key/features/settings/presentation/pages/change_password_page.dart';
import 'package:focus_key/features/settings/presentation/pages/edit_information_page.dart';
import 'package:focus_key/features/settings/presentation/pages/personal_information_page.dart';
import 'package:focus_key/features/settings/presentation/pages/delete_account_page.dart';
import 'package:focus_key/features/settings/presentation/pages/legal_information_page.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.onboarding,
      page: () => const OnboardingPage(),
      binding: OnboardingBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.focusMessage,
      page: () => const FocusMessagePage(),
      binding: FocusMessageBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginPage(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.forgotPassword,
      page: () => const ForgotPasswordPage(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.emailVerify,
      page: () => const EmailVerifyPage(),
      binding: EmailVerifyBinding(),
    ),
    GetPage(
      name: Routes.resetPassword,
      page: () => const ResetPasswordPage(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: Routes.signup,
      page: () => const SignUpPage(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: Routes.userVerify,
      page: () => const UserVerifyPage(),
      binding: UserVerifyBinding(),
    ),
    GetPage(
      name: Routes.pairing,
      page: () => const PairingPage(),
      binding: PairingBinding(),
    ),
    GetPage(
      name: Routes.pairingScanner,
      page: () => const PairingScannerPage(),
      binding: PairingScannerBinding(),
    ),
    GetPage(
      name: Routes.paired,
      page: () => const PairedSuccessPage(),
      binding: PairedSuccessBinding(),
    ),
    GetPage(
      name: Routes.enablePermissions,
      page: () => const EnablePermissionsPage(),
      binding: EnablePermissionsBinding(),
    ),
    GetPage(
      name: Routes.letsUnlock,
      page: () => const LetsUnlockPage(),
      binding: LetsUnlockBinding(),
    ),
    GetPage(
      name: Routes.customizeModes,
      page: () => const CustomizeModesPage(),
      binding: CustomizeModesBinding(),
    ),
    GetPage(
      name: Routes.newMode,
      page: () => const NewModePage(),
      binding: NewModeBinding(),
    ),
    GetPage(
      name: Routes.appSelection,
      page: () => const AppSelectionPage(),
      binding: AppSelectionBinding(),
    ),
    GetPage(
      name: Routes.modes,
      page: () => const ModesPage(),
      binding: ModesBinding(),
    ),
    GetPage(
      name: Routes.selectMode,
      page: () => const SelectModePage(),
      binding: ModesBinding(),
    ),
    GetPage(
      name: Routes.takeBreak,
      page: () => const BreakPage(),
      binding: BreakBinding(),
    ),
    GetPage(
      name: Routes.lock,
      page: () => const DashboardPage(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: Routes.personalReminder,
      page: () => const PersonalReminderPage(),
    ),
    GetPage(name: Routes.focusHistory, page: () => FocusHistoryPage()),
    GetPage(
      name: Routes.exportData,
      page: () => const ExportDataPage(),
      binding: ExportDataBinding(),
    ),
    GetPage(name: Routes.keyStatus, page: () => KeyStatusPage()),
    GetPage(name: Routes.addPartner, page: () => AddPartnerPage()),
    GetPage(name: Routes.friendDetails, page: () => const FriendDetailsPage()),
    GetPage(
      name: Routes.notification,
      page: () => const NotificationPage(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.joinFocus,
      page: () => const JoinFocusPage(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: Routes.changePassword,
      page: () => const ChangePasswordPage(),
    ),
    GetPage(
      name: Routes.personalInformation,
      page: () => const PersonalInformationPage(),
    ),
    GetPage(
      name: Routes.editInformation,
      page: () => const EditInformationPage(),
    ),
    GetPage(name: Routes.deleteAccount, page: () => const DeleteAccountPage()),
    GetPage(
      name: Routes.legalInformation,
      page: () => const LegalInformationPage(),
    ),

    GetPage(name: Routes.shield, page: () => const ShieldPage()),
    GetPage(
      name: Routes.totalFocusApps,
      page: () => const TotalFocusAppsPage(),
    ),



    GetPage(name: Routes.nfcUidDebugPage, page: () => const NfcUidDebugPage()),
    // GetPage(name: Routes.notificationDebug, page: () => const NotificationDebugPage()),
  ];
}
