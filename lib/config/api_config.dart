class ApiConfig {
  static const String baseUrl = 'https://bds.techfi.mn';
  // Payment Gateway микросервис (NEGDI integration)
  // Production-д өөрийн домэйнд солих ёстой
  static const String paymentGatewayUrl = 'http://10.0.2.2:3002';
  // Notification Gateway микросервис (FCM + DB)
  // Production: https://notification.mandalcapital.mn
  // Local dev (Android emulator): http://10.0.2.2:3001
  static const String notificationGatewayUrl =
      'https://notification.mandalcapital.mn';

  // ─── Notification Gateway endpoints ───
  /// GET /v1/notifications?unread_only={bool}&limit={1..200}&offset={int}
  ///   Хэрэглэгчийн feed (user-target + broadcast). Bearer JWT шаардана.
  ///   Response: { data: [...], count }
  static const String notificationsList = '/v1/notifications';

  /// POST /v1/notifications/{id}/read → 204 No Content
  static String notificationMarkRead(int id) => '/v1/notifications/$id/read';

  /// POST /v1/notifications/read-all → 204 No Content
  static const String notificationsMarkAllRead = '/v1/notifications/read-all';
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
  static const String banksList = '/bdc/api/banks/list';
  static const String pepStatus = '/bdc/api/kyc/pep_status';
  static const String kycUploadDocument = '/bdc/api/kyc/upload_document';
  static const String kycAcceptAgreement = '/bdc/api/kyc/accept_agreement';

  // ─── Device / FCM ───
  static const String registerFcmToken = '/bdc/api/security/fcm_token';

  // ─── Customer / User ───
  static const String userInfo = '/bdc/api/user/info';
  static const String devices = '/bdc/api/security/devices';
  static const String customerCreate = '/bdc/api/customer/create.php';
  static const String customerUpdate = '/bdc/api/customer/update.php';

  // ─── Watchlist ───
  static const String watchlistList = '/bdc/api/watchlist/list';
  static const String watchlistAvailable = '/bdc/api/stocks/available';

  /// Add/remove watchlist — path includes symbol: `/watchlist/{SYMBOL}`
  /// add: POST no body
  /// delete: POST body `{api: "watchlist_delete", data: {symbol}}`
  static String watchlistAdd(String symbol) => '/bdc/api/watchlist/$symbol';

  // ─── Stocks ───
  static const String stocksGainers = '/bdc/api/stocks/gainers';
  static const String stocksLosers = '/bdc/api/stocks/losers';
  static const String stocksIpo = '/bdc/api/stocks/ipo';
  static const String stocksSearch = '/bdc/api/stocks/search';

  /// Symbol-ийн график — `/stocks/{SYMBOL}/chart`
  /// Query: start=YYYY/MM/DD&end=YYYY/MM/DD
  static String stockChart(String symbol) => '/bdc/api/stocks/$symbol/chart';

  // ─── Portfolio ───
  /// GET /portfolio/summary → { totalAssets, totalChange, changePercent, cashBalance }
  static const String portfolioSummary = '/bdc/api/portfolio/summary';

  /// GET /portfolio/chart_data?period=1D|1W|1M|3M|1Y|ALL → { points: [{date, value}], period }
  static const String portfolioChartData = '/bdc/api/portfolio/chart_data';

  /// GET /portfolio/breakdown
  ///   Response data row: { TYPE, AMOUNT, AMOUNTMNT, COUNT, CODENAME, CODEORDER }
  ///   TYPE: 'mnt' | 'usd' | 'bond' | 'stock'
  ///   AMOUNT: өөрийн нэгжээр (cash → валют, bond/stock → ширхэг)
  ///   AMOUNTMNT: MNT эквивалент
  ///   CODENAME: Монгол нэр (Төгрөг/Доллар/Бонд/Хувьцаа)
  ///   CODEORDER: эрэмбэ (1..4)
  static const String portfolioBreakdown = '/bdc/api/portfolio/breakdown';

  // ─── Order ───
  static const String orderCreate = '/bdc/api/order/create.php';

  // ─── Legacy ───
  static const String refreshToken = '/bdc/api/auth/refresh.php';
  static const String profile = '/bdc/api/auth/profile.php';
  static const String accounts = '/bdc/api/auth/accounts.php';
}
