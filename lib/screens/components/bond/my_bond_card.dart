import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
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
                          child: CustomSvgIcon(
                            'info-circle',
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
                Expanded(
                  child: _buildMetric(
                    theme,
                    extendedColors,
                    l10n.ownedAmountLabel,
                    ownedAmount,
                  ),
                ),
                VerticalDivider(
                  color: extendedColors.neutral500,
                  width: 1,
                  thickness: 1,
                ),
                Expanded(
                  child: _buildMetric(
                    theme,
                    extendedColors,
                    l10n.interestRate,
                    interestRate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          SizedBox(
            height: 1,
            width: double.infinity,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: extendedColors.neutral400,
              ),
            )
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: AppTextStyles.light,
            color: extendedColors.neutral300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: extendedColors.neutral100,
          ),
        ),
      ],
    );
  }
}
