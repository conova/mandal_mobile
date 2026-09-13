import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

/// E-Mongolia (DAN) баталгаажуулалтын API client.
class DanService {
  final AuthService _auth;
  final Dio _dio;

  DanService(this._auth)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.danServiceUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            contentType: 'application/json',
          ),
        ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _auth.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  /// E-Mongolia баталгаажуулалт эхлүүлэх — webview-д нээх uri авна.
  /// POST /api/e/uri
  /// body: { unique, callback, services: [{code, params?}] }
  /// response: { code, response: { uri, state, requestId }, title }
  Future<DanEUriResult> startEMongolia({
    required String unique,
    required String callback,
    required List<DanServiceRequest> services,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.danEUri,
        data: {
          'unique': unique,
          'callback': callback,
          'services': services.map((s) => s.toJson()).toList(),
        },
      );
      final body = response.data as Map<String, dynamic>;
      if (body['code'] != 0) {
        throw DanException(
          (body['title']?.toString() ?? 'E-Mongolia init failed'),
        );
      }
      final resp = body['response'] as Map<String, dynamic>;
      return DanEUriResult(
        uri: resp['uri'] as String,
        state: resp['state'] as String,
        requestId: (resp['requestId'] as num).toInt(),
      );
    } on DioException catch (e) {
      throw DanException(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final t = data['title'] ?? data['message'] ?? data['error'];
      if (t is String && t.isNotEmpty) return t;
    }
    return e.message ?? 'Network error';
  }
}

/// E-Mongolia-гаас хүсэх нэг үйлчилгээ.
///
/// Зарим үйлчилгээ нэмэлт параметр шаардана — жнь `CHILD_INFO` нь
/// эцэг/эхийн `registeredNum` (иргэний үнэмлэхний бүртгэлийн дугаар)
/// болон `regnum` (регистрийн дугаар) хоёрыг авна.
class DanServiceRequest {
  final String code;
  final Map<String, String> params;

  const DanServiceRequest(this.code, {this.params = const {}});

  Map<String, dynamic> toJson() => {
        'code': code,
        if (params.isNotEmpty) 'params': params,
      };
}

class DanException implements Exception {
  final String message;
  DanException(this.message);
  @override
  String toString() => message;
}

class DanEUriResult {
  final String uri;
  final String state;
  final int requestId;
  const DanEUriResult({
    required this.uri,
    required this.state,
    required this.requestId,
  });
}
