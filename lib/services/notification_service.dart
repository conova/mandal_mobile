import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart' show navigatorKey;

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

class NotificationService extends ChangeNotifier {
  static const String _storageKey = 'fcm_notifications';
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Foreground үед notification bar-д давхар харуулах локал notification.
  /// Android дээр FCM foreground message-ийг систем өөрөө харуулдаггүй
  /// тул үүгээр харуулна; iOS дээр setForegroundNotificationPresentationOptions
  /// хангалттай.
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'mandal_high_importance',
    'Мэдэгдэл',
    description: 'Mandal Capital мэдэгдлүүд',
    importance: Importance.high,
  );

  /// FCM token
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Notification жагсаалт
  List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => List.unmodifiable(_notifications);

  /// Уншаагүй мэдэгдлийн тоо — home header-ийн хонхны badge.
  /// Notification API-ийн unread_count-аас эх авч, FCM push ирэх бүрд
  /// 1-ээр нэмэгдэнэ; жагсаалтын дэлгэц дээр уншихад буурна.
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  /// Server-ийн unread_count-аар badge-ийг шинэчилнэ (home нээгдэхэд,
  /// мэдэгдлийн жагсаалт татахад)
  void setUnreadCount(int value) {
    final v = value < 0 ? 0 : value;
    if (_unreadCount == v) return;
    _unreadCount = v;
    notifyListeners();
  }

  /// Callback — шинэ notification ирэхэд дуудна
  void Function(NotificationItem)? onNotificationReceived;

  /// Шинэ (хараагүй) push ирсэн эсэх — home header-ийн хонхны улаан цэг.
  /// Notification жагсаалтын дэлгэц нээгдэхэд [markSeen]-ээр арилна.
  bool _hasUnseen = false;
  bool get hasUnseen => _hasUnseen;

  /// Terminated байхад notification bar-аас нээсэн мессеж — app бүрэн
  /// ачаалж дуусаад (MainContainer) '/notification_detail' руу шилжихэд
  /// ашиглана.
  NotificationItem? _pendingOpen;
  NotificationItem? takePendingOpen() {
    final item = _pendingOpen;
    _pendingOpen = null;
    return item;
  }

  /// Notification жагсаалтын дэлгэц нээгдэхэд — хонхны цэгийг арилгана
  void markSeen() {
    if (!_hasUnseen) return;
    _hasUnseen = false;
    markAllAsRead();
    notifyListeners();
  }

  /// NotificationItem → notification_detail дэлгэцийн Map args
  static Map<String, dynamic> detailArgsOf(NotificationItem item) => {
        'type': item.data?['type']?.toString() ?? 'system',
        'title': item.title,
        'body': item.body,
        'time': item.time,
        'targetKind': item.data?['target_kind']?.toString(),
        'data': item.data ?? const {},
      };

  /// Callback — FCM token шинэчлэгдэхэд дуудна (deviceId шинэчлэхэд)
  void Function(String)? onTokenRefresh;

  /// Firebase Messaging тохируулах
  Future<void> init() async {
    // Хадгалсан notification-уудыг унших
    await _loadNotifications();

    // Локал notification тохируулах (foreground үед bar-д харуулах)
    await _initLocalNotifications();

    // iOS: foreground үед FCM notification-ийг систем шууд харуулна
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

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

  /// Мэдэгдлийн зөвшөөрөл асууж token авна. [init]-ээс тусад нь —
  /// runApp-ын ӨМНӨ дуудвал iOS-ийн permission popup app-ийг гацаадаг
  /// тул эхний frame зурагдсаны ДАРАА (main.dart) дуудагдана.
  Future<void> requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus != AuthorizationStatus.authorized &&
        settings.authorizationStatus != AuthorizationStatus.provisional) {
      return;
    }

    // FCM token авах
    // Web push-д VAPID key шаардлагатай — Firebase Console → Project Settings →
    // Cloud Messaging → Web configuration → Web Push certificates
    _fcmToken = await _messaging.getToken(
      vapidKey: kIsWeb
          ? 'BEb-ahqOqkHywzlILnxM5_rpMDIMbncCJw4E5c2IspRf7Pbrs-1EqwP9G8J8-5BV9vuP7VbebIryqMGyQFskeJM'
          : null,
    );
    debugPrint('[FCM] Token: $_fcmToken');

    // Token хожуу ирсэн тул deviceId-г шинэчлүүлнэ (main.dart-ийн
    // onTokenRefresh нь authService.setDeviceId-г дууддаг)
    if (_fcmToken != null) {
      onTokenRefresh?.call(_fcmToken!);
    }

    // Token шинэчлэгдэхэд
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      debugPrint('[FCM] Token refreshed: $newToken');
      onTokenRefresh?.call(newToken);
    });

    // Бүх хэрэглэгчийг "all" topic-д сувагчлуулна — broadcast мэдэгдэл
    // илгээхэд ашиглана. (Web дээр topic subscription дэмжигдэхгүй.)
    if (!kIsWeb) {
      try {
        await _messaging.subscribeToTopic('all');
        debugPrint('[FCM] Subscribed to topic: all');
      } catch (e) {
        debugPrint('[FCM] Topic subscribe алдаа: $e');
      }
    }
  }

  /// Foreground дээр notification ирэхэд — unseen туг тавьж сонсогчдод
  /// мэдэгдэнэ: notification жагсаалтын дэлгэц нээлттэй бол жагсаалтаа
  /// шинэчилнэ, бусад дэлгэц дээр home header-ийн хонх цэгтэй болно
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('[FCM] Foreground: ${message.notification?.title}');

    final item = _messageToItem(message);
    _notifications.insert(0, item);
    _saveNotifications();

    _hasUnseen = true;
    _unreadCount++;
    notifyListeners();
    onNotificationReceived?.call(item);

    // Notification bar-д давхар харуулна (Android; iOS-ийг
    // setForegroundNotificationPresentationOptions хариуцна)
    _showLocalNotification(message, item);
  }

  /// Локал notification plugin init — дарахад notification_detail руу шилжинэ
  Future<void> _initLocalNotifications() async {
    if (kIsWeb) return;
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/launcher_icon'),
      iOS: DarwinInitializationSettings(
        // Зөвшөөрлийг FCM requestPermission аль хэдийн авсан
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final item = NotificationItem.fromJson(
            Map<String, dynamic>.from(jsonDecode(payload)),
          );
          navigatorKey.currentState?.pushNamed(
            '/notification_detail',
            arguments: detailArgsOf(item),
          );
        } catch (_) {
          // payload эвдэрсэн — үл тооцно
        }
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  /// Foreground үед ирсэн FCM message-ийг notification bar-д харуулна
  Future<void> _showLocalNotification(
    RemoteMessage message,
    NotificationItem item,
  ) async {
    // iOS foreground-ийг FCM өөрөө харуулдаг тул давхардуулахгүй
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return;
    }
    if (item.title.isEmpty && item.body.isEmpty) return;
    await _localNotifications.show(
      id: message.hashCode,
      title: item.title,
      body: item.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
      payload: jsonEncode(item.toJson()),
    );
  }

  /// Notification bar-аас дарж app нээгдэхэд — notification_detail руу
  /// шууд шилжинэ
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('[FCM] Opened app from: ${message.notification?.title}');

    final item = _messageToItem(message);
    // Давхардал шалгах
    if (!_notifications.any((n) => n.id == item.id)) {
      _notifications.insert(0, item);
      _saveNotifications();
    }

    final nav = navigatorKey.currentState;
    if (nav != null) {
      // App аль хэдийн ажиллаж байсан (background) — шууд шилжинэ
      nav.pushNamed('/notification_detail', arguments: detailArgsOf(item));
    } else {
      // Terminated-оос нээгдэж байна — app ачаалж дуусахаар
      // (MainContainer) шилжүүлэхээр хадгална
      _pendingOpen = item;
    }
    notifyListeners();
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
      // Background-д ирж хадгалагдсан, хараахан үзээгүй push байвал
      // хонхны цэгийг сэргээнэ
      _hasUnseen = _notifications.any((n) => !n.isRead);
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
