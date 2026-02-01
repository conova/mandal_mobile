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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: extendedColors.primary100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.info, color: extendedColors.neutral100, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '${l10n.lockedAmountLabel}: $amount',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
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
                  style: TextStyle(
                    color: extendedColors.neutral100,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(Icons.expand_less, color: extendedColors.neutral100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
