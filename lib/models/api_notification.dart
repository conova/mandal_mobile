/// Notification Gateway-ийн feed хариу (pagination дэмжинэ)
class NotificationFeed {
  final List<ApiNotification> items;
  final int count;
  final bool hasMore;
  final int nextOffset;
  final int totalCount;
  final int unreadCount;

  const NotificationFeed({
    required this.items,
    required this.count,
    this.hasMore = false,
    this.nextOffset = 0,
    this.totalCount = 0,
    this.unreadCount = 0,
  });
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
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
      targetKind: (json['target_kind'] as String?) ?? 'user',
      isRead: json['is_read'] == true,
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
              DateTime.now(),
    );
  }

  /// Зарим талбарыг сольсон хуулбар (уншсан болгох г.м.)
  ApiNotification copyWith({bool? isRead}) => ApiNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        data: data,
        targetKind: targetKind,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  /// Format: `2025.10.30 19:32`
  String get formattedTime {
    final d = createdAt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}.${two(d.month)}.${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
  }
}
