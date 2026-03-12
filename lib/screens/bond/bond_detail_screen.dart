import 'package:flutter/material.dart';
import 'package:mandal_capital/theme/app_text_styles.dart';
import 'package:mandal_capital/widgets/custom_button.dart';
import '../components/bond/bond_progress.dart';
import '../components/bond/bond_info_card.dart';
import '../components/bond/bond_action_bottom_bar.dart';
import '../../l10n/app_localizations.dart';
import '../../theme/extended_colors.dart';

class BondDetailScreen extends StatelessWidget {
  const BondDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final extendedColors = theme.extension<ExtendedColors>()!;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Net Capital',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: extendedColors.neutral100,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Нэт Капитал',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: AppTextStyles.light,
                    color: extendedColors.neutral200,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildBadge(
                  l10n.closed,
                  extendedColors.primary100,
                  extendedColors.primaryMain,
                ),
                const SizedBox(width: 8),
                _buildBadge(
                  l10n.primaryMarket,
                  extendedColors.bgSecondary,
                  theme.colorScheme.onSurface,
                ),
              ],
            ),
            const SizedBox(height: 32),
            const BondProgress(
              current: '900,000₮',
              total: '1,000,000,000₮',
              percentage: 0.02,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              decoration: BoxDecoration(
                color: extendedColors.primary100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: extendedColors.neutral100,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.bondClosingDateLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: AppTextStyles.extraLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '2025.12.20 16:00',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: extendedColors.neutral100,
                            fontWeight: AppTextStyles.regular,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const BondInfoCard(
              tenure: '12 сар',
              rate: '19.5%',
              frequency: 'Улирал бүр',
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: () {},
                label: l10n.viewBondPresentation,
                variant: CustomButtonVariant.tertiary,
              ),
            ),
            const SizedBox(height: 120), // Bottom bar space
          ],
        ),
      ),
      bottomNavigationBar: BondActionBottomBar(
        label: l10n.availableCash,
        amount: '10,000,000₮',
        buttonText: l10n.buyBond,
        onPressed: () => Navigator.pushNamed(context, '/bond_buy'),
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: AppTextStyles.paragraph1.copyWith(
          color: textColor,
          fontWeight: AppTextStyles.regular,
        ),
      ),
    );
  }
}
