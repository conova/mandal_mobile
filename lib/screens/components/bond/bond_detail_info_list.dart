import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

/// Бондын үндсэн үзүүлэлтүүдийн карт: жилийн өгөөж, дараагийн хүү
/// төлөгдөх өдөр, дуусах өдөр, хүү төлөх давтамж.
/// bond == null үед демо утгууд харагдана.
class BondDetailInfoList extends StatelessWidget {
  final Map<String, dynamic>? bond;

  const BondDetailInfoList({super.key, required this.bond});

  String _field(String key) => bond?[key]?.toString() ?? '';

  /// Огноог "2026.2.10 (122 хоног)" хэлбэрээр — үлдсэн хоногтой нь
  String _dateWithDays(String raw, AppLocalizations l10n) {
    final date = parseStockDate(raw);
    if (date == null) return raw.isEmpty ? '-' : raw;
    final formatted = formatStockDate(date);
    final days = date.difference(DateTime.now()).inDays;
    if (days <= 0) return formatted;
    return '$formatted (${l10n.daysCount(days.toString())})';
  }

  /// Хүү төлөх давтамж — locale-аас хамаарч PAYPERIOD (мон) эсвэл
  /// PAYPERIOD2 (англи); аль нь хоосон бол нөгөөгөөр нь нөхнө
  String _payPeriod(BuildContext context) {
    final mn = _field('PAYPERIOD');
    final en = _field('PAYPERIOD2');
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final value =
        isEnglish ? (en.isNotEmpty ? en : mn) : (mn.isNotEmpty ? mn : en);
    return value.isEmpty ? '-' : value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;
    final intRate = _field('INTRATE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.percent,
            l10n.annualYield,
            bond == null ? '12.5%' : (intRate.isEmpty ? '-' : '$intRate%'),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.event_available_outlined,
            l10n.nextInterestPayDate,
            bond == null
                ? '2026.2.10 (${l10n.daysCount('122')})'
                : _dateWithDays(_field('PAYDAY'), l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.event_note_outlined,
            l10n.bondMaturityDate,
            bond == null
                ? '2026.8.10 (${l10n.daysCount('280')})'
                : _dateWithDays(_field('TERM'), l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            Icons.autorenew,
            l10n.paymentFrequency,
            bond == null ? 'Хагас жил' : _payPeriod(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    ExtendedColors extendedColors,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26, color: extendedColors.neutral100),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral300,
                  fontWeight: AppTextStyles.extraLight,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral100,
                  fontWeight: AppTextStyles.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
