import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform, debugPrint;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../common/api_message.dart';
import '../models/sub_account.dart';
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

  /// Одоо хийсэн буруу оролдлогын тоо
  final int? counter;

  /// Зөвшөөрөгдөх дээд оролдлогын тоо
  final int? attempt;

  /// Сүлжээ/техникийн алдаа эсэх — UI-д raw мессеж бус, ерөнхий
  /// мессеж (connectionError) харуулна.
  final bool isConnectionError;

  const LoginResult({
    this.success = false,
    this.requiresOtp = false,
    this.sessionId,
    this.message,
    this.counter,
    this.attempt,
    this.isConnectionError = false,
  });
}

class AuthService with ChangeNotifier {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _storyShownKey = 'story_shown';
  static const String _lastUserNameKey = 'last_user_name';
  static const String _lastUserIdKey = 'last_user_id';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _biometricUserKey = 'biometric_user_id';
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

  /// Биометрикийг идэвхжүүлсэн хэрэглэгчийн uid — өөр хэрэглэгч нэвтрэхэд
  /// тохиргоог автоматаар унтраахад ашиглана (logout _lastUserId-г
  /// цэвэрлэдэг тул тусад нь хадгална)
  String? _biometricUserId;
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

  /// Сервэр (PHP) хоосон объектыг `[]` буюу List болгож буцаадаг тул
  /// шууд cast хийхгүй — Map биш бол null.
  static Map<String, dynamic>? _asMap(dynamic v) =>
      v is Map ? Map<String, dynamic>.from(v) : null;

  Map<String, dynamic>? get _kyc => _asMap(_userInfo?['kyc']);

  /// Home дээр сонгогдсон хүүхдийн данс (null — өөрийн данс)
  SubAccount? _activeSubAccount;
  SubAccount? get activeSubAccount => _activeSubAccount;

