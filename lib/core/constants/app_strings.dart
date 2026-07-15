class AppStrings {
  // Common
  static const String appName = 'Smart Lock';
  static const String retry = 'Retry';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';

  // Auth
  static const String login = 'Login';
  static const String signup = 'Sign Up';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String emailHint = 'Enter your email';
  static const String passwordHint = 'Enter your password';
  static const String loginToContinue = 'Login to continue';

  // Errors
  static const String errorGeneric = 'Something went wrong';
  static const String errorNetwork = 'Network error occurred';
  static const String errorEmptyField = 'This field cannot be empty';
  static const String errorInvalidEmail = 'Please enter a valid email';
  static const String errorShortPassword =
      'Password must be at least 6 characters';

  // Onboarding
  static const String next = 'Next';
  static const String onboardingTitle1 = 'The Focus Key';
  static const String onboardingDesc1 =
      "Your Focus Key is a passive NFC tag. It doesn't broadcast signals or require charging.";
  static const String onboardingTitle2 = 'Private Pairing';
  static const String onboardingDesc2 =
      "The app only recognizes your unique paired key. No other phone or NFC device can unlock your sessions.";
  static const String onboardingTitle3 = 'Custom Mode';
  static const String onboardingDesc3 =
      "Shape each mode around a different part of your life. Create spaces for study, work, gym, sleep, and more - each with its own blocked apps.";

  // Focus Message
  static const String focusMessageTitle = 'What deserves your focus?';
  static const String focusMessageDesc =
      'Write a short message to yourself for moments you feel distracted.';
  static const String focusMessageHint = 'I want to stay focused for...';
  static const String focusMessageHelper =
      'Shown when you try to open a locked app.';
  static const String saveMessage = 'Save Message';
  static const String skipForNow = 'Skip for now';

  // Login
  static const String welcomeBack = 'Welcome back.';
  static const String signInToContinue = 'Sign in to continue.';
  static const String forgotPassword = 'Forgot password?';
  static const String signIn = 'Sign in';
  static const String newHere = 'New here? ';
  static const String createAccount = 'Create an account';

  // Forgot Password
  static const String forgotPasswordTitle = 'Forgot password';
  static const String forgotPasswordDesc =
      "Enter your email and we'll send a reset code";
  static const String sendCode = 'Send Code';

  // Email Verify
  static const String checkYourEmail = 'Check your email';
  static const String weSentCode = 'We sent a 6 - digit code to your email';
  static const String enterCodeToVerify = 'Enter the code to verify your email';
  static const String continueBtn = 'Continue';
  static const String resend = 'Resend';

  // Reset Password
  static const String setNewPassword = 'Set new password';
  static const String setStrongPassword = 'Set a strong Password';
  static const String confirmPassword = 'Confirm Password';
  static const String confirm = 'Confirm';

  // Sign Up
  static const String createAccountTitle = 'Create Account';
  static const String dataStaysOnDevice = 'Your data stays on your device';
  static const String alreadyHaveAccount = 'Already have an account? ';

  // Landing / Pairing
  static const String focusTitle = 'Focus';
  static const String focusSubtitle = 'on what truly matters to you';
  static const String tapToStartPairing = 'Tap to start pairing';
  static const String holdKeyAgainstBack =
      'Held your key against the back of\nyour phone'; // exact match from screen
  static const String pairedTitle = 'Paired';
  static const String readyToBegin = "You're ready to begin";
  static const String letsUnlockTitle = "Let's unlock \nyour focus \ntogether";
  static const String customizeModesTitle = "Customize \nyour modes";
  static const String customizeModesSubtitle =
      "Remember what deserves\nyour focus";
  static const String modeSelectionTitle = 'Mode Selection';
  static const String modeSelectionSubtitle = 'Choose how you want to focus';
  static const String modeOptionLock = 'Lock';
  static const String modeOptionUnlock = 'Unlock';
  static const String modeOptionAuto = 'Auto';

  // New Mode
  static const String newModeTitle = 'New Mode';
  static const String newModeSubtitle =
      'Modes let you switch between different blocklist';
  static const String modeNameLabel = 'Mode Name';
  static const String modeNameHint = 'e.g. Deep Work';
  static const String descriptionLabel = 'Description';
  static const String descriptionHint = 'Write a short description';
  static const String selectIconLabel = 'Select icon';
  static const String startWithMode = 'Start with ';

  // App Selection
  static const String whatTakesYourTimeTitle = 'What takes your time?';
  static const String whatTakesYourTimeSubtitle = 'What takes your time?';
  static const String showMore = 'Show more';

  // Modes List
  static const String modesTitle = 'Modes';
  static const String modesSubtitle =
      'Modes let you switch between different blocklist';
  static const String addNewMode = '+ Add New Mode';
}
