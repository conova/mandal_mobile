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

  /// Хүү төлөгдөх бүх өдөр (эхлэхээс хойш, сүүлийнх нь [end])
  final List<DateTime> dueDates;

  /// Сүүлд хүү төлөгдсөн өдөр (нэг ч удаа төлөгдөөгүй бол null)
  final DateTime? lastPaid;

  /// Дараагийн хүү төлөгдөх өдөр (бүгд төлөгдсөн бол null)
  final DateTime? nextPay;

  const BondSchedule({
    required this.paid,
    required this.total,
    required this.start,
    required this.end,
    this.dueDates = const [],
    this.lastPaid,
    this.nextPay,
  });

  int get remaining => (total - paid).clamp(0, total);

  /// Хүү төлөх давтамжийн (PAYTYPE, системийн dateformat) сарын тоо.
  /// Сараар илэрхийлэгдэхгүй (долоо хоног/өдөр) эсвэл танигдахгүй бол null.
  static int? monthsOf(String period) {
    final p = period.toUpperCase().trim();
    if (p == 'YYYY/MM') return 1;
    if (p == 'YYYY/Q') return 3;
    if (p == 'YYYY/2') return 6;
    if (p == 'YYYY') return 12;
    return null;
  }

  /// Сараар биш давтамжийн хоногийн тоо: YYYY/WW — 7, YYYY/MM/DD — 1
  static int? _daysOf(String period) {
    final p = period.toUpperCase().trim();
    if (p == 'YYYY/WW') return 7;
    if (p == 'YYYY/MM/DD') return 1;
    return null;
  }

  /// [start]-аас [period]-ийн [i] дахь алхам. Сарын өдөр давбал (31 → 30/28)
  /// тухайн сарын сүүлийн өдрөөр хязгаарлана.
  static DateTime _step(DateTime start, int i, int? months, int? days) {
    if (months == null) return start.add(Duration(days: days! * i));
    final monthIndex = start.month + months * i;
    final lastDay = DateTime(start.year, monthIndex + 1, 0).day;
    return DateTime(
      start.year,
      monthIndex,
      start.day > lastDay ? lastDay : start.day,
    );
  }

  /// [start]-аас [end] хүртэлх хүүгийн төлбөрийн хуваарь. Сүүлийн төлбөр
  /// нь [end] (дуусах өдөр) — эхлэх өдрөөр тооцсон огноо биш.
  /// Тооцоолох боломжгүй бол null.
  static BondSchedule? build({
    required DateTime? start,
    required DateTime? end,
    required String payPeriod,
    DateTime? nextPayday,
  }) {
    final months = monthsOf(payPeriod);
    final days = months == null ? _daysOf(payPeriod) : null;
    if (start == null || end == null || (months == null && days == null)) {
      return null;
    }
    if (!end.isAfter(start)) return null;

    // Дуусах өдрөөс хагас давтамжаас бага өмнө таарсан огноог тусад нь
    // төлбөр гэж тооцохгүй — тэр төлбөр нь дуусах өдөр олгогдоно
    final tolerance = Duration(days: months != null ? months * 15 : days! ~/ 2);
    final dueDates = <DateTime>[];
    for (var i = 1;; i++) {
      final due = _step(start, i, months, days);
      if (!due.isBefore(end.subtract(tolerance))) break;
      dueDates.add(due);
    }
    dueDates.add(end);

    // Өнөөдрийг хүртэл хэдэн удаа төлөгдсөнийг тоолно
    final now = DateTime.now();
    final paid = dueDates.where((d) => !d.isAfter(now)).length;
    final total = dueDates.length;

    return BondSchedule(
      paid: paid,
      total: total,
      start: start,
      end: end,
      dueDates: dueDates,
      lastPaid: paid == 0 ? null : dueDates[paid - 1],
      nextPay: paid >= total ? null : (nextPayday ?? dueDates[paid]),
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
