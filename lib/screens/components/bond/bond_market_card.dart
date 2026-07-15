import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondMarketCard extends StatelessWidget {
  /// /stocks/* API-ийн түүхий мөр — detail дэлгэц рүү бүхэлд нь дамжуулна
  final Map<String, dynamic> bond;
  final BuildContext context;
  final String title;
  final String subtitle;
  final String status;
  final String tenure;
  final String yield;
  final String totalAmount;
  final double? progress;
  final String? payday;
  final String? market;
  final String progressLabel;
  final String progressLabel2;

  const BondMarketCard(
    this.bond, {
    super.key,
    required this.context,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.tenure,
    required this.yield,
    required this.totalAmount,
    this.progress,
    this.payday,
    this.market,
    this.progressLabel = '',
    this.progressLabel2 = '',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
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
                              color: extendedColors.neutral100,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: extendedColors.neutral200,
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
                          decoration: BoxDecoration(
                            color: extendedColors.bgSecondary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: Text(
                            status.toUpperCase(),
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
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 90),
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
          if (progress != null && market == 'primary') ...[
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
