import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background message handler — top-level function байх ёстой
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('[FCM] Background message: ${message.messageId}');
  // Notification хадгалах
  await NotificationService.saveNotification(message);
}

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.data,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'time': time,
        'isRead': isRead,
        'data': data,
      };

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      time: json['time'] ?? '',
      isRead: json['isRead'] ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  NotificationItem copyWith({bool? isRead}) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      time: time,
      isRead: isRead ?? this.isRead,
      data: data,
    );
  }
}

class NotificationService {
  static const String _storageKey = 'fcm_notifications';
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// FCM token
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Notification жагсаалт
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Уншаагүй notification тоо
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Callback — шинэ notification ирэхэд дуудна
  void Function(NotificationItem)? onNotificationReceived;

  /// Callback — FCM token шинэчлэгдэхэд дуудна (deviceId шинэчлэхэд)
  void Function(String)? onTokenRefresh;

  /// Firebase Messaging тохируулах
  Future<void> init() async {
    // Зөвшөөрөл авах
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // FCM token авах
      _fcmToken = await _messaging.getToken(
        vapidKey: kIsWeb
            ? 'YOUR-VAPID-KEY' // Web push-д VAPID key шаардлагатай
            : null,
      );
      debugPrint('[FCM] Token: $_fcmToken');

      // Token шинэчлэгдэхэд
      _messaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        debugPrint('[FCM] Token refreshed: $newToken');
        onTokenRefresh?.call(newToken);
      });
    }

    // Хадгалсан notification-уудыг унших
    await _loadNotifications();

    // Foreground message listener
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background-оос app нээхэд
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // App хаалттай байхад notification дарж нээхэд
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Foreground дээр notification ирэхэд
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.notification?.title}');

    final item = _messageToItem(message);
    _notifications.insert(0, item);
    _saveNotifications();

    onNotificationReceived?.call(item);
  }

  /// Background/terminated-оос app нээхэд
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Opened app from: ${message.notification?.title}');

    final item = _messageToItem(message);
    // Давхардал шалгах
    if (!_notifications.any((n) => n.id == item.id)) {
      _notifications.insert(0, item);
      _saveNotifications();
    }

    // TODO: data дотор route байвал navigate хийх
    // Жишээ: message.data['route'] == '/order_detail'
  }

  /// RemoteMessage → NotificationItem
  NotificationItem _messageToItem(RemoteMessage message) {
    return NotificationItem(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? message.data['title'] ?? '',
      body: message.notification?.body ?? message.data['body'] ?? '',
      time: DateTime.now().toIso8601String(),
      data: message.data.isNotEmpty ? Map<String, dynamic>.from(message.data) : null,
    );
  }

  /// Background handler-аас notification хадгалах (static)
  static Future<void> saveNotification(RemoteMessage message) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    final List<dynamic> list = raw != null ? jsonDecode(raw) : [];

    list.insert(0, {
      'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': message.notification?.title ?? message.data['title'] ?? '',
      'body': message.notification?.body ?? message.data['body'] ?? '',
      'time': DateTime.now().toIso8601String(),
      'isRead': false,
      'data': message.data.isNotEmpty ? message.data : null,
    });

    await prefs.setString(_storageKey, jsonEncode(list));
  }

  /// SharedPreferences-аас notification унших
  Future<void> _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null) {
      final List<dynamic> list = jsonDecode(raw);
      _notifications = list
          .map((e) => NotificationItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  /// SharedPreferences-д хадгалах
  Future<void> _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final json = _notifications.map((n) => n.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(json));
  }

  /// Notification уншсан гэж тэмдэглэх
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications();
    }
  }

  /// Бүгдийг уншсан гэж тэмдэглэх
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications();
  }

  /// Notification устгах
  Future<void> clearAll() async {
    _notifications.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
