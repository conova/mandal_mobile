/// Notification Gateway-ийн feed хариу
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