  /// Профайл солих — auth/switch_profile API дуудаж шинэ token авна
  /// (хариу нь refresh_token-тэй ижил бүтэцтэй). [child] null бол
  /// өөрийн данс руу буцна. Өөрийн info кэшийг (нэр, subAcnts) хөндөхгүй.
  Future<void> switchProfile(SubAccount? child) async {
    final custId = child?.custId ?? _uid;
    if (custId == null || custId.isEmpty) {
      throw Exception('cust_id олдсонгүй');
    }
    try {
      final response = await _authedDio.post(
        ApiConfig.switchProfile,
        data: {
          'api': 'switch_profile',
          'data': {'cust_id': custId},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() != '0') {
        throw Exception(apiMessage(body) ?? 'Профайл солиход алдаа гарлаа');
      }
      final data = body['data'] as Map<String, dynamic>;
      await saveTokens(
        accessToken: data['token'],
        refreshToken: data['refreshToken'] ?? _refreshToken ?? '',
      );
      _activeSubAccount = child;
      notifyListeners();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Бүртгэлтэй хүүхдийн (дэд) данснууд — /user/info-ийн `subAcnts`
  List<SubAccount> get subAccounts {
    final raw = _userInfo?['subAcnts'];
    if (raw is! List) return const [];
    return SubAccount.listFromJson(raw);
  }

  /// Үнэт цаасны гэрээ зурсан эсэх
  bool get hasAgreement => _parseBool(_kyc?['agreement']);

  /// DAN баталгаажуулалт хийгдсэн эсэх
  bool get isDanVerified => _parseBool(_kyc?['dan']);

  /// PEP төлөв тодорхойлсон эсэх
  bool get isPepDeclared => _parseBool(_kyc?['ispep']);

  /// 3 алхмын хэдийг гүйцэтгэсэнг 0.0..1.0 хязгаарт буцаана.
  /// Баримтын алхам нь 3 зураг (id_front, id_back, selfie) бүгд true
  /// үед гүйцсэнд тооцогдоно.
  double get kycProgress {
    if (_kyc == null) return 0.0;
    final done = [
      hasAgreement,
      isDanVerified,
      areAllDocumentsUploaded,
    ].where((b) => b).length;
    return done / 3;
  }

  /// Бүх KYC алхам гүйцэтгэсэн эсэх
  bool get isKycComplete =>
      hasAgreement && isDanVerified && areAllDocumentsUploaded;

  // ── Document upload статус ────────────────────────────────────────────
  // Шинэ API: төлвүүд `kyc` дотор snake_case-ээр ирнэ
  // (kyc: { id_front: "true", id_back: "true", selfie: "true" }).
  // Хуучин формат `document: { idFront: ... }`-ийг fallback болгож дэмжинэ.
  Map<String, dynamic>? get _document => _asMap(_userInfo?['document']);

  // Өмнө илгээсэн баримтуудын зургийн URL-ууд:
  // kycDocs: { id_front: "https://...", id_back: ..., selfie: ... }
  Map<String, dynamic>? get _kycDocs => _asMap(_userInfo?['kycDocs']);

  /// Өмнө илгээсэн KYC баримтын зургийн URL (илгээгээгүй бол null).
  /// type: id_front | id_back | selfie
  String? kycDocUrl(String type) {
    final url = _kycDocs?[type]?.toString();
    return (url == null || url.isEmpty) ? null : url;
  }

  /// Иргэний үнэмлэхний урд талын зураг илгээсэн эсэх
  bool get isIdFrontUploaded =>
      _parseBool(_kyc?['id_front'] ?? _document?['idFront']) ||
      kycDocUrl('id_front') != null;

  /// Иргэний үнэмлэхний ар талын зураг илгээсэн эсэх
  bool get isIdBackUploaded =>
      _parseBool(_kyc?['id_back'] ?? _document?['idBack']) ||
      kycDocUrl('id_back') != null;

  /// Selfie зураг илгээсэн эсэх
  bool get isSelfieUploaded =>
      _parseBool(_kyc?['selfie'] ?? _document?['selfie']) ||
      kycDocUrl('selfie') != null;

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
    _biometricUserId = prefs.getString(_biometricUserKey);
    _uid = prefs.getString(_uidKey);
    _custName = prefs.getString(_custNameKey);

    // Хуучин хувилбарт эзэн хадгалагдаагүй — одоогийн хэрэглэгчээр нөхнө
    if (_isBiometricEnabled && _biometricUserId == null && _uid != null) {
      _biometricUserId = _uid;
      await prefs.setString(_biometricUserKey, _uid!);
    }

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
    // Идэвхжүүлсэн эзнийг цээжилнэ — өөр хэрэглэгч нэвтрэхэд унтраана
    if (enabled && _uid != null) {
      _biometricUserId = _uid;
      await prefs.setString(_biometricUserKey, _uid!);
    } else if (!enabled) {
      _biometricUserId = null;
      await prefs.remove(_biometricUserKey);
    }
    notifyListeners();
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      // PlatformException + MissingPluginException (web дээр plugin байхгүй)
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
    } catch (_) {
      // PlatformException + MissingPluginException (web дээр plugin байхгүй)
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
      'passDate': '2025-10-20',
      'deviceCount': 2,
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
    return apiMessage(data) ?? e.message ?? 'Network error';
  }

  Dio get _dio => Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ),
  );

  /// Session дууссан (401, refresh ч амжилтгүй) үед дуудагдана —
  /// main.dart-аас login дэлгэц рүү шилжүүлэхээр тохируулна.
  void Function()? onSessionExpired;

  /// Session-ийг цэвэрлээд login руу шилжүүлнэ. Зэрэг олон 401 ирэхэд
  /// нэг л удаа ажиллана.
  Future<void> _handleSessionExpired() async {
    if (_accessToken == null) return; // аль хэдийн гарсан
    await clearSession();
    onSessionExpired?.call();
  }

