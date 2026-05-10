import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../../../theme/extended_colors.dart';

class BondActionBottomBar extends StatelessWidget {
  final String label;
  final String amount;
  final String buttonText;
  final VoidCallback onPressed;

  const BondActionBottomBar({
    super.key,
    required this.label,
    required this.amount,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: extendedColors.bgBase,
        boxShadow: [
          BoxShadow(
            color: extendedColors.neutral500,
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.regular,
                    color: extendedColors.primaryMain,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          CustomButton(
            onPressed: onPressed,
            label: buttonText,
            variant: CustomButtonVariant.primary,
          ),
        ],
      ),
    );
  }
}
