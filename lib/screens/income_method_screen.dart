import 'package:flutter/material.dart';
import 'package:mandal_capital/widgets/circle_back_button.dart';
import 'package:mandal_capital/widgets/custom_svg_icon.dart';
import '../l10n/app_localizations.dart';
import '../theme/extended_colors.dart';

class IncomeMethodScreen extends StatelessWidget {
  const IncomeMethodScreen({super.key});

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
                l10n.incomeMethod,
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: extendedColors.neutral100,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                l10n.incomeMethodDesc,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: extendedColors.neutral200,
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Tugrik option
            _buildMethodOption(
              context: context,
              theme: theme,
              extendedColors: extendedColors,
              icon: 'tugrug-01',
              iconColor: extendedColors.primaryMain,
              title: l10n.tugrik,
              subtitle: l10n.qpay,
              showRecommend: true,
              recommendLabel: l10n.recommend,
              onTap: () => Navigator.pushNamed(
                context,
                '/income_amount',
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
              icon: 'currency-dollar',
              iconColor: extendedColors.neutral100,
              title: l10n.dollar,
              subtitle: l10n.qpayAndCard,
              showRecommend: false,
              onTap: () => Navigator.pushNamed(
                context,
                '/income_amount',
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                child: CustomSvgIcon(icon, color: Colors.white,)
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: extendedColors.neutral100,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: extendedColors.neutral200,
                    ),
                  ),
                ],
              ),
            ),
            if (showRecommend && recommendLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: extendedColors.primary100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: extendedColors.primaryMain,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            CustomSvgIcon(
              'chevron-right',
              color: extendedColors.neutral200,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}
