import '../models/api_notification.dart';

/// Backend Notification Gateway-гүй үед UI-г preview хийх / тест хийхэд
/// зориулсан жишээ notification-ууд.
///
/// `notification_screen.dart` нь API амжилтгүй болсон эсвэл хоосон жагсаалт
/// буцсан үед `mockNotifications()`-ыг fallback болгож харуулна.
///
/// Жагсаалтад дараах type-ууд орсон: order, news, promo, security, payment,
/// kyc, system, broadcast (`target_kind`-аар). Зарим нь read, зарим unread.
List<ApiNotification> mockNotifications() {
  final now = DateTime.now();
  return [
    // 1) Order — арилжаа биелсэн
    ApiNotification(
      id: 1001,
      type: 'order',
      title: 'Захиалга биелэлээ',
      body: 'APU 1,250₮-ээр 100 ширхэг худалдаж авлаа',
      data: const {
        'order_id': 'ORD-2026-0089',
        'symbol': 'APU',
        'side': 'BUY',
        'quantity': 100,
        'price': 1250,
        'total': 125000,
        'fee': 250,
        'status': 'FILLED',
      },
      targetKind: 'user',
      isRead: false,
      createdAt: now.subtract(const Duration(minutes: 5)),
    ),

    // 2) Order — Sell side
    ApiNotification(
      id: 1002,
      type: 'order',
      title: 'Зарах захиалга идэвхжлээ',
      body: 'GOV 2,100₮-ээр 50 ширхэг зарах захиалга байршууллаа',
      data: const {
        'order_id': 'ORD-2026-0090',
        'symbol': 'GOV',
        'side': 'SELL',
        'quantity': 50,
        'price': 2100,
        'total': 105000,
        'status': 'OPEN',
      },
      targetKind: 'user',
      isRead: false,
      createdAt: now.subtract(const Duration(hours: 1)),
    ),

    // 3) Payment — мөнгөн орлого
    ApiNotification(
      id: 1003,
      type: 'payment',
      title: 'Данс цэнэглэгдлээ',
      body: 'Голомт банкнаас 500,000₮ танай данс руу шилжүүлэгдлээ',
      data: const {
        'amount': 500000,
        'currency': 'MNT',
        'broker': 'Голомт банк',
        'account': '****4521',
        'status': 'SUCCESS',
      },
      targetKind: 'user',
      isRead: false,
      createdAt: now.subtract(const Duration(hours: 3)),
    ),

    // 4) Security — нэвтрэх анхааруулга
    ApiNotification(
      id: 1004,
      type: 'security',
      title: 'Шинэ төхөөрөмжөөс нэвтэрлээ',
      body: 'Танай нэрийн өмнөөс шинэ Android төхөөрөмжөөс амжилттай нэвтэрсэн байна. Хэрэв та биш бол яаралтай нууц үгээ солино уу.',
      data: const {
        'device': 'Samsung Galaxy S23',
        'ip': '192.168.1.45',
        'location': 'Ulaanbaatar, Mongolia',
      },
      targetKind: 'user',
      isRead: true,
      createdAt: now.subtract(const Duration(hours: 8)),
    ),

    // 5) KYC — баталгаажуулалт
    ApiNotification(
      id: 1005,
      type: 'kyc',
      title: 'Баталгаажуулалт амжилттай',
      body: 'Таны KYC мэдээлэл амжилттай баталгаажлаа. Та одоо бүх үйлчилгээг ашиглах боломжтой.',
      data: const {
        'status': 'APPROVED',
        'reason': 'E-Mongolia баталгаажсан',
      },
      targetKind: 'user',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 1)),
    ),

    // 6) News — зах зээлийн мэдээ (broadcast)
    ApiNotification(
      id: 1006,
      type: 'news',
      title: 'MSE индекс шинэ дээд цэгтээ хүрлээ',
      body: 'Top-20 индекс өнөөдөр 32,450 пункт болж сүүлийн 12 сарын дээд цэгтээ хүрсэн байна.',
      data: const {
        'symbol': 'MSE-TOP20',
        'price': 32450,
        'url': 'https://news.mongolia.mn/mse-record',
      },
      targetKind: 'broadcast',
      isRead: false,
      createdAt: now.subtract(const Duration(days: 1, hours: 5)),
    ),

    // 7) Promo — урамшуулал (broadcast)
    ApiNotification(
      id: 1007,
      type: 'promo',
      title: 'Шинэ хэрэглэгчдэд 0% шимтгэл',
      body: 'Энэ долоо хоногт шинээр данс нээсэн хэрэглэгчдэд эхний 30 хоногт арилжааны шимтгэлийг 0% болгож олгож байна.',
      data: const {
        'fee': 0,
        'reason': 'Шинэ хэрэглэгчийн урамшуулал',
      },
      targetKind: 'broadcast',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 2)),
    ),

    // 8) System — system update
    ApiNotification(
      id: 1008,
      type: 'system',
      title: 'Систем шинэчлэгдлээ',
      body: 'Mandal Capital апп v2.4.0 хувилбар руу шинэчлэгдлээ. Шинэ боломжуудыг "Тохиргоо → Шинэчлэлт" хэсгээс үзнэ үү.',
      data: const {
        'version': '2.4.0',
        'message': 'Performance сайжруулалт + watchlist шинэчлэлт',
      },
      targetKind: 'broadcast',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 5)),
    ),

    // 9) Withdrawal
    ApiNotification(
      id: 1009,
      type: 'withdraw',
      title: 'Мөнгөн гарах хүсэлт хүлээн авлаа',
      body: 'Танай 250,000₮ татан авах хүсэлтийг хүлээн авлаа. Дансанд 1-2 цагийн дотор шилжих болно.',
      data: const {
        'amount': 250000,
        'currency': 'MNT',
        'broker': 'Хаан банк',
        'account': '****8821',
        'status': 'PENDING',
      },
      targetKind: 'user',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 7)),
    ),

    // 10) Alert — security alert
    ApiNotification(
      id: 1010,
      type: 'alert',
      title: 'Үнэ хүрсэн дохио',
      body: 'TDB үнэ танай тогтоосон 4,500₮ түвшинд хүрлээ.',
      data: const {
        'symbol': 'TDB',
        'price': 4500,
        'side': 'TARGET',
      },
      targetKind: 'user',
      isRead: true,
      createdAt: now.subtract(const Duration(days: 14)),
    ),
  ];
}
