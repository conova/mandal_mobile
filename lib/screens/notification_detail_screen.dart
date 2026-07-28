import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/api_notification.dart';
import '../theme/app_text_styles.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';
import '../widgets/custom_button.dart';

/// Notification дэлгэрэнгүй харах дэлгэц.
///
/// Args: [ApiNotification] объект. (Хуучин Map хэлбэрийг мөн дэмжинэ —
/// FCM push г.м. гаднаас Map-аар навигаци хийх боломж хэвээр.)
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final rawArgs = ModalRoute.of(context)?.settings.arguments;

    final String type;
    final String title;
    final String body;
    final String time;
    final String? targetKind;
    final Map<String, dynamic> data;

    if (rawArgs is ApiNotification) {
      type = rawArgs.type;
      title = rawArgs.title;
      body = rawArgs.body;
      time = rawArgs.formattedTime;
      targetKind = rawArgs.targetKind;
      data = rawArgs.data ?? const {};
    } else {
      final args = rawArgs is Map<String, dynamic> ? rawArgs : const {};
      type = (args['type'] as String?) ?? 'system';
      title = (args['title'] as String?) ?? '';
      body = (args['body'] as String?) ?? '';
      time = (args['time'] as String?) ?? '';
      targetKind = args['targetKind'] as String?;
      data = args['data'] is Map
          ? Map<String, dynamic>.from(args['data'] as Map)
          : const {};
    }

    final icon = notificationIconForType(type);

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leadingWidth: 60,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20, bottom: 10),
          child: SizedBox(width: 40, height: 40, child: CircleBackButton()),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 10,),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon + type chip
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: extendedColors.bgSecondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            icon,
                            size: 32,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        const SizedBox(width: 12),
                        _TypeChip(
                          type: type,
                          targetKind: targetKind,
                          extendedColors: extendedColors,
                          theme: theme,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Title
                    Text(
                      title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Body
                    if (body.isNotEmpty)
                      Text(
                        body,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                          height: 1.5,
                        ),
                      ),
                    const SizedBox(height: 24),
                    // Time
                    Text(
                      time,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: extendedColors.neutral300,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Холбогдох мэдээлэл — data Map дотор утга байвал гарна
                    if (data.isNotEmpty) ...[
                      Text(
                        l10n.notificationRelatedInfo,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: AppTextStyles.semiBold,
                          color: extendedColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _DataTable(
                        data: data,
                        extendedColors: extendedColors,
                        theme: theme,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: extendedColors.neutral500,),
            // Footer button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: CustomButton(
                label: l10n.back,
                onPressed: () => Navigator.pop(context),
                variant: CustomButtonVariant.tertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Notification type-аас тохирох icon. List болон detail хоёуланд хэрэглэгдэнэ.
IconData notificationIconForType(String? type) {
  switch ((type ?? '').toLowerCase()) {
    case 'order':
    case 'trading':
      return Icons.swap_horiz;
    case 'news':
      return Icons.article_outlined;
    case 'promo':
    case 'promotion':
      return Icons.local_offer_outlined;
    case 'security':
    case 'alert':
      return Icons.security;
    case 'payment':
    case 'deposit':
    case 'withdraw':
      return Icons.account_balance_wallet_outlined;
    case 'kyc':
    case 'verification':
      return Icons.verified_user_outlined;
    case 'system':
    default:
      return Icons.notifications_none_outlined;
  }
}

/// Type + targetKind харуулах жижиг chip.
class _TypeChip extends StatelessWidget {
  final String type;
  final String? targetKind;
  final ExtendedColors extendedColors;
  final ThemeData theme;
  const _TypeChip({
    required this.type,
    required this.targetKind,
    required this.extendedColors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final isBroadcast = (targetKind ?? '').toLowerCase() == 'broadcast';
    final label =
        isBroadcast ? '${_typeLabel(type)} • Олон нийтийн' : _typeLabel(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: extendedColors.neutral200,
          fontWeight: AppTextStyles.semiBold,
        ),
      ),
    );
  }

  String _typeLabel(String t) {
    switch (t.toLowerCase()) {
      case 'order':
      case 'trading':
        return 'Арилжаа';
      case 'news':
        return 'Мэдээ';
      case 'promo':
      case 'promotion':
        return 'Урамшуулал';
      case 'security':
      case 'alert':
        return 'Аюулгүй байдал';
      case 'payment':
      case 'deposit':
      case 'withdraw':
        return 'Гүйлгээ';
      case 'kyc':
      case 'verification':
        return 'Баталгаажуулалт';
      case 'system':
      default:
        return 'Систем';
    }
  }
}

/// `data` Map-ыг key/value хүснэгт хэлбэрээр харуулна.
class _DataTable extends StatelessWidget {
  final Map<String, dynamic> data;
  final ExtendedColors extendedColors;
  final ThemeData theme;
  const _DataTable({
    required this.data,
    required this.extendedColors,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < data.entries.length; i++) ...[
            _row(data.entries.elementAt(i)),
            if (i < data.entries.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  height: 1,
                  color: extendedColors.neutral400,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _row(MapEntry<String, dynamic> entry) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            _humanizeKey(entry.key),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral300,
              fontWeight: AppTextStyles.regular,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            _formatValue(entry.value),
            textAlign: TextAlign.right,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral100,
              fontWeight: AppTextStyles.semiBold,
            ),
          ),
        ),
      ],
    );
  }

  /// snake_case → "Snake Case"; нэр томъёонуудыг монголоор орчуулна.
  String _humanizeKey(String key) {
    const dictionary = <String, String>{
      'order_id': 'Захиалгын дугаар',
      'symbol': 'Симбол',
      'amount': 'Дүн',
      'price': 'Үнэ',
      'quantity': 'Тоо ширхэг',
      'side': 'Талаас',
      'status': 'Төлөв',
      'currency': 'Валют',
      'url': 'Холбоос',
      'reason': 'Шалтгаан',
      'message': 'Мессеж',
      'broker': 'Брокер',
      'account': 'Данс',
      'fee': 'Шимтгэл',
      'total': 'Нийт',
    };
    final lower = key.toLowerCase();
    if (dictionary.containsKey(lower)) return dictionary[lower]!;
    // snake_case → Title Case
    return lower
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _formatValue(dynamic v) {
    if (v == null) return '—';
    if (v is num) {
      // Бүхэл бол шууд, бутархай бол 2 орон
      if (v == v.toInt()) return v.toInt().toString();
      return v.toStringAsFixed(2);
    }
    if (v is bool) return v ? 'Тийм' : 'Үгүй';
    if (v is List) return v.join(', ');
    if (v is Map) return v.toString();
    return v.toString();
  }
}
