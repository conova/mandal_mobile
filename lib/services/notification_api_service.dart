import 'package:dio/dio.dart';
import '../config/api_config.dart';
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
  Future<NotificationFeed> list({
    bool unreadOnly = false,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/v1/notifications',
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
      );
    } on DioException catch (e) {
      throw NotificationApiException(_extractError(e));
    }
  }

  /// POST /v1/notifications/:id/read → 204
  Future<void> markRead(int id) async {
    try {
      await _dio.post('/v1/notifications/$id/read');
    } on DioException catch (e) {
      throw NotificationApiException(_extractError(e));
    }
  }

  /// POST /v1/notifications/read-all → 204
  Future<void> markAllRead() async {
    try {
      await _dio.post('/v1/notifications/read-all');
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

class NotificationFeed {
  final List<ApiNotification> items;
  final int count;
  const NotificationFeed({required this.items, required this.count});
}

/// Gateway-ийн буцаасан notification (DB row).
class ApiNotification {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final String targetKind; // 'user' | 'broadcast'
  final bool isRead;
  final DateTime createdAt;

  const ApiNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.targetKind,
    required this.isRead,
    required this.createdAt,
  });

  factory ApiNotification.fromJson(Map<String, dynamic> json) {
    return ApiNotification(
      id: (json['id'] as num).toInt(),
      type: (json['type'] as String?) ?? 'system',
      title: (json['title'] as String?) ?? '',
      body: (json['body'] as String?) ?? '',
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      targetKind: (json['target_kind'] as String?) ?? 'user',
      isRead: json['is_read'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  /// Format: `2025.10.30 19:32`
  String get formattedTime {
    final d = createdAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}.${two(d.month)}.${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
