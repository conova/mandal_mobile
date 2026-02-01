class ApiConfig {
  static const String baseUrl = 'http://192.168.1.133'; // Replace with actual base URL
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/bdc/api/auth/login.php';
  static const String refreshToken = '/bdc/api/auth/refresh.php';
  static const String profile = '/bdc/api/auth/profile.php';
  static const String accounts = '/bdc/api/auth/accounts.php';
}
