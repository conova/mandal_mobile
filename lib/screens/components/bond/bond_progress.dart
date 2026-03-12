import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class BondProgress extends StatelessWidget {
  final String current;
  final String total;
  final double percentage;

  const BondProgress({
    super.key,
    required this.current,
    required this.total,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bondCollectionTarget,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: extendedColors.neutral200,
            fontWeight: AppTextStyles.extraLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: AppTextStyles.regular,
                  color: extendedColors.neutral100,
                ),
                children: [
                  TextSpan(text: current),
                  TextSpan(
                    text: ' / $total',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                      fontWeight: AppTextStyles.light,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${(percentage * 100).toInt()}%',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: AppTextStyles.light,
                color: extendedColors.neutral100,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              theme.colorScheme.onSurface,
            ),
            minHeight: 4,
          ),
        ),
      ],
    );
  }
}
