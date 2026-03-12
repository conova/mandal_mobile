import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondMarketCard extends StatelessWidget {
  final BuildContext context;
  final String title;
  final String subtitle;
  final String status;
  final String tenure;
  final String yield;
  final String totalAmount;
  final double? progress;
  final String progressLabel;
  final String progressLabel2;

  const BondMarketCard({
    super.key,
    required this.context,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.tenure,
    required this.yield,
    required this.totalAmount,
    this.progress,
    this.progressLabel = '',
    this.progressLabel2 = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          child: Text(
                            status,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: extendedColors.neutral100,
                              fontWeight: AppTextStyles.regular,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: extendedColors.neutral300,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              CustomButton(
                onPressed: () => Navigator.pushNamed(context, '/bond_detail'),
                label: l10n.buy,
                variant: CustomButtonVariant.primary,
              ),
            ],
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(child: _buildMetric(theme, l10n.tenureLabel, tenure)),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: extendedColors.neutral400,
                ),
                Expanded(child: _buildMetric(theme, l10n.interestRate, yield)),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: extendedColors.neutral400,
                ),
                Expanded(
                  child: _buildMetric(theme, l10n.amountLabel, totalAmount),
                ),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: extendedColors.neutral500,
                valueColor: AlwaysStoppedAnimation<Color>(
                  extendedColors.neutral100,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  progressLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral100,
                    fontWeight: AppTextStyles.light,
                  ),
                ),
                Text(
                  '/$progressLabel2',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: extendedColors.neutral200,
                    fontWeight: AppTextStyles.light,
                  ),
                ),
                Spacer(),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral100,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetric(ThemeData theme, String label, String value) {
    final extendedColors = theme.extension<ExtendedColors>()!;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
            fontWeight: AppTextStyles.extraLight,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: AppTextStyles.regular,
          ),
        ),
      ],
    );
  }
}
