import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_notification.dart';
import 'auth_service.dart';

/// Notification Gateway микросервистэй харьцах HTTP client.
/// Bearer JWT auth — `AuthService.accessToken` ашиглана.
class NotificationApiService {
  final AuthService _auth;
  final Dio _dio;

  NotificationApiService(this._auth)
      : _dio = Dio(
          BaseOptions(
            baseUrl: ApiConfig.notificationGatewayUrl,
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

  /// GET /v1/notifications?unread_only=true&limit=50&offset=0
  /// limit: 1..200 (default 50), offset: ≥0 (default 0)
  Future<NotificationFeed> list({
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        ApiConfig.notificationsList,
        queryParameters: {
          if (unreadOnly) 'unread_only': 'true',
          'limit': limit,
          'offset': offset,
        },
      );
      final body = response.data as Map<String, dynamic>;
      final rawList = (body['data'] as List? ?? const []);
      final items = rawList
          .map((e) => ApiNotification.fromJson(e as Map<String, dynamic>))
          .toList();
      return NotificationFeed(
        items: items,
        count: (body['count'] as num?)?.toInt() ?? items.length,
        hasMore: body['has_more'] == true,
        nextOffset: (body['next_offset'] as num?)?.toInt() ??
            offset + items.length,
        totalCount: (body['total_count'] as num?)?.toInt() ?? items.length,
        unreadCount: (body['unread_count'] as num?)?.toInt() ?? 0,
      );
    } on DioException catch (e) {
      throw NotificationApiException(_extractError(e));
    }
  }

  /// POST /v1/notifications/:id/read → 204 No Content
  Future<void> markRead(int id) async {
    try {
      // body хоосон бол "Body cannot be empty when content-type is
      // application/json" алдаа өгдөг тул хоосон JSON объект явуулна
      await _dio.post(ApiConfig.notificationMarkRead(id), data: const {});
    } on DioException catch (e) {
      throw NotificationApiException(_extractError(e));
    }
  }

  /// POST /v1/notifications/read-all → 204 No Content
  Future<void> markAllRead() async {
    try {
      await _dio.post(ApiConfig.notificationsMarkAllRead, data: const {});
    } on DioException catch (e) {
      throw NotificationApiException(_extractError(e));
    }
  }

  String _extractError(DioException e) {
    final data = e.response?.data;
    if (data is Map) {
      final err = data['error'];
      if (err is String && err.isNotEmpty) return err;
    }
    return e.message ?? 'Network error';
  }
}

class NotificationApiException implements Exception {
  final String message;
  NotificationApiException(this.message);
  @override
  String toString() => message;
}
