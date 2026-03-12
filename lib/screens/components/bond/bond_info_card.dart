import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/extended_colors.dart';

class BondInfoCard extends StatelessWidget {
  final String tenure;
  final String rate;
  final String frequency;

  const BondInfoCard({
    super.key,
    required this.tenure,
    required this.rate,
    required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = Theme.of(context).extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: extendedColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Theme.of(context),
            Icons.calendar_today_outlined,
            l10n.tenureLabel,
            tenure,
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Theme.of(context),
            Icons.percent,
            l10n.annualInterest,
            rate,
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Theme.of(context),
            Icons.refresh,
            l10n.paymentFrequency,
            frequency,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.extension<ExtendedColors>()!.bgSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 24,
            color: theme.extension<ExtendedColors>()!.neutral100,
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.extension<ExtendedColors>()!.neutral100,
                fontWeight: AppTextStyles.extraLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.extension<ExtendedColors>()!.neutral100,
                fontWeight: AppTextStyles.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
