import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondMarketCardCompact extends StatelessWidget {
  /// /stocks/* API-ийн түүхий мөр — detail дэлгэц рүү бүхэлд нь дамжуулна
  final Map<String, dynamic> bond;
  final BuildContext context;
  final String title;

  /// Can be DateTime (maturity/order end date) or String (manual term)
  final dynamic tenure;
  final String yield;
  final String? payday;
  final String? market;
  final bool isBuy;

  const BondMarketCardCompact(
    this.bond, {
    super.key,
    required this.context,
    required this.title,
    required this.tenure,
    required this.yield,
    this.payday,
    this.market,
    this.isBuy = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    String tenureStr = '-';
    if (tenure is DateTime) {
      tenureStr = formatTimeLeft(tenure, l10n);
    } else if (tenure != null) {
      tenureStr = tenure.toString();
    }

    // Format the interest rate here to ensure "X.X%" format

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: extendedColors.neutral100,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      tenureStr,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: AppTextStyles.regular,
                        color: extendedColors.neutral300,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                yield,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: AppTextStyles.regular,
                  color: extendedColors.primaryMain,
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 63, maxHeight: 40),
                child: CustomButton(
                  onPressed: () => Navigator.pushNamed(
                    context,
                    '/bond_detail',
                    arguments: {
                      'bond': bond,
                      'languageCode': Localizations.localeOf(
                        context,
                      ).languageCode,
                    },
                  ),
                  label: l10n.buy,
                  size: CustomButtonSize.small,
                  variant: CustomButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
