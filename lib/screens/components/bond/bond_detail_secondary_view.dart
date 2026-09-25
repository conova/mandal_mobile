import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import 'bond_date_row.dart';
import 'bond_fact_card.dart';
import 'bond_payment_schedule.dart';

/// ХОЁРДОГЧ зах зээлийн бондын дизайн: үзүүлэлтүүдийн карт, хүүгийн
/// төлбөрийн хуваарь болон гол огноонууд.
class BondDetailSecondaryView extends StatelessWidget {
  final MarketInstrument? bond;
  final double topPadding;

  const BondDetailSecondaryView({super.key, required this.bond, required this.topPadding});

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

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPadding),
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
          BondDateRow(
            label: l10n.lastInterestPaymentDate,
            date: schedule?.lastPaid,
          ),
          BondDateRow(
            label: l10n.nextInterestPayDate,
            date: schedule?.nextPay ?? parseStockDate(bond?.payday),
          ),
          BondDateRow(label: l10n.bondMaturityDate, date: maturity, isLast: true),
        ],
      ),
    );
  }
}
