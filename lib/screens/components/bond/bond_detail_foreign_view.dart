import 'package:flutter/material.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';
import 'bond_close_date_banner.dart';
import 'bond_date_row.dart';
import 'bond_fact_card.dart';
import 'bond_payment_schedule.dart';

/// ГАДААД бондын дизайн: цугларсан дүнгийн явц, үзүүлэлтүүдийн карт,
/// хаагдах төлөвлөгөөт огноо, хүүгийн төлбөрийн хуваарь.
class BondDetailForeignView extends StatelessWidget {
  final MarketInstrument? bond;
  final double topPadding;

  const BondDetailForeignView({super.key, required this.bond, required this.topPadding});

  /// Хүү төлөх давтамж — locale-ийн дагуу (хоосон бол нөгөөгөөр нөхнө)
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

    final progress = orderProgress(bond?.orderedAmt, bond?.amt);
    // Захиалга хаагдах огноо — байхгүй бол арилжааны огноогоор нөхнө
    final closeDate =
        parseStockDate(bond?.orderEndDate) ?? parseStockDate(bond?.payday);

    // Төлбөрийн хуваарь — дата дутуу бол хэсгийг харуулахгүй
    final schedule = BondSchedule.build(
      start: parseStockDate(bond?.startDate),
      end: parseStockDate(bond?.endDate),
      payPeriod: bond?.payPeriod ?? '',
      nextPayday: parseStockDate(bond?.payday),
    );
    final maturity =
        parseStockDate(bond?.endDate) ?? parseStockDate(bond?.term);

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: topPadding),
          if (progress != null) ...[
            Text(
              l10n.collectedAmount,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral200,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    formatStockAmount(
                      bond?.orderedAmt ?? 0,
                      isForeign: true,
                      decimals: 0,
                    ),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.regular,
                      color: extendedColors.primaryMain,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: extendedColors.bgTertiary,
                valueColor: AlwaysStoppedAnimation<Color>(
                  extendedColors.primaryMain,
                ),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${l10n.targetAmount}: ',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                ),
                Flexible(
                  child: Text(
                    formatStockAmount(
                      bond?.amt ?? 0,
                      isForeign: true,
                      decimals: 0,
                    ),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: AppTextStyles.semiBold,
                      color: extendedColors.neutral100,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
          ],
          BondFactCard(
            facts: [
              BondFact(l10n.annualInterest, formatIntRate(bond?.intRate)),
              BondFact(l10n.paymentFrequency, _payPeriodOf(context)),
            ],
          ),
          if (closeDate != null) ...[
            const SizedBox(height: 20),
            BondCloseDateBanner(date: closeDate),
          ],
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
          BondDateRow(
            label: l10n.bondMaturityDate,
            date: maturity,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
