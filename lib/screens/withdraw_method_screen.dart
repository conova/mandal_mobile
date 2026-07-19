import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';
import '../widgets/circle_back_button.dart';

class WithdrawMethodScreen extends StatelessWidget {
  const WithdrawMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: extendedColors.bgBase,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CircleBackButton(),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.withdrawMethod,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.withdrawMethodDesc,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: extendedColors.neutral300,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Tugrik option
            _buildMethodOption(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: '₮',
              iconColor: extendedColors.primaryMain,
              title: l10n.tugrik,
              subtitle: l10n.bankTransfer,
              showRecommend: true,
              recommendLabel: l10n.recommend,
              onTap: () => Navigator.pushNamed(
                context,
                '/withdraw_amount',
                arguments: 'mnt',
              ),
            ),
            Divider(
              height: 1,
              color: extendedColors.neutral500,
              indent: 24,
              endIndent: 24,
            ),
            // Dollar option
            _buildMethodOption(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: '\$',
              iconColor: extendedColors.neutral100,
              title: l10n.dollar,
              subtitle: l10n.bankTransferDesc,
              showRecommend: false,
              onTap: () => Navigator.pushNamed(
                context,
                '/withdraw_amount',
                arguments: 'usd',
              ),
            ),
            Divider(
              height: 1,
              color: extendedColors.neutral500,
              indent: 24,
              endIndent: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption({
    required BuildContext context,
    required ThemeData theme,
    required ExtendedColors extendedColors,
    required String icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showRecommend = false,
    String? recommendLabel,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    color: extendedColors.bgBase,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: extendedColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
            if (showRecommend && recommendLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: extendedColors.primary100.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  recommendLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: extendedColors.primaryMain,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: extendedColors.neutral300,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
