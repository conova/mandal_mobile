import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';
import '../../../widgets/custom_button.dart';

class PledgeBondBanner extends StatelessWidget {
  const PledgeBondBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: extendedColors.primary100,
        borderRadius: BorderRadius.circular(24),
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
                      l10n.pledgeBond,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: extendedColors.neutral100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.pledgeBondDesc,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: AppTextStyles.light,
                        color: extendedColors.neutral100,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.savings_rounded,
                color: extendedColors.neutral100,
                size: 64,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildBannerMetric(
                theme,
                l10n.availableAmountLabel,
                '23,000,000₮',
                extendedColors,
              ),
              const SizedBox(width: 32),
              _buildBannerMetric(
                theme,
                l10n.costLabel,
                'Бондын хүү +6%',
                extendedColors,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: l10n.pledge,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerMetric(
    ThemeData theme,
    String label,
    String value,
    ExtendedColors extendedColors,
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
