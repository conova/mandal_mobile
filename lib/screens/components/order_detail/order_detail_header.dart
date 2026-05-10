import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';

class OrderDetailHeader extends StatelessWidget {
  const OrderDetailHeader({super.key});

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  'Net Capital',
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
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    'Нэт Капитал',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge(
                l10n.buy.toUpperCase(),
                extendedColors.primary100,
                extendedColors.primaryMain,
                theme,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                l10n.closed.toUpperCase(),
                extendedColors.bgSecondary,
                extendedColors.neutral100,
                theme,
              ),
              const SizedBox(width: 8),
              _buildBadge(
                l10n.bond.toUpperCase(),
                extendedColors.bgSecondary,
                extendedColors.neutral100,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(
    String label,
    Color bgColor,
    Color textColor,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
