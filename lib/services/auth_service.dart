import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../config/api_config.dart';

/// Login хариуны төрөл
class LoginResult {
  /// Амжилттай нэвтэрсэн эсэх (deviceId бүртгэлтэй бол шууд true)
  final bool success;

  /// OTP баталгаажуулалт шаардлагатай эсэх (deviceId бүртгэлгүй)
  final bool requiresOtp;

  /// OTP flow-д ашиглах session ID
  final String? sessionId;

  /// Алдааны мессеж
  final String? message;

  const LoginResult({
    this.success = false,
    this.requiresOtp = false,
    this.sessionId,
    this.message,
  });
}

class AuthService with ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _storyShownKey = 'story_shown';
  static const String _lastUserNameKey = 'last_user_name';
  static const String _lastUserIdKey = 'last_user_id';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _uidKey = 'user_uid';
  static const String _custNameKey = 'user_cust_name';
  static const String _rolesKey = 'user_roles';
  static const String _deviceIdKey = 'device_id';

  final LocalAuthentication _localAuth = LocalAuthentication();

  String? _accessToken;
  String? _refreshToken;
  bool _storyShown = false;
  String? _lastUserName;
  String? _lastUserId;
  bool _isBiometricEnabled = false;
  String? _uid;
  String? _custName;
  Map<String, String> _roles = {};
  String? _deviceId;

  String? get accessToken => _accessToken;
  bool get hasShownStory => _storyShown;
  bool get hasSavedUser => _lastUserId != null;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String? get uid => _uid;
  String? get custName => _custName;
  Map<String, String> get roles => _roles;
  String? get deviceId => _deviceId;

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
    _uid = prefs.getString(_uidKey);
    _custName = prefs.getString(_custNameKey);

    final rolesJson = prefs.getString(_rolesKey);
    if (rolesJson != null) {
      _roles = Map<String, String>.from(jsonDecode(rolesJson));
    }

    // DeviceId: FCM token ашиглана (main.dart-аас setDeviceId дуудна)
    _deviceId = prefs.getString(_deviceIdKey);
  }

  /// FCM token-г deviceId болгож хадгалах
  /// Firebase init хийсний дараа main()-аас дуудна
  Future<void> setDeviceId(String fcmToken) async {
    _deviceId = fcmToken;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_deviceIdKey, fcmToken);
    debugPrint(
      '[Auth] DeviceId set to FCM token: ${fcmToken.substring(0, 20)}...',
    );
  }

  /// FCM token-г серверт бүртгэх (login амжилттай болсны дараа дуудна)
  /// Сервер энэ token-г push notification илгээхэд ашиглана
  Future<void> registerFcmToken() async {
    if (_deviceId == null || _accessToken == null) return;

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
        ),
      );

      await dio.post(
        ApiConfig.registerFcmToken,
        data: {
          'api': 'register_fcm_token',
          'data': {'fcmToken': _deviceId, 'platform': _getPlatform()},
        },
      );
      debugPrint('[Auth] FCM token серверт бүртгэгдлээ');
    } catch (e) {
      debugPrint('[Auth] FCM token бүртгэхэд алдаа: $e');
    }
  }

  String _getPlatform() {
    if (identical(0, 0.0)) return 'web'; // dart2js check
    return 'mobile';
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    _isBiometricEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
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

  /// JWT token-ий payload хэсгийг decode хийнэ (base64)
  Map<String, dynamic>? _decodeJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // base64url → base64 padding нэмэх
      String payload = parts[1];
      final remainder = payload.length % 4;
      if (remainder == 2) {
        payload += '==';
      } else if (remainder == 3) {
        payload += '=';
      }

      final decoded = utf8.decode(base64Url.decode(payload));
      return jsonDecode(decoded) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Token-оос uid, custName, roles задлан авч SharedPreferences-д хадгална
  Future<void> _saveUserInfoFromToken(String token) async {
    final payload = _decodeJwtPayload(token);
    if (payload == null) return;

    final prefs = await SharedPreferences.getInstance();

    // uid
    if (payload.containsKey('uid')) {
      _uid = payload['uid'] as String;
      await prefs.setString(_uidKey, _uid!);
    }

    // custName
    if (payload.containsKey('custName')) {
      _custName = payload['custName'] as String;
      await prefs.setString(_custNameKey, _custName!);
    }

    // roles
    if (payload.containsKey('roles') && payload['roles'] is Map) {
      _roles = Map<String, String>.from(payload['roles']);
      await prefs.setString(_rolesKey, jsonEncode(_roles));
    }
  }

  // ┌──────────────────────────────────────────────────────┐
  // │  MOCK MODE — туршилтын mock response                │
  // │  Бодит API холбоход энийг false болго               │
  // └──────────────────────────────────────────────────────┘
  static const bool _useMock = true;

  /// DioException-с алдааны мессеж задлах (data нь String эсвэл Map байж болно)
  String _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      return data['message']?.toString() ?? e.message ?? 'Network error';
    }
    return e.message ?? 'Network error';
  }

  Dio get _dio => Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Authentication header-тай Dio (`Authorization: Bearer <token>`).
  /// Нэвтэрсэн хэрэглэгчийн API дуудлагуудад ашиглана.
  Dio get _authedDio => Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
    ),
  );

  /// Хариунаас token задлан хадгалах (login, biometric, OTP verify-д ашиглана)
  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final String accessToken = data['token'];
    final String refreshToken = data['refreshToken'] ?? '';

    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await _saveUserInfoFromToken(accessToken);

    if (_custName != null && _uid != null) {
      await saveLastUser(_custName!, _uid!);
    }

    // Login амжилттай → FCM token серверт бүртгэх
    registerFcmToken();
  }

  /// Нэвтрэх — deviceId илгээнэ.
  /// deviceId бүртгэлтэй → шууд token буцаана (success: true)
  /// deviceId бүртгэлгүй → OTP шаардана (requiresOtp: true, sessionId)
  Future<LoginResult> login(String userName, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'api': 'login',
          'userName': userName,
          'userPass': password,
          'deviceId': _deviceId ?? '1234562',
        },
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final String code = body['code']?.toString() ?? '';

        // code "0" → deviceId бүртгэлтэй, шууд нэвтэрсэн
        if (code == '0') {
          await _handleAuthResponse(body['data']);
          return const LoginResult(success: true);
        }

        // code "2" → нэвтрэлт зөв, гэхдээ deviceId бүртгэлгүй → OTP шаардлагатай
        // data.sessionId авч verification_channels API дуудна
        if (code == '2') {
          final data = body['data'];
          return LoginResult(
            requiresOtp: true,
            sessionId: data is Map ? data['sessionId']?.toString() : null,
          );
        }

        // Бусад → алдаа (буруу нууц үг гэх мэт)
        return LoginResult(message: body['message'] ?? 'Login failed');
      }

      return const LoginResult(message: 'Login failed');
    } catch (e) {
      if (e is DioException) {
        return LoginResult(message: 'Network error: ${e.message}');
      }
      return LoginResult(message: e.toString());
    }
  }

  /// Биометрик нэвтрэлт — deviceId + uid ашиглана.
  /// Зөвхөн deviceId бүртгэлтэй үед ажиллана.
  Future<LoginResult> biometricLogin() async {
    if (_uid == null) {
      return const LoginResult(message: 'No saved user');
    }

    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'api': 'biometric_login',
          'deviceId': _deviceId ?? '123456',
          'uid': _uid,
        },
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final String code = body['code']?.toString() ?? '';

        if (code == '0') {
          await _handleAuthResponse(body['data']);
          return const LoginResult(success: true);
        }

        return LoginResult(
          message: body['message'] ?? 'Biometric login failed',
        );
      }

      return const LoginResult(message: 'Biometric login failed');
    } catch (e) {
      if (e is DioException) {
        return LoginResult(message: 'Network error: ${e.message}');
      }
      return LoginResult(message: e.toString());
    }
  }

  /// OTP баталгаажсны дараа deviceId бүртгэх.
  /// sessionId нь login-с буцсан sessionId.
  Future<LoginResult> registerDevice(String sessionId) async {
    // ── MOCK ──
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      // Mock token хадгалах
      await saveTokens(
        accessToken:
            'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
        refreshToken: 'mock-refresh-token',
      );
      _uid = 'mock-uid-001';
      _custName = 'Тэст Хэрэглэгч';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_uidKey, _uid!);
      await prefs.setString(_custNameKey, _custName!);
      await saveLastUser(_custName!, _uid!);
      return const LoginResult(success: true);
    }
    // ── END MOCK ──

    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'api': 'register_device',
          'sessionId': sessionId,
          'deviceId': _deviceId ?? '123456',
        },
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final String code = body['code']?.toString() ?? '';

        if (code == '0') {
          await _handleAuthResponse(body['data']);
          return const LoginResult(success: true);
        }

        return LoginResult(
          message: body['message'] ?? 'Device registration failed',
        );
      }

      return const LoginResult(message: 'Device registration failed');
    } catch (e) {
      if (e is DioException) {
        return LoginResult(message: 'Network error: ${e.message}');
      }
      return LoginResult(message: e.toString());
    }
  }

  /// Бүртгэл эхлүүлэх — регистр + утас + овог + нэр илгээж OTP авна.
  /// Хариу: { success, msg, custId, sessionId, otp (test only) }
  /// Throws: бүртгэлтэй харилцагч (400) эсвэл бусад алдаа үед Exception
  Future<Map<String, dynamic>> registerInitiate({
    required String registerNumber,
    required String phone,
    required String lastName,
    required String firstName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerInitiate,
        data: {
          'api': 'register_initiate',
          'data': {
            'registerNumber': registerNumber,
            'phone': phone,
            'lastName': lastName,
            'firstName': firstName,
          },
        },
      );

      final body = response.data as Map<String, dynamic>;
      final code = body['code']?.toString() ?? '';
      final data = body['data'];

      if (code == '0' && data is Map && data['success'] == true) {
        final dataResult = await sendOtp(data['sessionId'], 'sms');
        return Map<String, dynamic>.from(dataResult);
      }

      // Сервер код 0 биш, эсвэл data.success != true → алдааны мессеж
      final msg =
          (data is Map ? data['msg']?.toString() : null) ??
          body['message']?.toString() ??
          'Бүртгэл амжилтгүй боллоо';
      throw Exception(msg);
    } on DioException catch (e) {
      // 400 → бүртгэлтэй харилцагч; сервер msg илгээдэг
      final data = e.response?.data;
      if (data is Map) {
        final msg =
            data['message']?.toString() ??
            (data['data'] is Map ? data['data']['msg']?.toString() : null);
        if (msg != null && msg.isNotEmpty) {
          throw Exception(msg);
        }
      }
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Бүртгэлийн нууц үг үүсгэх — sessionId + шинэ нууц үг.
  /// register_initiate → OTP verify-ийн дараах алхам.
  /// Returns: server message
  Future<String> setPassword({
    required String sessionId,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerSetPassword,
        data: {
          'api': 'set_password',
          'data': {
            'sessionId': sessionId,
            'password': password,
            'confirmPassword': confirmPassword,
          },
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ?? 'Нууц үг амжилттай үүсгэгдлээ';
      }
      throw Exception(body['message'] ?? 'Нууц үг үүсгэхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Бүртгэлийн орлого авах данс холбох — sessionId + банк + IBAN + нэр.
  /// Returns: server message
  Future<String> addAccount({
    required String sessionId,
    required String bankCode,
    required String iban,
    required String accountName,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerAddAccount,
        data: {
          'api': 'add_account',
          'data': {
            'sessionId': sessionId,
            'bankCode': bankCode,
            'iban': iban,
            'accountName': accountName,
          },
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ??
            'Дансны мэдээлэл амжилттай хадгалагдлаа';
      }
      throw Exception(body['message'] ?? 'Данс холбоход алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Нууц үг сэргээх (forgot_password урсгалын төгсгөл).
  /// sessionId-г /auth/forgot_password → verify_otp-оор баталгаажсан байх ёстой.
  Future<String> resetPassword({
    required String sessionId,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.registerReset,
        data: {
          'api': 'reset',
          'data': {
            'sessionId': sessionId,
            'password': password,
            'confirmPassword': confirmPassword,
          },
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ?? 'Нууц үг амжилттай үүсгэгдлээ';
      }
      throw Exception(body['message'] ?? 'Нууц үг сэргээхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Банкны жагсаалт татах. Хариу: список (банк бүр Map).
  Future<List<Map<String, dynamic>>> getBanksList() async {
    try {
      final response = await _dio.get(ApiConfig.banksList);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .map((b) => Map<String, dynamic>.from(b as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Нэвтэрсэн хэрэглэгчийн дэлгэрэнгүй мэдээлэл (uid, нэр, имэйл, утас, ...).
  /// `Authorization: Bearer <token>` шаардана.
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final response = await _authedDio.get(ApiConfig.userInfo);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
      throw Exception(body['message'] ?? 'Failed to fetch user info');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Нэвтэрсэн хэрэглэгчийн бүртгэлтэй төхөөрөмжүүд.
  /// `Authorization: Bearer <token>` шаардана.
  Future<List<Map<String, dynamic>>> getDevices() async {
    try {
      final response = await _authedDio.get(ApiConfig.devices);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// PEP (Politically Exposed Person) төлөв илгээх.
  /// `Authorization: Bearer <token>` шаардана.
  Future<String> setPepStatus(bool isPep) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.pepStatus,
        data: {
          'api': 'pep_status',
          'data': {'isPep': isPep.toString()},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ?? 'PEP төлөв хадгалагдлаа';
      }
      throw Exception(body['message'] ?? 'PEP төлөв илгээхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Нууц үг солих — хуучин, шинэ, давтан нууц үг
  Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          },
        ),
      );

      final response = await dio.post(
        ApiConfig.changePassword,
        data: {
          'api': 'change_password',
          'data': {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            'confirmPassword': confirmPassword,
          },
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Баталгаажуулах суваг авах (SMS, Email) — sessionId ашиглана
  Future<List<Map<String, dynamic>>> getVerificationChannels(
    String sessionId,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.verificationChannels,
        queryParameters: {
          'sessionId': sessionId,
          'api': 'verification_channels',
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        final channels = body['data']['channels'] as List;
        return channels.map((c) => Map<String, dynamic>.from(c)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// OTP код илгээх — sessionId + channel (sms | email)
  Future<Map<String, dynamic>> sendOtp(String sessionId, String channel) async {
    try {
      final response = await _dio.post(
        ApiConfig.sendOtp,
        data: {
          'api': 'send_otp',
          'data': {'sessionId': sessionId, 'channel': channel},
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['data'] as Map<String, dynamic>;
      }
      throw Exception(body['message'] ?? 'OTP send failed');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// OTP код шалгах — sessionId + otpCode
  /// Амжилттай бол deviceId буцаана
  Future<Map<String, dynamic>> verifyOtp(
    String sessionId,
    String otpCode,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.verifyOtp,
        data: {
          'api': 'verify_otp',
          'data': {'sessionId': sessionId, 'otpCode': otpCode},
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['data'] as Map<String, dynamic>;
      }
      throw Exception(body['message'] ?? 'OTP verification failed');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Нууц үг мартсан — регистрийн дугаар + утас илгээж sessionId + сувгууд авна.
  /// Returns: { sessionId, otp (test only), channels: [{type, value}, ...] }
  Future<Map<String, dynamic>> forgotPassword({
    required String registerNumber,
    required String phone,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.forgotPassword,
        data: {
          'api': 'forgot_password',
          'data': {'registerNumber': registerNumber, 'phone': phone},
        },
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
      throw Exception(body['message'] ?? 'Харилцагч олдсонгүй');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
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
    _uid = null;
    _custName = null;
    _roles = {};

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_custNameKey);
    await prefs.remove(_rolesKey);
  }

  bool get isAuthenticated => _accessToken != null;

  bool _isRefreshing = false;

  /// Token expire болсон үед refresh token ашиглан шинэ token авна.
  /// Амжилттай бол шинэ access token буцаана, амжилтгүй бол null.
  Future<String?> refreshAccessToken() async {
    if (_refreshToken == null || _isRefreshing) return null;

    _isRefreshing = true;
    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          headers: {
            'Content-Type': 'application/json',
            if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
          },
        ),
      );

      final response = await dio.post(
        ApiConfig.login,
        data: {'api': 'refresh', 'refreshToken': _refreshToken},
      );

      if (response.statusCode == 200) {
        final body = response.data;
        final String code = body['code']?.toString() ?? '';

        if (code != '0') return null;

        final data = body['data'];
        final String newAccessToken = data['token'];
        final String newRefreshToken = data['refreshToken'] ?? _refreshToken!;

        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        // Шинэ token доторх хэрэглэгчийн мэдээллийг шинэчлэх
        await _saveUserInfoFromToken(newAccessToken);

        return newAccessToken;
      }
    } catch (_) {
      return null;
    } finally {
      _isRefreshing = false;
    }
    return null;
  }
}
