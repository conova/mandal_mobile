import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../l10n/app_localizations.dart';

class StockDetailBottomBar extends StatelessWidget {
  final VoidCallback onTrade;

  const StockDetailBottomBar({super.key, required this.onTrade});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 100,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.tugrik,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '142,000.53₮',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: extendedColors.primaryMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: CustomButton(
                label: l10n.trade,
                onPressed: onTrade,
                size: CustomButtonSize.large,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
