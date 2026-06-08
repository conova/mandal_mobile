import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
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
  static const String _fallbackDeviceIdKey = 'fallback_device_id';
  static const String _userInfoKey = 'user_info';
  static const String _watchlistOrderKey = 'watchlist_order';

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
  String? _fallbackDeviceId;
  String _manufacturer = '';
  Map<String, dynamic>? _userInfo;

  String? get accessToken => _accessToken;
  bool get hasShownStory => _storyShown;
  bool get hasSavedUser => _lastUserId != null;
  bool get isBiometricEnabled => _isBiometricEnabled;
  String? get uid => _uid;
  String? get custName => _custName;
  Map<String, String> get roles => _roles;
  String? get deviceId => _deviceId;

  /// Нэвтэрсэн хэрэглэгчийн дэлгэрэнгүй мэдээлэл (lastName, firstName,
  /// registerNumber, email, phone, address г.м.). Login амжилттай болоход
  /// автоматаар татаж кэшэлнэ. App дахин нээхэд SharedPreferences-аас
  /// уншина.
  Map<String, dynamic>? get userInfo => _userInfo;

  // ── KYC + verification helpers ─────────────────────────────────────────
  // Сервэр нь boolean утгуудыг "true" / "false" string-аар буцаадаг учир
  // _parseBool() helper ашиглана.

  bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    if (v is num) return v != 0;
    return false;
  }

  Map<String, dynamic>? get _kyc =>
      _userInfo == null ? null : _userInfo!['kyc'] as Map<String, dynamic>?;

  /// Үнэт цаасны гэрээ зурсан эсэх
  bool get hasAgreement => _parseBool(_kyc?['agreement']);

  /// DAN баталгаажуулалт хийгдсэн эсэх
  bool get isDanVerified => _parseBool(_kyc?['dan']);

  /// PEP төлөв тодорхойлсон эсэх
  bool get isPepDeclared => _parseBool(_kyc?['ispep']);

  /// 3 алхмын хэдийг гүйцэтгэсэнг 0.0..1.0 хязгаарт буцаана
  double get kycProgress {
    if (_kyc == null) return 0.0;
    final done = [
      hasAgreement,
      isDanVerified,
      isPepDeclared,
    ].where((b) => b).length;
    return done / 3;
  }

  /// Бүх KYC алхам гүйцэтгэсэн эсэх
  bool get isKycComplete => hasAgreement && isDanVerified && isPepDeclared;

  // ── Document upload статус ────────────────────────────────────────────
  // `userInfo.document` объект — `kyc`-ийн гадна, тусдаа irне.
  // Жишээ: { idFront: "true", idBack: "true", selfie: "false" }
  Map<String, dynamic>? get _document => _userInfo == null
      ? null
      : _userInfo!['document'] as Map<String, dynamic>?;

  /// Иргэний үнэмлэхний урд талын зураг илгээсэн эсэх
  bool get isIdFrontUploaded => _parseBool(_document?['idFront']);

  /// Иргэний үнэмлэхний ар талын зураг илгээсэн эсэх
  bool get isIdBackUploaded => _parseBool(_document?['idBack']);

  /// Selfie зураг илгээсэн эсэх
  bool get isSelfieUploaded => _parseBool(_document?['selfie']);

  /// 3 баримтын аль аль нь илгээгдсэн эсэх
  bool get areAllDocumentsUploaded =>
      isIdFrontUploaded && isIdBackUploaded && isSelfieUploaded;

  /// Утас баталгаажуулсан эсэх
  bool get isPhoneVerified => _parseBool(_userInfo?['phoneVerified']);

  /// Имэйл баталгаажуулсан эсэх
  bool get isEmailVerified => _parseBool(_userInfo?['emailVerified']);

  /// Хэрэглэгчийн статусын нэр (Идэвхтэй / Идэвхгүй г.м.)
  String? get statusName => _userInfo?['statusName'] as String?;

  /// Login API-д илгээх deviceId. FCM token байгаа бол түүнийг, үгүй бол
  /// төхөөрөмж тус бүрд анх ажиллахад үүсгэсэн UUID-г буцаана. Энэ нь
  /// hardcoded fallback-аас зайлсхийж, төхөөрөмж бүр өвөрмөц утгатай байхыг
  /// баталгаажуулна.
  String get effectiveDeviceId => _deviceId ?? _fallbackDeviceId ?? 'unknown';

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

    final userInfoJson = prefs.getString(_userInfoKey);
    if (userInfoJson != null) {
      _userInfo = Map<String, dynamic>.from(jsonDecode(userInfoJson));
    }

    // DeviceId: FCM token ашиглана (main.dart-аас setDeviceId дуудна)
    _deviceId = prefs.getString(_deviceIdKey);

    // Fallback deviceId: FCM-гүй төхөөрөмжид зориулсан UUID v4 (анх 1 удаа үүсгэж
    // байнгын хадгална). Login дуудлагууд `effectiveDeviceId`-г ашиглана.
    _fallbackDeviceId = prefs.getString(_fallbackDeviceIdKey);
    if (_fallbackDeviceId == null) {
      _fallbackDeviceId = _generateUuidV4();
      await prefs.setString(_fallbackDeviceIdKey, _fallbackDeviceId!);
      debugPrint('[Auth] Generated fallback deviceId: $_fallbackDeviceId');
    }

    // Төхөөрөмжийн ялгаагч нэр (login API-ийн `manufacturer` талбарт илгээх).
    // Жишээ: "Samsung SM-S928B", "iPhone iPhone17,1", "Chrome 147"
    _manufacturer = await _detectManufacturer();
    debugPrint('[Auth] Manufacturer: $_manufacturer');
  }

  /// Платформ тус бүрд харгалзах хүн уншихад тааруу нэр буцаана.
  /// Алдаа гарвал хоосон string буцаана (login зогсохгүй).
  Future<String> _detectManufacturer() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (kIsWeb) {
        final web = await deviceInfo.webBrowserInfo;
        final name = web.browserName.name; // "chrome", "safari", ...
        return '${_capitalize(name)} ${web.appVersion ?? ''}'.trim();
      }
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          final a = await deviceInfo.androidInfo;
          // manufacturer = "samsung", model = "SM-S928B" → "Samsung SM-S928B"
          return '${_capitalize(a.manufacturer)} ${a.model}'.trim();
        case TargetPlatform.iOS:
          final i = await deviceInfo.iosInfo;
          // utsname.machine = "iPhone17,1" — серверт марк/моделод mapping хийнэ
          final machine = i.utsname.machine;
          return '${i.model} $machine'.trim();
        case TargetPlatform.windows:
          final w = await deviceInfo.windowsInfo;
          return '${w.computerName} (Windows)';
        case TargetPlatform.macOS:
          final m = await deviceInfo.macOsInfo;
          return '${m.model} (macOS)';
        case TargetPlatform.linux:
          final l = await deviceInfo.linuxInfo;
          return '${l.prettyName} (Linux)';
        default:
          return 'Unknown';
      }
    } catch (e) {
      debugPrint('[Auth] Manufacturer detect алдаа: $e');
      return '';
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }

  /// UUID v4 (random) үүсгэх. Сэтгэл алддаггүй хувийн санамсаргүй тооноос.
  /// Жишээ: `f47ac10b-58cc-4372-a567-0e02b2c3d479`
  String _generateUuidV4() {
    final rng = Random.secure();
    final bytes = List<int>.generate(16, (_) => rng.nextInt(256));
    // RFC 4122 v4: байт 6-ын дээд 4 бит = 0100, байт 8-ын дээд 2 бит = 10
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20, 32)}';
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
  static const bool _useMock = false;

  /// Login дуудлагын mock хувилбар.
  ///   - true  → server: code "2" (deviceId бүртгэлгүй → "Шинэ төхөөрөмж"
  ///                                 screen + OTP flow)
  ///   - false → server: code "0" (шууд success, token буцаасан мэт)
  /// `_useMock = true` үед л үйлчилнэ.
  static const bool _mockNewDevice = false;

  /// Login flow-н mock-д ашиглах хуурамч хэрэглэгч.
  static const String _mockUid = 'mock-uid-001';
  static const String _mockCustName = 'Тэст Хэрэглэгч';

  /// Mock login (deviceId бүртгэлтэй → success). registerDevice болон
  /// biometricLogin-ийн хооронд хуваалцаж ашиглана.
  Future<LoginResult> _mockLoginSuccess() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await saveTokens(
      accessToken: 'mock-access-token-${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: 'mock-refresh-token',
    );
    _uid = _mockUid;
    _custName = _mockCustName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_uidKey, _uid!);
    await prefs.setString(_custNameKey, _custName!);
    await saveLastUser(_custName!, _uid!);
    // Default mock userInfo (KYC аль хэдийн дууссан хувилбар)
    _userInfo = {
      'uid': _mockUid,
      'lastName': 'Тэст',
      'firstName': 'Хэрэглэгч',
      'registerNumber': 'РД 0000000',
      'email': 'test@mock.mn',
      'emailVerified': true,
      'phone': '99000000',
      'phoneVerified': true,
      'address': null,
      'statusName': 'Идэвхтэй',
      'kyc': {'agreement': 'true', 'dan': 'true', 'ispep': 'true'},
      'document': {'idFront': 'true', 'idBack': 'true', 'selfie': 'true'},
    };
    await prefs.setString(_userInfoKey, jsonEncode(_userInfo));
    notifyListeners();
    return const LoginResult(success: true);
  }

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

    // Өмнөх saved user-ийг шинэ нэвтрэлтийн өмнө цээжлэх (saveLastUser нь
    // _lastUserId-г дарж бичих учир)
    final previousUserId = _lastUserId;

    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await _saveUserInfoFromToken(accessToken);

    // Шинэ хэрэглэгч өөр (өмнөх биометрик идэвхжсэн user-ийнх биш) бол
    // биометрик тохиргоог автоматаар унтрааж аюулгүй болгоно.
    if (previousUserId != null &&
        _uid != null &&
        previousUserId != _uid &&
        _isBiometricEnabled) {
      await setBiometricEnabled(false);
      debugPrint('[Auth] Биометрик тохиргоо унтраав ($previousUserId → $_uid)');
    }

    if (_custName != null && _uid != null) {
      await saveLastUser(_custName!, _uid!);
    }

    // Login амжилттай → FCM token серверт бүртгэх
    registerFcmToken();

    // Хэрэглэгчийн дэлгэрэнгүй мэдээллийг татаж кэшэлнэ
    // (нэвтрэх процессыг хойшлуулахгүйн тулд async асаав)
    refreshUserInfo();
  }

  /// `/user/info` API-аас хэрэглэгчийн мэдээлэл татаж кэш + persistence
  /// шинэчилнэ. Алдаа гарвал чимээгүй (хуучин cache үлддэг).
  /// Login + my_info screen-аас дуудаж болно.
  Future<Map<String, dynamic>?> refreshUserInfo() async {
    try {
      final info = await getUserInfo();
      _userInfo = info;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userInfoKey, jsonEncode(info));
      notifyListeners();
      return info;
    } catch (e) {
      debugPrint('[Auth] refreshUserInfo алдаа: $e');
      return null;
    }
  }

  /// Нэвтрэх — deviceId илгээнэ.
  /// deviceId бүртгэлтэй → шууд token буцаана (success: true)
  /// deviceId бүртгэлгүй → OTP шаардана (requiresOtp: true, sessionId)
  Future<LoginResult> login(String userName, String password) async {
    // ── MOCK ──
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 600));
      // 1) Хоосон оролттой бол алдаа
      if (userName.trim().isEmpty || password.isEmpty) {
        return const LoginResult(message: 'Утас/нууц үг хоосон байна');
      }
      // 2) "wrong" нууц үг өгсөн бол алдаа (UX тестлэхэд хэрэгтэй)
      if (password == 'wrong') {
        return const LoginResult(message: 'Нэвтрэх нэр эсвэл нууц үг буруу');
      }
      // 3) Default scenario
      if (_mockNewDevice) {
        // code "2" — "Шинэ төхөөрөмж" intro + OTP flow
        return LoginResult(
          requiresOtp: true,
          sessionId: 'mock-session-${DateTime.now().millisecondsSinceEpoch}',
        );
      }
      // code "0" — шууд амжилттай
      return _mockLoginSuccess();
    }
    // ── END MOCK ──

    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'api': 'login',
          'userName': userName,
          'userPass': password,
          'deviceId': effectiveDeviceId,
          'manufacturer': _manufacturer,
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
    // Logout-ын дараа _uid цэвэрлэгдэх боловч _lastUserId үлдэнэ.
    // Quick login дэлгэцэд биометрикээр нэвтрэхэд энийг ашиглана.
    final uidToUse = _uid ?? _lastUserId;
    if (uidToUse == null) {
      return const LoginResult(message: 'No saved user');
    }

    // ── MOCK ──
    // Биометрик нэвтрэлт нь deviceId бүртгэлтэй хэрэглэгчид зориулагдсан тул
    // mock үед үргэлж success ажиллана ("Шинэ төхөөрөмж" flow орохгүй).
    if (_useMock) {
      return _mockLoginSuccess();
    }
    // ── END MOCK ──

    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'api': 'biometric_login',
          'deviceId': effectiveDeviceId,
          'uid': uidToUse,
          'manufacturer': _manufacturer,
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
    // OTP амжилттай → token буцаагдсан мэтээр хадгална.
    if (_useMock) {
      return _mockLoginSuccess();
    }
    // ── END MOCK ──

    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'api': 'register_device',
          'sessionId': sessionId,
          'deviceId': effectiveDeviceId,
          'manufacturer': _manufacturer,
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
            'deviceId': effectiveDeviceId,
            'manufacturer': _manufacturer,
          },
        },
      );

      final body = response.data as Map<String, dynamic>;
      final code = body['code']?.toString() ?? '';
      final data = body['data'];

      if (code == '0' && data is Map && data['success'] == true) {
        return Map<String, dynamic>.from(data);
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
  /// Данс холбох — sessionId эсвэл нэвтэрсэн token хоёрын аль нэгийг шаардана.
  ///   • sessionId дамжуулсан → register flow (нэвтрээгүй)
  ///   • sessionId null → нэвтэрсэн → Bearer token автомат явна
  Future<String> addAccount({
    String? sessionId,
    required String bankCode,
    required String iban,
    required String accountName,
  }) async {
    final dio = sessionId != null ? _dio : _authedDio;
    try {
      final response = await dio.post(
        ApiConfig.registerAddAccount,
        data: {
          'api': 'add_account',
          'data': {
            if (sessionId != null) 'sessionId': sessionId,
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

  /// KYC: бичиг баримтын зураг илгээх
  /// type: id_front | id_back | selfie г.м.
  /// image: base64 encoded string
  Future<String> uploadKycDocument({
    required String type,
    required String image,
  }) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.kycUploadDocument,
        data: {
          'api': 'upload_document',
          'data': {'type': type, 'image': image},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        // Кэшэлсэн userInfo дотрох document талбарыг шинэчлэх
        if (_userInfo != null) {
          final doc = Map<String, dynamic>.from(
            (_userInfo!['document'] as Map?) ?? const {},
          );
          doc[type] = 'true';
          _userInfo!['document'] = doc;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userInfoKey, jsonEncode(_userInfo));
          notifyListeners();
        }
        return body['message']?.toString() ?? 'Амжилттай илгээгдлээ';
      }
      throw Exception(body['message'] ?? 'Бичиг баримт илгээхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// KYC: үнэт цаасны гэрээ зөвшөөрөх
  Future<String> acceptKycAgreement() async {
    try {
      final response = await _authedDio.post(
        ApiConfig.kycAcceptAgreement,
        data: {
          'api': 'accept_agreement',
          'data': {'isAgreement': 'true'},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        // Кэшэлсэн userInfo дотрох kyc.agreement шинэчлэх
        if (_userInfo != null) {
          final kyc = Map<String, dynamic>.from(
            (_userInfo!['kyc'] as Map?) ?? const {},
          );
          kyc['agreement'] = 'true';
          _userInfo!['kyc'] = kyc;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userInfoKey, jsonEncode(_userInfo));
          notifyListeners();
        }
        return body['message']?.toString() ?? 'Гэрээ амжилттай зөвшөөрөгдлөө';
      }
      throw Exception(body['message'] ?? 'Гэрээ зөвшөөрөхөд алдаа гарлаа');
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
    // ── MOCK ──
    // Login mock-ийн дараа `_userInfo` хадгалагдсан байна — түүгээр буцаана.
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 200));
      return _userInfo ?? const {};
    }
    // ── END MOCK ──

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

  /// Watchlist — хэрэглэгчийн хадгалсан хувьцаа авна.
  /// `Authorization: Bearer <token>` шаардана.
  /// Локалд хадгалагдсан дарааллыг автоматаар хэрэглэнэ.
  Future<List<Map<String, dynamic>>> getWatchlist() async {
    try {
      final response = await _authedDio.get(ApiConfig.watchlistList);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        final raw = (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
        final order = await getSavedWatchlistOrder();
        return sortWatchlistByOrder(raw, order);
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Хэрэглэгчийн өөрчилсөн дарааллыг локалд хадгалах
  Future<void> saveWatchlistOrder(List<String> symbols) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_watchlistOrderKey, symbols);
  }

  /// Локалд хадгалагдсан watchlist-ийн дараалал (хоосон бол [])
  Future<List<String>> getSavedWatchlistOrder() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_watchlistOrderKey) ?? const [];
  }

  /// API-аас ирсэн жагсаалтыг хадгалагдсан дарааллаар sort хийнэ.
  /// Дарааллд байгаа SYMBOL-ууд эхлээд (хадгалсан index-ийн дагуу),
  /// үлдсэн нь араас (API-ийн анхдагч дарааллаар).
  static List<Map<String, dynamic>> sortWatchlistByOrder(
    List<Map<String, dynamic>> items,
    List<String> savedOrder,
  ) {
    if (savedOrder.isEmpty) return items;
    final indexOf = {
      for (var i = 0; i < savedOrder.length; i++) savedOrder[i]: i,
    };
    final sorted = [...items];
    sorted.sort((a, b) {
      final symA = a['SYMBOL']?.toString() ?? '';
      final symB = b['SYMBOL']?.toString() ?? '';
      final ia = indexOf[symA] ?? 1 << 30; // байхгүй бол хамгийн сүүлд
      final ib = indexOf[symB] ?? 1 << 30;
      return ia.compareTo(ib);
    });
    return sorted;
  }

  /// Stock list-ийн ерөнхий уншигч — GET <path>, `data` array буцаана.
  Future<List<Map<String, dynamic>>> _fetchStockList(String path) async {
    try {
      final response = await _authedDio.get(path);
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

  /// Өсөлттэй хувьцаанууд
  Future<List<Map<String, dynamic>>> getGainers() =>
      _fetchStockList(ApiConfig.stocksGainers);

  /// Уналттай хувьцаанууд
  Future<List<Map<String, dynamic>>> getLosers() =>
      _fetchStockList(ApiConfig.stocksLosers);

  /// IPO хувьцаанууд
  Future<List<Map<String, dynamic>>> getIpoStocks() =>
      _fetchStockList(ApiConfig.stocksIpo);

  /// Хувьцаа хайх
  /// POST /stocks/search?q=...&type=...
  /// type: optional (gainers | losers | ipo)
  Future<List<Map<String, dynamic>>> searchStocks(
    String query, {
    String? type,
  }) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.stocksSearch,
        queryParameters: {'q': query, if (type != null) 'type': type},
      );
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

  /// Хувьцааны үнийн график
  /// POST /stocks/{SYMBOL}/chart?start=YYYY/MM/DD&end=YYYY/MM/DD
  /// Default: сүүлийн 1 жил
  Future<List<Map<String, dynamic>>> getStockChart(
    String symbol, {
    String? start,
    String? end,
  }) async {
    final now = DateTime.now();
    final s =
        start ?? _formatChartDate(DateTime(now.year - 1, now.month, now.day));
    final e = end ?? _formatChartDate(now);

    try {
      final response = await _authedDio.post(
        ApiConfig.stockChart(symbol),
        queryParameters: {'start': s, 'end': e},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }
      return [];
    } on DioException catch (err) {
      throw Exception(_extractErrorMessage(err));
    }
  }

  String _formatChartDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.day.toString().padLeft(2, '0')}';

  // ─── Portfolio ───────────────────────────────────────────────────────

  /// Нийт хөрөнгийн товч мэдээлэл.
  /// GET /portfolio/summary
  /// Response: { totalAssets, totalChange, changePercent, cashBalance }
  Future<PortfolioSummary> getPortfolioSummary() async {
    try {
      final response = await _authedDio.get(ApiConfig.portfolioSummary);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() != '0') {
        throw Exception(
          body['message']?.toString() ?? 'Portfolio summary алдаа',
        );
      }
      final data = (body['data'] as Map?) ?? const {};
      double toDouble(dynamic v) => v == null
          ? 0.0
          : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
      return PortfolioSummary(
        totalAssets: toDouble(data['totalAssets']),
        totalChange: toDouble(data['totalChange']),
        changePercent: toDouble(data['changePercent']),
        cashBalance: toDouble(data['cashBalance']),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Equity (нийт хөрөнгө) график.
  /// GET /portfolio/chart_data?period=1D|1W|1M|3M|1Y|ALL
  /// Default period: '1Y'
  /// Response: { points: [{date, value}], period }
  Future<EquityChart> getEquityChart({String period = '1Y'}) async {
    try {
      final response = await _authedDio.get(
        ApiConfig.portfolioChartData,
        queryParameters: {'period': period},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() != '0') {
        throw Exception(body['message']?.toString() ?? 'Chart data алдаа');
      }
      final data = (body['data'] as Map?) ?? const {};
      final rawPoints = (data['points'] as List?) ?? const [];
      final points = rawPoints
          .map((p) => EquityPoint.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
      return EquityChart(
        period: (data['period'] as String?) ?? period,
        points: points,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Хөрөнгийн хуваарилалт (asset breakdown).
  /// GET /portfolio/breakdown
  /// Response: `data: [{type, name, amount, count, ...}]`
  Future<List<Map<String, dynamic>>> getAssetBreakdown() async {
    try {
      final response = await _authedDio.get(ApiConfig.portfolioBreakdown);
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

  /// Watchlist-д нэмж болох бүх хувьцаа.
  /// GET /watchlist/available
  /// Row: { STOCKCODE, SYMBOL, STOCKNAME, COMPNAME, CLOSEPRICE, OPENPRICE,
  ///        STOCKTYPE, TYPENAME, BOARDNAME }
  /// `Authorization: Bearer <token>` шаардана.
  Future<List<Map<String, dynamic>>> getAvailableStocks() async {
    try {
      final response = await _authedDio.get(ApiConfig.watchlistAvailable);
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

  /// Watchlist-д хувьцаа нэмэх.
  /// POST /watchlist/{symbol}
  /// `Authorization: Bearer <token>` шаардана.
  Future<String> addToWatchlist(String symbol) async {
    try {
      final response = await _authedDio.post(ApiConfig.watchlistAdd(symbol));
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ?? 'Амжилттай нэмэгдлээ';
      }
      throw Exception(body['message'] ?? 'Watchlist нэмэхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Watchlist-аас хувьцаа устгах.
  /// POST /watchlist/{symbol}   body: { api: "watchlist_delete", data: { symbol } }
  /// `Authorization: Bearer <token>` шаардана.
  Future<String> removeFromWatchlist(String symbol) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.watchlistAdd(symbol),
        data: {
          'api': 'watchlist_delete',
          'data': {'symbol': symbol},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ?? 'Амжилттай устгагдлаа';
      }
      throw Exception(body['message'] ?? 'Watchlist устгахад алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Бүртгэлтэй төхөөрөмжийг устгах.
  /// POST /security/devices  body: { api: "devices_delete", data: { deviceId } }
  /// `Authorization: Bearer <token>` шаардана.
  Future<String> deleteDevice(String deviceId) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.devices,
        data: {
          'api': 'devices_delete',
          'data': {'deviceId': deviceId},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return body['message']?.toString() ?? 'Төхөөрөмж устгагдлаа';
      }
      throw Exception(body['message'] ?? 'Төхөөрөмж устгахад алдаа гарлаа');
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
    // ── MOCK ──
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      return const [
        {'type': 'sms', 'value': '*****0000'},
        {'type': 'email', 'value': 't***@mock.mn'},
      ];
    }
    // ── END MOCK ──

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

  /// OTP код илгээх — channel (sms | email).
  ///
  /// 2 горим:
  ///   1) **Нэвтэрсэн** (`_accessToken != null`) — `Authorization: Bearer`
  ///      header илгээж, body-д `sessionId` оруулахгүй. Сервер token-аас
  ///      хэрэглэгчийг таних.
  ///   2) **Нэвтрээгүй** — `sessionId` заавал шаардлагатай (forgot password,
  ///      register flow г.м.).
  Future<Map<String, dynamic>> sendOtp(
    String channel, {
    String? sessionId,
  }) async {
    // ── MOCK ──
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      // Mock дээр OTP код "1234" (UI testing-д бичих кодыг хялбарчлав)
      return {'sessionId': sessionId ?? 'mock-session', 'otp': '1234'};
    }
    // ── END MOCK ──

    try {
      final dio = isAuthenticated ? _authedDio : _dio;
      final Map<String, dynamic> bodyData = {'channel': channel};
      if (!isAuthenticated) {
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception(
            'sessionId шаардлагатай (нэвтэрсэн хэрэглэгч биш үед)',
          );
        }
        bodyData['sessionId'] = sessionId;
      }

      final response = await dio.post(
        ApiConfig.sendOtp,
        data: {'api': 'send_otp', 'data': bodyData},
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return (body['data'] as Map<String, dynamic>?) ?? {};
      }
      throw Exception(body['message'] ?? 'OTP send failed');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// OTP код шалгах — sessionId + otpCode.
  ///
  /// Амжилттай үеийн хариу 2 төрөл байна:
  ///   1) Device/Customer register: data.token + data.refreshToken — энэ үед
  ///      tokens-ыг хадгална + JWT-аас uid/custName-г decode хийж кэшэлнэ.
  ///   2) Forgot password (token буцахгүй) — зүгээр л data-ыг буцаана.
  Future<Map<String, dynamic>> verifyOtp(
    String sessionId,
    String otpCode,
  ) async {
    // ── MOCK ──
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      // "1234" → OK, бусад код → буруу
      if (otpCode != '1234') {
        throw Exception('OTP код буруу байна');
      }
      // Forgot password flow-д token буцаах шаардлагагүй — calling code өөрөө
      // дараагийн алхамд `registerDevice`-г дуудна.
      return {'sessionId': sessionId};
    }
    // ── END MOCK ──

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
        if (body['data'] is Map<String, dynamic>) {
          final data = (body['data'] as Map<String, dynamic>?) ?? {};
          // Token буцсан бол хэрэглэгчийг "нэвтэрсэн" болгож хадгална
          if (data['token'] is String) {
            await _handleAuthResponse(data);
          }
          return data;
        }
        return {};
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
          'data': {
            'registerNumber': registerNumber,
            'phone': phone,
            'deviceId': effectiveDeviceId,
            'manufacturer': _manufacturer,
          },
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
    _userInfo = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_uidKey);
    await prefs.remove(_custNameKey);
    await prefs.remove(_rolesKey);
    await prefs.remove(_userInfoKey);
  }

  bool get isAuthenticated => _accessToken != null;

  /// JWT `exp` claim-аас тооцоолж token хүчингүй болсон эсэхийг буцаана.
  /// `exp` байхгүй эсвэл задлахад алдаа гарвал false (expired биш гэж тооцно).
  ///
  /// Энэ нь зөвхөн төлвийг шалгана — refresh оролдохгүй. Splash flow болон
  /// бусад дуудлагуудын өмнө шалгахад зориулагдсан.
  bool _isTokenExpired(String? token) {
    if (token == null || token.isEmpty) return true;
    final payload = _decodeJwtPayload(token);
    if (payload == null) return false;
    final exp = payload['exp'];
    if (exp is! num) return false;
    final expSec = exp.toInt();
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowSec >= expSec;
  }

  /// Access token хугацаа дууссан эсэх (JWT `exp`-аас).
  bool get isAccessTokenExpired => _isTokenExpired(_accessToken);

  /// Refresh token бас хугацаа дууссан эсэх.
  bool get isRefreshTokenExpired => _isTokenExpired(_refreshToken);

  /// App нээх үед — token expired бол refresh оролдоно, амжилтгүй бол
  /// session-ыг бүрэн арилгана. Буцаах: хэрэглэгч нэвтэрсэн төлөвтэй эсэх
  /// (UI-н routing шийдэхэд ашиглана).
  ///
  /// • Token аль ч бус null + access valid → true (шууд нэвтэрсэн)
  /// • Access expired, refresh valid → refresh оролдох → амжилттай бол true
  /// • Хоёул хугацаа дууссан → clearSession + false
  Future<bool> ensureValidSession() async {
    if (_accessToken == null) return false;

    // Access still valid → just continue
    if (!isAccessTokenExpired) return true;

    // Access expired — refresh token-той бол сэргээх оролдох
    if (_refreshToken != null && !isRefreshTokenExpired) {
      final newToken = await refreshAccessToken();
      if (newToken != null) return true;
    }

    // Refresh бас амжилтгүй → session-ыг арилгах
    await clearSession();
    notifyListeners();
    return false;
  }

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

// ─── Portfolio data models ─────────────────────────────────────────────

/// Нийт хөрөнгийн товч мэдээлэл.
class PortfolioSummary {
  /// Нийт хөрөнгийн дүн (₮)
  final double totalAssets;

  /// Хугацааны туршид гарсан өөрчлөлт (₮)
  final double totalChange;

  /// Өөрчлөлт хувиар (%)
  final double changePercent;

  /// Чөлөөт мөнгөн үлдэгдэл (₮)
  final double cashBalance;

  const PortfolioSummary({
    required this.totalAssets,
    required this.totalChange,
    required this.changePercent,
    required this.cashBalance,
  });

  /// Хоосон summary — алдаа гарсан үеийн default.
  static const PortfolioSummary empty = PortfolioSummary(
    totalAssets: 0,
    totalChange: 0,
    changePercent: 0,
    cashBalance: 0,
  );
}

/// Equity графикийн нэг цэг.
class EquityPoint {
  final DateTime date;
  final double value;

  const EquityPoint({required this.date, required this.value});

  factory EquityPoint.fromJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString() ?? '';
    final v = json['value'];
    final value = v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    return EquityPoint(
      date: DateTime.tryParse(dateStr) ?? DateTime.now(),
      value: value,
    );
  }
}

/// Equity графикийн бүх цэгүүд + сонгосон period.
class EquityChart {
  /// '1D' | '1W' | '1M' | '3M' | '1Y' | 'ALL'
  final String period;
  final List<EquityPoint> points;

  const EquityChart({required this.period, required this.points});

  static const EquityChart empty = EquityChart(period: '1Y', points: []);
}
