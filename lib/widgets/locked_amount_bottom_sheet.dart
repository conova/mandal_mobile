import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

class LockedAmountBottomSheet extends StatelessWidget {
  final String amount;
  final VoidCallback onRelease;

  const LockedAmountBottomSheet({
    super.key,
    required this.amount,
    required this.onRelease,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: extendedColors.primary100),
      child: Row(
        children: [
          Icon(Icons.info, color: extendedColors.primaryMain, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${l10n.lockedAmountLabel}: $amount',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w300,
                color: extendedColors.neutral100,
              ),
            ),
          ),
          TextButton(
            onPressed: onRelease,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.release,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                    color: extendedColors.primaryMain,
                  ),
                ),
                Icon(Icons.expand_less, color: extendedColors.primaryMain),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
