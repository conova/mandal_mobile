class ApiConfig {
  static const String baseUrl = 'https://bds.techfi.mn';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ─── Auth ───
  static const String login = '/bdc/api/auth/login.php';
  static const String registerValidate = '/bdc/api/auth/register/validate';
  static const String changePassword = '/bdc/api/auth/change_password';

  // ─── OTP ───
  static const String verificationChannels = '/bdc/api/auth/verification_channels';
  static const String sendOtp = '/bdc/api/auth/send_otp';
  static const String verifyOtp = '/bdc/api/auth/verify_otp';

  // ─── KYC ───
  static const String banksList = '/bdc/api/auth/banks/list';
  static const String pepStatus = '/bdc/api/kyc/pep_status';

  // ─── Device / FCM ───
  static const String registerFcmToken = '/bdc/api/security/fcm_token';

  // ─── Customer / User ───
  static const String userInfo = '/bdc/api/user/info';
  static const String devices = '/bdc/api/security/devices';
  static const String customerCreate = '/bdc/api/customer/create.php';
  static const String customerUpdate = '/bdc/api/customer/update.php';

  // ─── Order ───
  static const String orderCreate = '/bdc/api/order/create.php';

  // ─── Legacy ───
  static const String refreshToken = '/bdc/api/auth/refresh.php';
  static const String profile = '/bdc/api/auth/profile.php';
  static const String accounts = '/bdc/api/auth/accounts.php';
}
