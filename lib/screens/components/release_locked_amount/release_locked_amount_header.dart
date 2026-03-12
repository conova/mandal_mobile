import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/extended_colors.dart';

class ReleaseLockedAmountHeader extends StatelessWidget {
  const ReleaseLockedAmountHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.releaseLockedTitle,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: extendedColors.neutral100,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.releaseLockedSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: AppTextStyles.light,
              color: extendedColors.neutral300,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
