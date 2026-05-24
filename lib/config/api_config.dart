class ApiConfig {
  static const String baseUrl = 'https://bds.techfi.mn';
  // Payment Gateway микросервис (NEGDI integration)
  // Production-д өөрийн домэйнд солих ёстой
  static const String paymentGatewayUrl = 'http://10.0.2.2:3002';
  // Notification Gateway микросервис (FCM + DB)
  static const String notificationGatewayUrl = 'http://10.0.2.2:3001';
  // DAN (E-Mongolia) service base URL
  static const String danServiceUrl = 'https://mandalcapital.mn/dan';
  static const String danEUri = '/api/e/uri';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ─── Auth ───
  static const String login = '/bdc/api/auth/login.php';
  static const String registerInitiate = '/bdc/api/register/initiate';
  static const String registerSetPassword = '/bdc/api/register/set_password';
  static const String registerAddAccount = '/bdc/api/register/add_account';
  static const String registerReset = '/bdc/api/register/reset';
  static const String forgotPassword = '/bdc/api/auth/forgot_password';
  static const String changePassword = '/bdc/api/auth/change_password';

  // ─── OTP ───
  static const String verificationChannels =
      '/bdc/api/auth/verification_channels';
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

  // ─── Watchlist ───
  static const String watchlistList = '/bdc/api/watchlist/list';
  static const String watchlistAvailable = '/bdc/api/watchlist/available';

  /// Add/remove watchlist — path includes symbol: `/watchlist/{SYMBOL}`
  /// add: POST no body
  /// delete: POST body `{api: "watchlist_delete", data: {symbol}}`
  static String watchlistAdd(String symbol) => '/bdc/api/watchlist/$symbol';

  // ─── Stocks ───
  static const String stocksGainers = '/bdc/api/stocks/gainers';
  static const String stocksLosers = '/bdc/api/stocks/losers';
  static const String stocksIpo = '/bdc/api/stocks/ipo';

  // ─── Order ───
  static const String orderCreate = '/bdc/api/order/create.php';

  // ─── Legacy ───
  static const String refreshToken = '/bdc/api/auth/refresh.php';
  static const String profile = '/bdc/api/auth/profile.php';
  static const String accounts = '/bdc/api/auth/accounts.php';
}
