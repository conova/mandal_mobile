import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

class MyBondCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String status;
  final Color statusBgColor;
  final Color statusTextColor;
  final String ownedAmount;
  final String interestRate;
  final VoidCallback onSellPressed;

  /// ⓘ icon дээр дарахад — бондын төлвийн тайлбарын sheet нээнэ
  final VoidCallback? onInfoTap;

  const MyBondCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.statusBgColor,
    required this.statusTextColor,
    required this.ownedAmount,
    required this.interestRate,
    required this.onSellPressed,
    this.onInfoTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: extendedColors.neutral500),
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
                        Flexible(
                          child: Text(
                            subtitle,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: AppTextStyles.light,
                              color: extendedColors.neutral300,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: statusTextColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onInfoTap,
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            Icons.info_outline,
                            size: 20,
                            color: extendedColors.neutral300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 90),
                child: CustomButton(
                  label: l10n.sell,
                  size: CustomButtonSize.small,
                  onPressed: onSellPressed,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              children: [
                _buildMetric(
                  theme,
                  extendedColors,
                  l10n.ownedAmountLabel,
                  ownedAmount,
                ),
                const SizedBox(width: 24),
                VerticalDivider(
                  color: extendedColors.neutral500,
                  width: 1,
                  thickness: 1,
                ),
                const SizedBox(width: 24),
                _buildMetric(
                  theme,
                  extendedColors,
                  l10n.interestRate,
                  interestRate,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    ThemeData theme,
    ExtendedColors extendedColors,
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: AppTextStyles.light,
            color: extendedColors.neutral300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}
