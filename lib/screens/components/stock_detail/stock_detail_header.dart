import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailHeader extends StatelessWidget {
  const StockDetailHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MNDL',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          Text(
            'Мандал даатгал ХК',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: extendedColors.neutral200,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '65.62₮',
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.arrow_drop_up,
                color: extendedColors.primaryMain,
                size: 24,
              ),
              Text(
                '0.65% (-2.07)',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.primaryMain,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.today,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
