class ApiConfig {
  static const String baseUrl = 'https://api.example.com'; // Replace with actual base URL
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  // Endpoints
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String profile = '/user/profile';
  static const String accounts = '/user/accounts';
}