  /// Authentication header-тай Dio (`Authorization: Bearer <token>`).
  /// Нэвтэрсэн хэрэглэгчийн API дуудлагуудад ашиглана.
  ///
  /// 401 ирвэл: refresh token-оор шинэ access token авч хүсэлтийг нэг удаа
  /// давтана; refresh амжилтгүй эсвэл давталт нь дахин 401 бол session
  /// цэвэрлээд login дэлгэц рүү шилжүүлнэ.
  Dio get _authedDio {
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

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (err, handler) async {
          if (err.response?.statusCode != 401) return handler.next(err);

          // Давтан refresh хийхээс сэргийлэх
          if (err.requestOptions.headers.containsKey('X-Retry')) {
            await _handleSessionExpired();
            return handler.next(err);
          }

          final newToken = await refreshAccessToken();
          if (newToken == null) {
            // Refresh token-ий хугацаа дууссан → login руу
            await _handleSessionExpired();
            return handler.next(err);
          }

          // Шинэ token-той анхны хүсэлтийг дахин илгээх
          final options = err.requestOptions;
          options.headers['Authorization'] = 'Bearer $newToken';
          options.headers['X-Retry'] = 'true';
          try {
            final response = await dio.fetch(options);
            return handler.resolve(response);
          } on DioException catch (retryErr) {
            if (retryErr.response?.statusCode == 401) {
              await _handleSessionExpired();
            }
            return handler.next(retryErr);
          }
        },
      ),
    );

    return dio;
  }

  /// Хариунаас token задлан хадгалах (login, biometric, OTP verify-д ашиглана)
  Future<void> _handleAuthResponse(Map<String, dynamic> data) async {
    final String accessToken = data['token'];
    final String refreshToken = data['refreshToken'] ?? '';

    await saveTokens(accessToken: accessToken, refreshToken: refreshToken);
    await _saveUserInfoFromToken(accessToken);

    // Нэвтэрсэн хэрэглэгч биометрикийг идэвхжүүлсэн эзнээс өөр бол
    // тохиргоог автоматаар унтрааж аюулгүй болгоно. (Эзнийг _lastUserId-с
    // биш тусдаа key-ээс харьцуулна — logout _lastUserId-г цэвэрлэдэг.)
    if (_isBiometricEnabled &&
        _uid != null &&
        _biometricUserId != null &&
        _biometricUserId != _uid) {
      final previousOwner = _biometricUserId;
      await setBiometricEnabled(false);
      debugPrint('[Auth] Биометрик тохиргоо унтраав ($previousOwner → $_uid)');
    }

    if (_custName != null && _uid != null) {
      await saveLastUser(_custName!, _uid!);
    }

    // // Login амжилттай → FCM token серверт бүртгэх
    // registerFcmToken();

    // Хэрэглэгчийн дэлгэрэнгүй мэдээллийг татаж кэшэлнэ
    // (нэвтрэх процессыг хойшлуулахгүйн тулд async асаав)
    refreshUserInfo();
  }

  /// И-мэйл нэмэх / солих — POST /user/add_email, body: { data: { email } }
  /// Returns: серверийн message. Амжилттай бол кэшэлсэн userInfo-ийн
  /// email талбарыг шинэчилнэ.
  Future<String> addEmail(String email) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.userAddEmail,
        data: {
          'data': {'email': email},
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        if (_userInfo != null) {
          _userInfo!['email'] = email;
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userInfoKey, jsonEncode(_userInfo));
          notifyListeners();
        }
        return apiMessage(body) ?? 'И-мэйл амжилттай хадгалагдлаа';
      }
      throw Exception(apiMessage(body) ?? 'И-мэйл хадгалахад алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
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
      }
      // Бусад → алдаа (буруу нууц үг гэх мэт)
      return _loginErrorFromBody(response.data);
    } on DioException catch (e) {
      // Буруу нэвтрэлт нь 401 статустай ирдэг тул Dio exception шиднэ.
      // Гэхдээ response body-д code/message/attempt/counter байгаа тул
      // үүнийг credential алдаа болгож задална.
      final body = e.response?.data;
      if (body is Map) {
        return _loginErrorFromBody(body);
      }
      // Response огт байхгүй (timeout, холболт тасарсан гэх мэт) → техникийн алдаа
      debugPrint('[Auth] login сүлжээний алдаа: ${e.message}');
      return const LoginResult(isConnectionError: true);
    } catch (e) {
      // Техникийн алдааны raw мессежийг UI-д харуулахгүй.
      debugPrint('[Auth] login алдаа: $e');
      return const LoginResult(isConnectionError: true);
    }
  }

  /// Login-ний алдааны body-г LoginResult болгож задлана.
  /// body Map биш бол (HTML гэх мэт) техникийн алдаа гэж үзнэ.
  /// counter — одоо хийсэн буруу оролдлогын тоо
  /// attempt — зөвшөөрөгдөх дээд оролдлогын тоо
  LoginResult _loginErrorFromBody(dynamic body) {
    if (body is Map) {
      return LoginResult(
        message: apiMessage(body) ?? 'Login failed',
        counter: int.tryParse(body['counter']?.toString() ?? ''),
        attempt: int.tryParse(body['attempt']?.toString() ?? ''),
      );
    }
    return const LoginResult(isConnectionError: true);
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
          message: apiMessage(body) ?? 'Biometric login failed',
        );
      }

      return const LoginResult(message: 'Biometric login failed');
    } catch (e) {
      if (e is DioException) {
        // HTTP алдааны body-д message/messageen ирсэн бол түүнийг харуулна
        return LoginResult(message: _extractErrorMessage(e));
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
          message: apiMessage(body) ?? 'Device registration failed',
        );
      }

      return const LoginResult(message: 'Device registration failed');
    } catch (e) {
      if (e is DioException) {
        return LoginResult(message: _extractErrorMessage(e));
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
          apiMessage(body) ??
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
        return apiMessage(body) ?? 'Нууц үг амжилттай үүсгэгдлээ';
      }
      throw Exception(apiMessage(body) ?? 'Нууц үг үүсгэхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Орлого авах данс холбох — банк + IBAN + нэр.
  /// Returns: server message
  ///
  /// sendOtp-той ижил 2 горим:
  ///   1) **Нэвтэрсэн** (`isAuthenticated`) — `Authorization: Bearer` header
  ///      илгээж, body-д `sessionId` оруулахгүй. Сервер token-аас хэрэглэгчийг
  ///      таних.
  ///   2) **Нэвтрээгүй** — `sessionId` заавал шаардлагатай (register flow).
  ///
  /// [isPrimary] — үндсэн (орлого авах) данс болгох үед `"1"` гэж илгээнэ.
  /// Заавал биш — дансны жагсаалтаас данс сонгож primary болгоход ашиглана.
  Future<String> addAccount({
    String? sessionId,
    required String bankCode,
    required String iban,
    required String accountName,
    String? currency,
    bool isPrimary = false,
  }) async {
    final dio = isAuthenticated ? _authedDio : _dio;
    try {
      final Map<String, dynamic> bodyData = {
        'bankCode': bankCode,
        'iban': iban,
        'accountName': accountName,
        if (currency != null && currency.isNotEmpty) 'curCode': currency,
        if (isPrimary) 'isPrimary': '1',
      };
      if (!isAuthenticated) {
        if (sessionId == null || sessionId.isEmpty) {
          throw Exception(
            'sessionId шаардлагатай (нэвтэрсэн хэрэглэгч биш үед)',
          );
        }
        bodyData['sessionId'] = sessionId;
      }

      final response = await dio.post(
        ApiConfig.registerAddAccount,
        data: {'api': 'add_account', 'data': bodyData},
      );

      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        return apiMessage(body) ??
            'Дансны мэдээлэл амжилттай хадгалагдлаа';
      }
      throw Exception(apiMessage(body) ?? 'Данс холбоход алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// KYC: бичиг баримтын зураг илгээх
  /// type: id_front | id_back | selfie г.м.
  /// image: base64 encoded string
  /// [onSendProgress] — илгээлтийн явц (sent/total байт), UI-д progress
  /// харуулахад ашиглана
  /// Returns: серверт хадгалагдсан зургийн URL (data.url, байхгүй бол null)
  Future<String?> uploadKycDocument({
    required String type,
    required String image,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.kycUploadDocument,
        data: {
          'api': 'upload_document',
          'data': {'type': type, 'image': image},
        },
        onSendProgress: onSendProgress,
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        // Хариунаас хадгалагдсан зургийн URL авна
        final url = _asMap(body['data'])?['url']?.toString();

        // Кэшэлсэн userInfo дотрох kyc төлөв + kycDocs URL-ийг шинэчлэх
        // (type нь id_front | id_back | selfie — kyc-ийн түлхүүртэй ижил)
        if (_userInfo != null) {
          final kyc = _asMap(_userInfo!['kyc']) ?? <String, dynamic>{};
          kyc[type] = 'true';
          _userInfo!['kyc'] = kyc;
          if (url != null && url.isNotEmpty) {
            final docs = _asMap(_userInfo!['kycDocs']) ?? <String, dynamic>{};
            docs[type] = url;
            _userInfo!['kycDocs'] = docs;
          }
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_userInfoKey, jsonEncode(_userInfo));
          notifyListeners();
        }
        return url;
      }
      throw Exception(apiMessage(body) ?? 'Бичиг баримт илгээхэд алдаа гарлаа');
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
        return apiMessage(body) ?? 'Гэрээ амжилттай зөвшөөрөгдлөө';
      }
      throw Exception(apiMessage(body) ?? 'Гэрээ зөвшөөрөхөд алдаа гарлаа');
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
        return apiMessage(body) ?? 'Нууц үг амжилттай үүсгэгдлээ';
      }
      throw Exception(apiMessage(body) ?? 'Нууц үг сэргээхэд алдаа гарлаа');
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
      throw Exception(apiMessage(body) ?? 'Failed to fetch user info');
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

  /// Идэвхтэй захиалгууд.
  /// [scope]: 'all' → /orders/active, 'bond' → /orders/activebonds,
  /// 'stock' → /orders/activestocks.
  /// `Authorization: Bearer <token>` шаардана.
  Future<List<Map<String, dynamic>>> getActiveOrders({
    String scope = 'all',
  }) async {
    final endpoint = switch (scope) {
      'bond' => ApiConfig.ordersActiveBonds,
      'stock' => ApiConfig.ordersActiveStocks,
      _ => ApiConfig.ordersActive,
    };
    try {
      final response = await _authedDio.get(endpoint);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }
      // Захиалга байхгүй үед код 0-ээс өөр ирдэг — алдаа биш, хоосон жагсаалт
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  Future<List<Map<String, dynamic>>> getUserFees() async {
    try {
      final response = await _authedDio.get(ApiConfig.userFees);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data']) {
        return (body['data']['fees'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }
      return [];
    } on DioException catch (e) {
        throw Exception(_extractErrorMessage(e));
    }
  }

  /// Захиалгын түүх.
  /// POST /orders/history — body: {"data": {type?, status?, start, end}}
  /// type: bond|stock, status: done|canceled (заагаагүй бол бүгд).
  Future<List<Map<String, dynamic>>> getOrderHistory({
    String? type,
    String? status,
    required String start,
    required String end,
  }) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.ordersHistory,
        data: {
          'data': {
            if (type != null) 'type': type,
            if (status != null) 'status': status,
            'start': start,
            'end': end,
          },
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }
      // Түүх байхгүй үед алдаа биш — хоосон жагсаалт
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

  /// Үнэт цаасны тодорхойлолт — HTML хэлбэрээр (?lang=mn|en).
  /// Хариу нь шууд HTML эсвэл {code, data} JSON байж болно.
  Future<String> getDefinitionHtml({
    String lang = 'mn',
    String doc = 'definition',
    String? purpose,
  }) async {
    try {
      final response = await _authedDio.get(
        ApiConfig.userDocs(doc),
        queryParameters: {
          'lang': lang,
          if (purpose != null && purpose.isNotEmpty) 'purpose': purpose,
        },
        options: Options(responseType: ResponseType.plain),
      );
      final raw = response.data?.toString().trim() ?? '';
      if (raw.isEmpty) {
        throw Exception('Тодорхойлолт хоосон ирлээ');
      }
      // JSON envelope-той ирвэл data талбараас HTML-ийг авна
      if (raw.startsWith('{')) {
        try {
          final body = jsonDecode(raw) as Map<String, dynamic>;
          if (body['code']?.toString() == '0') {
            final html = body['data']?.toString() ?? '';
            if (html.isNotEmpty) return html;
          }
          throw Exception(
            apiMessage(body) ?? 'Тодорхойлолт авахад алдаа гарлаа',
          );
        } on FormatException {
          // JSON биш — raw HTML гэж үзнэ
        }
      }
      return raw;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Харилцагчийн шимтгэлийн хувиуд (кэштэй) — GET /user/fees
  /// Row: { STOCKTYPE, FEE ("1" = 1%), FEEIPO, SIDE, ... }
  List<Map<String, dynamic>>? _feesCache;
  Future<List<Map<String, dynamic>>> getUserFees() async {
    if (_feesCache != null) return _feesCache!;
    try {
      final response = await _authedDio.get(ApiConfig.userFees);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        final fees = (_asMap(body['data'])?['fees'] as List? ?? const [])
            .whereType<Map>()
            .map((f) => Map<String, dynamic>.from(f))
            .toList();
        _feesCache = fees;
        return fees;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Тухайн үнэт цаасны төрлийн шимтгэлийн ХУВЬ (1 = 1%).
  /// [ipo] — анхдагч арилжаа бол FEEIPO, бусад нь FEE.
  /// Олдохгүй/алдаа гарвал 0 буцаана (шимтгэлгүй гэж үзнэ).
  Future<double> getFeePercent({
    required String stockType,
    bool ipo = false,
  }) async {
    try {
      final fees = await getUserFees();
      final row = fees.firstWhere(
        (f) => f['STOCKTYPE']?.toString() == stockType,
        orElse: () => const {},
      );
      final raw = (ipo ? row['FEEIPO'] : row['FEE'])?.toString() ?? '';
      return double.tryParse(raw) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Захиалга үүсгэх — POST /order/new. Олон захиалгыг зэрэг илгээж
  /// болно; аль нэг нь амжилтгүй бол тухайн мөрийн msg-ээр алдаа шидне.
  /// Returns: серверийн message ("N orders created, M failed")
  Future<String> createOrders(List<Map<String, dynamic>> orders) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.orderNew,
        data: {'data': orders},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        final results = (body['data'] as List? ?? const []);
        final failed = results
            .whereType<Map>()
            .where((r) => r['success'] != true)
            .toList();
        if (failed.isNotEmpty) {
          final errMsg = failed.first['errMsg']?.toString() ?? '';
          final msg = failed.first['msg']?.toString() ?? '';
          throw Exception(
            errMsg.isNotEmpty
                ? errMsg
                : (msg.isNotEmpty ? msg : 'Захиалга амжилтгүй боллоо'),
          );
        }
        return apiMessage(body) ?? 'Захиалга амжилттай үүслээ';
      }
      throw Exception(apiMessage(body) ?? 'Захиалга үүсгэхэд алдаа гарлаа');
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Захиалга цуцлах — POST /order/cancel.
  /// [orders] мөр бүр {TXNID, ORDERNO} агуулна.
  Future<String> cancelOrders(List<Map<String, dynamic>> orders) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.orderCancel,
        data: {'data': orders},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0') {
        final results = (body['data'] as List? ?? const []);
        final failed = results
            .whereType<Map>()
            .where((r) => r['success'] != true)
            .toList();
        if (failed.isNotEmpty) {
          // Алдааны дэлгэрэнгүй нь errMsg-д, msg нь ерөнхий байдаг
          final errMsg = failed.first['errMsg']?.toString() ?? '';
          final msg = failed.first['msg']?.toString() ?? '';
          throw Exception(
            errMsg.isNotEmpty
                ? errMsg
                : (msg.isNotEmpty ? msg : 'Захиалга цуцлагдсангүй'),
          );
        }
        return apiMessage(body) ?? 'Захиалга цуцлагдлаа';
      }
      throw Exception(apiMessage(body) ?? 'Захиалга цуцлахад алдаа гарлаа');
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

  /// Санал болгож буй бондууд (NBO) — home carousel
  Future<List<Map<String, dynamic>>> getNboStocks() =>
      _fetchStockList(ApiConfig.stocksNbo);

  /// Харилцагчийн эзэмшдэг хувьцаанууд
  Future<List<Map<String, dynamic>>> getMyStocks() =>
      _fetchStockList(ApiConfig.stocksMyStocks);

  /// Харилцагчийн эзэмшдэг бондууд
  Future<List<Map<String, dynamic>>> getMyBonds() =>
      _fetchStockList(ApiConfig.stocksMyBonds);

  /// Зах зээл дээрх бондууд (бонд авах tab)
  Future<List<Map<String, dynamic>>> getBondList() =>
      _fetchStockList(ApiConfig.stocksBondList);

  /// Хураангуй тайлан — POST /portfolio/summary_report?start=..&end=..
  /// Returns: { portfolio: [...], transactions: [...] }
  Future<Map<String, dynamic>?> getSummaryReport({
    required String start,
    required String end,
  }) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.portfolioSummaryReport,
        queryParameters: {'start': start, 'end': end},
        data: {'api': 'summary_report'},
      );
      final body = response.data;
      if (body is Map && body['code']?.toString() == '0' && body['data'] is Map) {
        return Map<String, dynamic>.from(body['data'] as Map);
      }
      return null;
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Захиалгын самбар — POST /stocks/order_book,
  /// body: { api: "order_book", data: { stockcode } }
  Future<List<Map<String, dynamic>>> getOrderBook(String stockcode) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.stocksOrderBook,
        data: {
          'api': 'order_book',
          'data': {'stockcode': stockcode},
        },
      );
      final body = response.data;
      if (body is Map &&
          body['code']?.toString() == '0' &&
          body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map>()
            .map((d) => Map<String, dynamic>.from(d))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Хувьцааны дэлгэрэнгүй мэдээлэл — POST /stocks/info,
  /// body: { api: "info", data: { stockcode } }
  /// Хариу нь мөрүүдийн жагсаалт: эхний мөр = одоогийн ерөнхий мэдээлэл,
  /// мөр бүрийн DIVAMOUNT/DIVDATE = ногдол ашгийн түүх.
  Future<List<Map<String, dynamic>>> getStockInfo(String stockcode) async {
    try {
      final response = await _authedDio.post(
        ApiConfig.stocksInfo,
        data: {
          'api': 'info',
          'data': {'stockcode': stockcode},
        },
      );
      final body = response.data;
      if (body is Map && body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .whereType<Map>()
            .map((d) => Map<String, dynamic>.from(d))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

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
      /*if (body['code']?.toString() == '0' && body['data'] is List) {
        return (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .toList();
      }*/
      if (body['code']?.toString() == '0' && body['data'] is Map<String, dynamic>) {
        final data = body['data'] as Map<String, dynamic>;

        // 2. Extract and parse the nested 'points' array
        if (data['points'] is List) {
          return (data['points'] as List)
              .map((d) => Map<String, dynamic>.from(d as Map))
              .toList();
        }
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
          apiMessage(body) ?? 'Portfolio summary алдаа',
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
        usdRate: toDouble(data['usdRate']),
        holdAmount: toDouble(data['holdAmount']),
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Equity (нийт хөрөнгө) график.
  /// GET /portfolio/chart_data?start=yyyy/MM/dd&end=yyyy/MM/dd
  /// Default: сүүлийн 1 жил.
  /// Response: { points: [{date, value}] }
  Future<EquityChart> getEquityChart({String? start, String? end}) async {
    final now = DateTime.now();
    final s =
        start ?? _formatChartDate(DateTime(now.year - 1, now.month, now.day));
    final e = end ?? _formatChartDate(now);
    try {
      final response = await _authedDio.get(
        ApiConfig.portfolioChartData,
        queryParameters: {'start': s, 'end': e},
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() != '0') {
        throw Exception(apiMessage(body) ?? 'Chart data алдаа');
      }
      final data = (body['data'] as Map?) ?? const {};
      final rawPoints = (data['points'] as List?) ?? const [];
      final points = rawPoints
          .map((p) => EquityPoint.fromJson(Map<String, dynamic>.from(p as Map)))
          .toList();
      return EquityChart(
        period: (data['period'] as String?) ?? '',
        points: points,
      );
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Хөрөнгийн хуваарилалт (asset breakdown).
  /// GET /portfolio/breakdown
  /// Response (server): `data: [{TYPE, AMOUNT, AMOUNTMNT, COUNT, CODENAME, CODEORDER}]`
  /// Normalize → `[{type, name, amount, amountMnt, amountRaw, count, order}]`
  ///   • mnt / usd → `amount` = AMOUNT (өөрийн валютаар)
  ///   • bond / stock → `amount` = AMOUNTMNT (MNT эквивалент)
  Future<List<Map<String, dynamic>>> getAssetBreakdown() async {
    try {
      final response = await _authedDio.get(ApiConfig.portfolioBreakdown);
      final body = response.data as Map<String, dynamic>;
      if (body['code']?.toString() == '0' && body['data'] is List) {
        final list = (body['data'] as List)
            .map((d) => Map<String, dynamic>.from(d as Map))
            .map(_normalizeBreakdownItem)
            .toList();
        // CODEORDER-ээр эрэмбэлнэ (1=mnt, 2=usd, 3=bond, 4=stock)
        list.sort((a, b) {
          final ao = (a['order'] as num?)?.toInt() ?? 999;
          final bo = (b['order'] as num?)?.toInt() ?? 999;
          return ao.compareTo(bo);
        });
        return list;
      }
      return [];
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e));
    }
  }

  /// Backend uppercase + string утгуудыг UI-д хэрэглэдэг lowercase + num
  /// руу хөрвүүлнэ. Хуучин (lowercase түлхүүртэй) хариулттай ч нийцтэй.
  Map<String, dynamic> _normalizeBreakdownItem(Map<String, dynamic> raw) {
    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    final type = (raw['TYPE'] ?? raw['type'] ?? '').toString().toLowerCase();
    final name = raw['CODENAME'] ?? raw['name'];
    final amountRaw = toDouble(raw['AMOUNT'] ?? raw['amount']);
    final amountMnt = toDouble(raw['AMOUNTMNT'] ?? raw['amountMnt']);
    final count = toInt(raw['COUNT'] ?? raw['count']);
    final order = toInt(raw['CODEORDER'] ?? raw['order']);
    final usdRate = toDouble(raw['USDRATE'] ?? raw['usdRate']);

    // mnt/usd-ийн хувьд өөрийн валютаар, бонд/хувьцааны хувьд MNT эквивалентаар
    final isCash =
        type == 'mnt' ||
        type == 'usd' ||
        type == 'cash' ||
        type == 'tugrik' ||
        type == 'dollar';
    final displayAmount = isCash ? amountRaw : amountMnt;

    return {
      'type': type,
      if (name != null) 'name': name,
      'amount': displayAmount,
      'amountRaw': amountRaw,
      'amountMnt': amountMnt,
      'count': count,
      'order': order,
      'usdRate': usdRate,
    };
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
        return apiMessage(body) ?? 'Амжилттай нэмэгдлээ';
      }
      throw Exception(apiMessage(body) ?? 'Watchlist нэмэхэд алдаа гарлаа');
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
        return apiMessage(body) ?? 'Амжилттай устгагдлаа';
      }
      throw Exception(apiMessage(body) ?? 'Watchlist устгахад алдаа гарлаа');
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
        return apiMessage(body) ?? 'Төхөөрөмж устгагдлаа';
      }
      throw Exception(apiMessage(body) ?? 'Төхөөрөмж устгахад алдаа гарлаа');
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
        return apiMessage(body) ?? 'PEP төлөв хадгалагдлаа';
      }
      throw Exception(apiMessage(body) ?? 'PEP төлөв илгээхэд алдаа гарлаа');
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
      throw Exception(apiMessage(body) ?? 'OTP send failed');
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
      throw Exception(apiMessage(body) ?? 'OTP verification failed');
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
      throw Exception(apiMessage(body) ?? 'Харилцагч олдсонгүй');
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

  /// Явагдаж буй refresh хүсэлт — давхардлаас сэргийлнэ
  Future<String?>? _refreshFuture;

  /// Token expire болсон үед refresh token ашиглан шинэ token авна.
  /// Амжилттай бол шинэ access token буцаана, амжилтгүй бол null.
  Future<String?> refreshAccessToken() {
    if (_refreshToken == null) return Future.value(null);
    // Зэрэг олон 401 ирэхэд нэг л refresh хүсэлт явуулж, бусад нь
    // түүний үр дүнг хүлээнэ (өмнө нь null буцааж session-ийг
    // буруугаар дуусгадаг байсан)
    return _refreshFuture ??= _doRefreshToken().whenComplete(() {
      _refreshFuture = null;
    });
  }

  Future<String?> _doRefreshToken() async {
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

  final double holdAmount;

  final double usdRate;

  const PortfolioSummary({
    required this.totalAssets,
    required this.totalChange,
    required this.changePercent,
    required this.cashBalance,
    required this.holdAmount,
    required this.usdRate,
  });

  /// Хоосон summary — алдаа гарсан үеийн default.
  static const PortfolioSummary empty = PortfolioSummary(
    totalAssets: 0,
    totalChange: 0,
    changePercent: 0,
    cashBalance: 0,
    holdAmount: 0,
    usdRate: 0,
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
