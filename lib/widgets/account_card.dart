import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_colors.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';

import '../theme/extended_colors.dart';

class AccountCard extends StatelessWidget {
  final String bankName;
  final String accountNumber;
  final bool isPrimary;
  final VoidCallback? onTap;

  const AccountCard({
    super.key,
    required this.bankName,
    required this.accountNumber,
    this.isPrimary = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: isPrimary
              ? Border.all(color: theme.primaryColor.withOpacity(0.5))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    accountNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: extendedColors.neutral100,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    bankName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            const CustomSvgIcon('chevron-right', size: 20,),
          ],
        ),
      ),
    );
  }
}
