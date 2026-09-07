import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/extended_colors.dart';

/// Бондын үндсэн үзүүлэлтүүдийн карт: жилийн өгөөж, дараагийн хүү
/// төлөгдөх өдөр, дуусах өдөр, хүү төлөх давтамж.
/// bond == null үед демо утгууд харагдана.
class BondDetailInfoList extends StatelessWidget {
  final MarketInstrument? bond;

  const BondDetailInfoList({super.key, required this.bond});

  /// Огноог "2026.2.10 (122 хоног)" хэлбэрээр — үлдсэн хоногтой нь
  String _dateWithDays(String raw, AppLocalizations l10n) {
    final date = parseStockDate(raw);
    if (date == null) return raw.isEmpty ? '-' : raw;
    final formatted = formatStockDate(date);
    final days = date.difference(DateTime.now()).inDays;
    if (days <= 0) return formatted;
    return '$formatted (${l10n.daysCount(days.toString())})';
  }

  /// Хүү төлөх давтамж — locale-аас хамаарч payPeriod (мон) эсвэл
  /// payPeriod2 (англи); аль нь хоосон бол нөгөөгөөр нь нөхнө
  String _payPeriodOf(BuildContext context) {
    final mn = bond?.payPeriod ?? '';
    final en = bond?.payPeriod2 ?? '';
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
    final intRate = bond?.intRate;

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
            'percent-icon',
            l10n.annualYield,
            bond == null ? '0.0%' : (intRate == null ? '-' : '$intRate%'),
          ),
          const SizedBox(height: 20,),
          _buildInfoRow(
            theme,
            extendedColors,
            'bank-note-01',
            l10n.lastInterestPaymentDate,
            bond == null ? '2000.01.01 (${l10n.daysCount('0')})' : _dateWithDays(bond!.payday, l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            'calendar-check',
            l10n.nextInterestPayDate,
            bond == null
                ? '2000.01.01 (${l10n.daysCount('0')})'
                : _dateWithDays(bond!.payday, l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            'calendar-done',
            l10n.bondMaturityDate,
            bond == null
                ? '2000.01.01 (${l10n.daysCount('0')})'
                : _dateWithDays(bond!.term, l10n),
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            theme,
            extendedColors,
            'clock-refresh',
            l10n.paymentFrequency,
            bond == null ? 'Хагас жил' : _payPeriodOf(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    ExtendedColors extendedColors,
    String icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const SizedBox(height: 12,),
            CustomSvgIcon(icon, size: 24, color: extendedColors.neutral100),
          ],
        ),
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
