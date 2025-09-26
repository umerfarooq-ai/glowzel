class Endpoints {
  static const String login = '/api/login';
  static const String signup = '/api/register';
  static const String sendActivationOtp = '/api/resend-activation-otp';
  static const String verifyActivationOtp = '/api/activate-otp';
  static const String updateProfile = '/api/me';
  static const String deleteAccount = '/api/me';
  static const String getUserData = '/api/me';
  static const String createProfile = '/api/profile';
  static const String updateProfile1 = '/api/profile';
  static const String getSkinData = '/api/profile';
  static const String forgotPassword = '/api/forgot-password';
  static const String resetPassword = '/api/reset-password-otp';
  static const String changePassword = '/api/change-password';
  static const String sendOtp = '/api/users/deleteAccount/otp';
  static const String verifyDeleteOtp = '/api/users/deleteAccount/verify';
  static const String skinAnalysis = '/api/skin-analysis';
  static const String getSkinHealth = '/api/skin-analysis';
  static const String skinDailyLog = '/api/daily-skin-log';
  static const String createReminder = '/api/reminders';
  static const String updateDeviceToken = '/api/device-token';
}
