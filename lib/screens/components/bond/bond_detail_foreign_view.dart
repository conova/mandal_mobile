import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/market_instrument.dart';
import '../../../theme/extended_colors.dart';
import 'bond_detail_info_list.dart';
import 'bond_progress.dart';

/// ГАДААД + хоёрдогч бондын дизайн: цуглуулах дүнгийн явц
/// (ORDEREDAMT/AMT), арилжаа биелэх төлөвлөгөөт огноо (PAYDAY),
/// үзүүлэлтүүдийн карт, танилцуулга үзэх товч.
class BondDetailForeignView extends StatelessWidget {
  final MarketInstrument? bond;

  const BondDetailForeignView({super.key, required this.bond});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    final progress =
        bond == null ? null : orderProgress(bond!.orderedAmt, bond!.amt);
    final paydayDate = parseStockDate(bond?.payday);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (progress != null) ...[
          BondProgress(
            current: formatStockAmount(
              bond?.orderedAmt,
              isForeign: true,
              decimals: 0,
            ),
            total: formatStockAmount(bond?.amt, isForeign: true, decimals: 0),
            percentage: progress,
          ),
          const SizedBox(height: 24),
        ],
        if (paydayDate != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: extendedColors.primary100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  color: extendedColors.primaryMain,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tradePlannedDate,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: AppTextStyles.extraLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatStockDate(paydayDate),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: extendedColors.neutral100,
                          fontWeight: AppTextStyles.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
        BondDetailInfoList(bond: bond),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: CustomButton(
            onPressed: () {},
            label: l10n.viewBondPresentation,
            variant: CustomButtonVariant.tertiary,
          ),
        ),
      ],
    );
  }
}
