import 'package:flutter/material.dart';
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
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Нэт Капитал',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
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
              padding: const EdgeInsets.all(16),
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
                          style: TextStyle(
                            fontSize: 13,
                            color: extendedColors.neutral100,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '2025.12.20 16:00',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: extendedColors.neutral100,
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
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  backgroundColor: extendedColors.bgSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  l10n.viewBondPresentation,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
