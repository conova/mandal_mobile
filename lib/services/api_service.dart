import 'package:dio/dio.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class ApiService {
  final Dio _dio;
  final AuthService _authService;

  ApiService(this._authService, {void Function()? onLogout})
      : _dio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: ApiConfig.connectTimeout,
          receiveTimeout: ApiConfig.receiveTimeout,
          contentType: 'application/json',
        )) {
    _dio.interceptors.add(AuthInterceptor(_authService, _dio, onLogout: onLogout));
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.put(path, data: data, queryParameters: queryParameters);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    return _dio.delete(path, data: data, queryParameters: queryParameters);
  }
}

class AuthInterceptor extends Interceptor {
  final AuthService _authService;
  final Dio _dio;
  final void Function()? onLogout;

  AuthInterceptor(this._authService, this._dio, {this.onLogout});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _authService.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Давтан refresh хийхээс сэргийлэх
      if (err.requestOptions.headers.containsKey('X-Retry')) {
        _authService.clearSession();
        onLogout?.call();
        return super.onError(err, handler);
      }

      // Refresh token ашиглан шинэ access token авах
      final newToken = await _authService.refreshAccessToken();

      if (newToken != null) {
        // Header шинэчлэн анхны request-г дахин илгээх
        final options = err.requestOptions;
        options.headers['Authorization'] = 'Bearer $newToken';
        options.headers['X-Retry'] = 'true';

        try {
          final response = await _dio.fetch(options);
          return handler.resolve(response);
        } on DioException catch (retryErr) {
          return handler.next(retryErr);
        }
      } else {
        // Refresh token-ий хугацаа дууссан → session цэвэрлэх, logout
        _authService.clearSession();
        onLogout?.call();
      }
    }
    super.onError(err, handler);
  }

  void clearSession() {
    _authService.clearSession();
  }
}
