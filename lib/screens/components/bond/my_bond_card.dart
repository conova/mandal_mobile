import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../common/stock_row_format.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

class MyBondCard extends StatelessWidget {
  final String title;
  final double ownedAmount;
  final String interestRate;
  final dynamic tenure;
  final VoidCallback onSellPressed;

  const MyBondCard({
    super.key,
    required this.title,
    required this.ownedAmount,
    required this.interestRate,
    required this.onSellPressed,
    required this.tenure,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    String tenureStr = '-';
    if (tenure is DateTime) {
      tenureStr = formatTimeLeft(tenure, l10n);
    } else if (tenure != null) {
      tenureStr = tenure.toString();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: extendedColors.neutral100,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            l10n.piece(ownedAmount.toInt()),
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: AppTextStyles.regular,
                              color: extendedColors.neutral200,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: AppTextStyles.bold,
                            color: extendedColors.neutral200,
                          ),
                        ),
                        Text(
                          tenureStr,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: AppTextStyles.regular,
                            color: extendedColors.neutral200,
                          ),
                        ),
                        Text(
                          ' · ',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: AppTextStyles.bold,
                            color: extendedColors.neutral200,
                          ),
                        ),
                        Text(
                          interestRate,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: AppTextStyles.regular,
                            color: extendedColors.neutral200,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 63, maxHeight: 40),
                child: CustomButton(
                  label: l10n.sell,
                  size: CustomButtonSize.small,
                  onPressed: onSellPressed,
                  variant: CustomButtonVariant.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
