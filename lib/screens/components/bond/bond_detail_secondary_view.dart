import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import 'bond_fact_card.dart';
import 'bond_payment_schedule.dart';

/// ХОЁРДОГЧ зах зээлийн бондын дизайн: үзүүлэлтүүдийн карт, хүүгийн
/// төлбөрийн хуваарь болон гол огноонууд.
class BondDetailSecondaryView extends StatelessWidget {
  final MarketInstrument? bond;

  const BondDetailSecondaryView({super.key, required this.bond});

  /// Хувь хүний бондын хүүгийн татвар — API-аас ирээгүй бол 10%
  static const String _defaultTaxRate = '10%';

  /// Хүү төлөх давтамж — locale-ийн дагуу (хоосон бол нөгөөгөөр нөхнө)
  String _payPeriodOf(BuildContext context) {
    final mn = bond?.payPeriod ?? '';
    final en = bond?.payPeriod2 ?? '';
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final value =
        isEnglish ? (en.isNotEmpty ? en : mn) : (mn.isNotEmpty ? mn : en);
    return value.isEmpty ? '-' : value;
  }

  String get _taxLabel {
    final raw = bond?.raw['TAX'] ?? bond?.raw['TAXRATE'];
    final value = num.tryParse(raw?.toString() ?? '');
    return value == null ? _defaultTaxRate : '$value%';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Төлбөрийн хуваарь — эхлэх/дуусах огноо, давтамжаас тооцоолно.
    // Аль нэг нь дутуу эсвэл давтамж танигдахгүй бол хэсгийг харуулахгүй.
    final schedule = BondSchedule.build(
      start: parseStockDate(bond?.startDate),
      end: parseStockDate(bond?.endDate),
      payPeriod: bond?.payPeriod ?? '',
      nextPayday: parseStockDate(bond?.payday),
    );
    final maturity = parseStockDate(bond?.endDate) ?? parseStockDate(bond?.term);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BondFactCard(
          facts: [
            BondFact(l10n.annualYield, formatIntRate(bond?.intRate)),
            BondFact(l10n.paymentFrequency, _payPeriodOf(context)),
            BondFact(l10n.taxLabel, _taxLabel),
          ],
        ),
        const SizedBox(height: 32),
        if (schedule != null) ...[
          BondPaymentSchedule(schedule: schedule),
          const SizedBox(height: 24),
        ],
        _DateRow(
          label: l10n.lastInterestPaymentDate,
          date: schedule?.lastPaid,
        ),
        _DateRow(
          label: l10n.nextInterestPayDate,
          date: schedule?.nextPay ?? parseStockDate(bond?.payday),
        ),
        _DateRow(label: l10n.bondMaturityDate, date: maturity, isLast: true),
      ],
    );
  }
}

/// Шошго дээр, огноо доор нь — хоорондоо зайтай мөр
class _DateRow extends StatelessWidget {
  final String label;
  final DateTime? date;
  final bool isLast;

  const _DateRow({required this.label, this.date, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: AppTextStyles.light,
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date == null ? '-' : formatStockDate(date!).replaceAll('/', '.'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: AppTextStyles.regular,
              color: extendedColors.neutral100,
            ),
          ),
        ],
      ),
    );
  }
}
