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

  /// NEGDI төлбөрийн линк авах (custid, amount, txntype, action)
  static const String paymentLink = '$danServiceUrl/api/payment/link';
  static const String danEUri = '/api/e/uri';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ─── Auth ───
  static const String login = '/bdc/api/auth/login.php';
  static const String registerInitiate = '/bdc/api/register/initiate';
  static const String registerSetPassword = '/bdc/api/register/set_password';
  static const String registerAddAccount = '/bdc/api/register/add_account';
  static const String registerDeleteAccount = '/bdc/api/register/delete_account';
  static const String registerReset = '/bdc/api/register/reset';
  static const String forgotPassword = '/bdc/api/auth/forgot_password';
  static const String changePassword = '/bdc/api/auth/change_password';

  // ─── OTP ───
  static const String verificationChannels =
      '/bdc/api/auth/verification_channels';
  static const String sendOtp = '/bdc/api/auth/send_otp';
  static const String verifyOtp = '/bdc/api/auth/verify_otp';

  /// Банкны лого (bankCode = TXNBANKNO, жнь "21")
  static String bankLogoUrl(String bankCode) =>
      '$baseUrl/bdc/api/images/banks/$bankCode.png';

  // ─── KYC ───
  static const String banksList = '/bdc/api/banks/list';
  static const String pepStatus = '/bdc/api/kyc/pep_status';
  static const String kycUploadDocument = '/bdc/api/kyc/upload_document';
  static const String kycAcceptAgreement = '/bdc/api/kyc/accept_agreement';

  // ─── Device / FCM ───
  static const String registerFcmToken = '/bdc/api/security/fcm_token';

  // ─── Customer / User ───
  static const String userInfo = '/bdc/api/user/info';

  /// POST /user/add_email → и-мэйл нэмэх/солих
  ///   Body: { data: { email } }
  static const String userAddEmail = '/bdc/api/user/add_email';

  /// GET /user/acnts → харилцагчийн орлого авах дансууд
  ///   Response data row: { TXNACNTNO, TXNACNTNAME, TXNBANKNO, BANKNAME,
  ///   BANKNAME2, REGDATE, ISPRIMARY ("1" | "0") }
  static const String userAccounts = '/bdc/api/user/acnts';

  /// GET /user/fees → харилцагчийн шимтгэлийн хувиуд
  ///   Row: { STOCKTYPE, FEE ("1" = 1%), FEEIPO, SIDE, TYPENAME, ... }
  static const String userFees = '/bdc/api/user/fees';

  /// Үнэт цаасны тодорхойлолт (HTML) — ?lang=mn|en
  static const String userDocsDefinition = '/bdc/api/user/docs/definition';

  /// Бичиг баримт (definition | agreement) — HTML, ?lang=mn|en
  static String userDocs(String doc) => '/bdc/api/user/docs/$doc';
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

  /// GET /stocks/nbo → нээлттэй/хаалттай бонд санал болголтууд (home carousel)
  static const String stocksNbo = '/bdc/api/stocks/nbo';

  /// GET /stocks/mystocks → харилцагчийн эзэмшдэг хувьцаанууд
  ///   Row: { SYMBOL, STOCKNAME, AMT, CLOSEPRICE, PRICECHANGE, ISFOREIGN, ... }
  static const String stocksMyStocks = '/bdc/api/stocks/mystocks';

  /// POST /stocks/info → хувьцааны дэлгэрэнгүй мэдээлэл
  ///   Body: { api: "info", data: { stockcode } }
  static const String stocksInfo = '/bdc/api/stocks/info';

  /// POST /stocks/order_book → захиалгын самбар
  ///   Body: { api: "order_book", data: { stockcode } }
  ///   Row: { STOCKCODE, PRICE, TOTAL_CNT, ORDER_TYPE: "BUY"|"SELL",
  ///   PRICE_RANK }
  static const String stocksOrderBook = '/bdc/api/stocks/order_book';

  /// GET /stocks/bondlist → зах зээл дээрх бондууд (бонд авах tab)
  ///   Row: { SYMBOL, STOCKNAME, COMPNAME2, TYPENAME, TERM, INTRATE, AMT,
  ///   ISOPEN, ISFOREIGN, MARKET: "Primary"|"Secondary", ... }
  static const String stocksBondList = '/bdc/api/stocks/bondlist';

  /// GET /stocks/mybonds → харилцагчийн эзэмшдэг бондууд
  ///   Row: { SYMBOL, STOCKNAME, COMPNAME2, TYPENAME, AMT, INTRATE, ISOPEN,
  ///   ISFOREIGN, ... }
  static const String stocksMyBonds = '/bdc/api/stocks/mybonds';
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

  /// POST /portfolio/summary_report?start=YYYY/MM/DD&end=YYYY/MM/DD
  ///   Body: { api: "summary_report" }
  ///   data.portfolio: огноо/төрөл тус бүрийн үлдэгдэл
  ///     { TXNDATE, TYPE: bond|cash|stock, CODENAME, AMOUNT, AMOUNTMNT, CNT }
  ///   data.transactions: төрөл тус бүрээс нэг мөр (байхгүй бол 0 гэж үзнэ)
  ///     { TXNDATE, TYPE: stock|cash|rateincome|dividend|bond, AMOUNT, ... }
  static const String portfolioSummaryReport =
      '/bdc/api/portfolio/summary_report';

  // ─── Order ───
  static const String orderCreate = '/bdc/api/order/create.php';

  /// POST /order/new — захиалга үүсгэх (олон захиалга зэрэг дэмжинэ)
  ///   Body: { data: [{STOCKCODE, CNT, PRICE, TXNTYPE, ORDERTYPE, CONDID,
  ///                   DESCR, EXPDATE (yyyy/MM/dd), FEE, ACNTNO}] }
  ///   Response: { code: "0", message, data: [{idx, success, msg, txnId}] }
  static const String orderNew = '/bdc/api/order/new';

  /// POST /order/cancel — захиалга цуцлах (олон захиалга зэрэг)
  ///   Body: { data: [{TXNID, ORDERNO}] } (утгууд orders жагсаалтаас ирнэ)
  static const String orderCancel = '/bdc/api/order/cancel';

  // ─── Legacy ───
  static const String refreshToken = '/bdc/api/auth/refresh.php';

  /// Профайл солих (өөрийн ↔ хүүхдийн данс) — refresh-тэй ижил хариу
  static const String switchProfile = '/bdc/api/auth/switch_profile';

  // ── Захиалга (orders) ────────────────────────────────────────────
  /// Идэвхтэй бүх захиалга
  static const String ordersActive = '/bdc/api/orders/active';

  /// Идэвхтэй бондын захиалгууд
  static const String ordersActiveBonds = '/bdc/api/orders/activebond';

  /// Идэвхтэй хувьцааны захиалгууд
  static const String ordersActiveStocks = '/bdc/api/orders/activestocks';

  /// Захиалгын түүх (type/status/start/end шүүлттэй POST)
  static const String ordersHistory = '/bdc/api/orders/history';
  static const String profile = '/bdc/api/auth/profile.php';
  static const String accounts = '/bdc/api/auth/accounts.php';
}
