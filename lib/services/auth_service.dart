import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  String? _accessToken;
  String? _refreshToken;

  String? get accessToken => _accessToken;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> login(String userName, String password) async {
    final dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    try {
      final response = await dio.post(
        ApiConfig.login,
        data: {
          'api': 'login',
          'userName': userName,
          'userPass': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Adjust these keys based on actual API response
        final String accessToken = data['access_token'] ?? data['token'] ?? 'mock_access_token';
        final String refreshToken = data['refresh_token'] ?? '';
        
        await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Network error: ${e.message}');
      }
      rethrow;
    }
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  bool get isAuthenticated => _accessToken != null;

  bool _isRefreshing = false;

  // Placeholder for Oauth2 Refresh logic
  Future<String?> refreshAccessToken(Future<String?> Function() refreshCall) async {
    if (_refreshToken == null || _isRefreshing) return null;
    
    _isRefreshing = true;
    try {
      final newAccessToken = await refreshCall();
      if (newAccessToken != null) {
        _accessToken = newAccessToken;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_accessTokenKey, newAccessToken);
        return newAccessToken;
      }
    } finally {
      _isRefreshing = false;
    }
    return null;
  }
}
