import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';

/// Бондын хүүгийн төлбөрийн хуваарь — эхлэх/дуусах огноо болон хүү төлөх
/// давтамжаас тооцоологдоно.
class BondSchedule {
  final int paid;
  final int total;
  final DateTime start;
  final DateTime end;

  /// Сүүлд хүү төлөгдсөн өдөр (нэг ч удаа төлөгдөөгүй бол null)
  final DateTime? lastPaid;

  /// Дараагийн хүү төлөгдөх өдөр (бүгд төлөгдсөн бол null)
  final DateTime? nextPay;

  const BondSchedule({
    required this.paid,
    required this.total,
    required this.start,
    required this.end,
    this.lastPaid,
    this.nextPay,
  });

  int get remaining => (total - paid).clamp(0, total);

  /// Хүү төлөх давтамжийн бичвэрээс сарын тоо гаргана.
  /// Танигдахгүй бол null — хуваарийг огт харуулахгүй.
  ///
  /// "Хагас жил" нь "жил" гэсэн үг агуулдаг тул шалгах дараалал чухал.
  static int? monthsOf(String period) {
    final p = period.toLowerCase().trim();
    if (p.isEmpty) return null;
    if (p.contains('сар') || p.contains('month')) return 1;
    if (p.contains('улирал') || p.contains('quarter')) return 3;
    if (p.contains('хагас') || p.contains('semi') || p.contains('half')) {
      return 6;
    }
    if (p.contains('жил') || p.contains('year') || p.contains('annual')) {
      return 12;
    }
    return null;
  }

  /// [start]-аас [end] хүртэлх хугацааг [periodMonths]-аар хуваан
  /// хуваарь үүсгэнэ. Тооцоолох боломжгүй бол null.
  static BondSchedule? build({
    required DateTime? start,
    required DateTime? end,
    required String payPeriod,
    DateTime? nextPayday,
  }) {
    final months = monthsOf(payPeriod);
    if (start == null || end == null || months == null) return null;
    if (!end.isAfter(start)) return null;

    final totalMonths =
        (end.year - start.year) * 12 + (end.month - start.month);
    final total = (totalMonths / months).round();
    if (total <= 0) return null;

    // Өнөөдрийг хүртэл хэдэн удаа төлөгдсөнийг тоолно
    final now = DateTime.now();
    var paid = 0;
    for (var i = 1; i <= total; i++) {
      final due = DateTime(start.year, start.month + months * i, start.day);
      if (due.isAfter(now)) break;
      paid = i;
    }

    return BondSchedule(
      paid: paid,
      total: total,
      start: start,
      end: end,
      lastPaid: paid == 0
          ? null
          : DateTime(start.year, start.month + months * paid, start.day),
      nextPay: paid >= total
          ? null
          : (nextPayday ??
              DateTime(start.year, start.month + months * (paid + 1),
                  start.day)),
    );
  }
}

/// "Хуваарьт төлбөрүүд" хэсэг — төлөгдсөн/үлдсэн тоо, сегментчилсэн
/// прогресс, эхлэх/дуусах огноо.
class BondPaymentSchedule extends StatelessWidget {
  final BondSchedule schedule;

  const BondPaymentSchedule({super.key, required this.schedule});

  String _fmt(DateTime d) => formatStockDate(d).replaceAll('/', '.');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.scheduledPayments,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: AppTextStyles.semiBold,
            color: extendedColors.neutral100,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _CountLabel(
              count: schedule.paid,
              label: l10n.timesPaid,
              countFirst: true,
            ),
            const Spacer(),
            _CountLabel(
              count: schedule.remaining,
              label: l10n.remainingPayments,
              countFirst: false,
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Сегмент бүр нэг төлбөр — төлөгдсөн нь primary өнгөтэй
        Row(
          children: [
            for (var i = 0; i < schedule.total; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: i < schedule.paid
                        ? extendedColors.primaryMain
                        : extendedColors.primary100,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _fmt(schedule.start),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral200,
              ),
            ),
            Text(
              _fmt(schedule.end),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral200,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// "5 удаа төлөгдсөн" / "үлдсэн төлөлт 7" — тоо нь том, бичиг нь жижиг
class _CountLabel extends StatelessWidget {
  final int count;
  final String label;
  final bool countFirst;

  const _CountLabel({
    required this.count,
    required this.label,
    required this.countFirst,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    final number = Text(
      '$count',
      style: theme.textTheme.headlineLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: extendedColors.neutral100,
      ),
    );
    final text = Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          fontWeight: AppTextStyles.light,
          color: extendedColors.neutral200,
        ),
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: countFirst
          ? [number, const SizedBox(width: 6), text]
          : [text, const SizedBox(width: 6), number],
    );
  }
}
