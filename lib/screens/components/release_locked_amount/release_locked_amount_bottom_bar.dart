import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/theme/extended_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/custom_button.dart';

class ReleaseLockedAmountBottomBar extends StatelessWidget {
  final String projectedCashText;
  final VoidCallback onBack;
  final VoidCallback? onCancel;
  final bool isCancelEnabled;

  const ReleaseLockedAmountBottomBar({
    super.key,
    required this.projectedCashText,
    required this.onBack,
    this.onCancel,
    this.isCancelEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        border: Border(
          top: BorderSide(color: extendedColors.neutral500),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${l10n.availableCash}: ',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral300,
                  ),
                ),
                Text(
                  projectedCashText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.primaryMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: extendedColors.bgSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: extendedColors.neutral100,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomButton(
                    label: l10n.cancelOrder,
                    onPressed: isCancelEnabled ? onCancel : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
