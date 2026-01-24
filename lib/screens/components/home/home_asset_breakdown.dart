import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../widgets/asset_card.dart';

class HomeAssetBreakdown extends StatelessWidget {
  const HomeAssetBreakdown({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.assetBreakdown,
          style: theme.textTheme.titleLarge?.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 16),
        AssetCard(
            icon: Icons.currency_ruble,
            title: l10n.tugrik,
            subtitle: l10n.orderCount('2'),
            amount: '128,000.53₮'),
        AssetCard(
            icon: Icons.attach_money,
            title: l10n.dollar,
            subtitle: l10n.orderCount('0'),
            amount: '0.00\$',
            isDark: true),
      ],
    );
  }
}
