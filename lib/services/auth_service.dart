import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

class AuthService with ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _storyShownKey = 'story_shown';
  static const String _lastUserNameKey = 'last_user_name';
  static const String _lastUserIdKey = 'last_user_id';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricTokenKey = 'biometric_token';

  final LocalAuthentication _localAuth = LocalAuthentication();

  String? _accessToken;
  String? _refreshToken;
  bool _storyShown = false;
  String? _lastUserName;
  String? _lastUserId;
  bool _isBiometricEnabled = false;
  String? _biometricToken;

  String? get accessToken => _accessToken;
  bool get hasShownStory => _storyShown;
  bool get hasSavedUser => _lastUserId != null;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String? get biometricToken => _biometricToken;

  Map<String, String?> get savedUser => {
    'name': _lastUserName,
    'id': _lastUserId,
  };

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _storyShown = prefs.getBool(_storyShownKey) ?? false;
    _lastUserName = prefs.getString(_lastUserNameKey);
    _lastUserId = prefs.getString(_lastUserIdKey);
    _isBiometricEnabled = prefs.getBool(_biometricEnabledKey) ?? false;
    _biometricToken = prefs.getString(_biometricTokenKey);
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    if (!enabled) {
      _biometricToken = null;
      await prefs.remove(_biometricTokenKey);
    }
    notifyListeners();
  }

  Future<void> saveBiometricToken(String token) async {
    _biometricToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_biometricTokenKey, token);
    notifyListeners();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return <BiometricType>[];
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      if (!canAuthenticate) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Нэвтрэхийн тулд баталгаажуулна уу',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }

  Future<void> saveLastUser(String name, String id) async {
    _lastUserName = name;
    _lastUserId = id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastUserNameKey, name);
    await prefs.setString(_lastUserIdKey, id);
  }

  Future<void> setStoryShown() async {
    _storyShown = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storyShownKey, true);
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    _accessToken = accessToken;
    _refreshToken = refreshToken;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> login(String userName, String password) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    try {
      final response = await dio.post(
        ApiConfig.login,
        data: {'api': 'login', 'userName': userName, 'userPass': password},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        // Adjust these keys based on actual API response
        final String accessToken =
            data['access_token'] ?? data['token'] ?? 'mock_access_token';
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

  Future<void> clearLastUser() async {
    _lastUserId = null;
    _lastUserName = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastUserNameKey);
    await prefs.remove(_lastUserIdKey);
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
  Future<String?> refreshAccessToken(
    Future<String?> Function() refreshCall,
  ) async {
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
